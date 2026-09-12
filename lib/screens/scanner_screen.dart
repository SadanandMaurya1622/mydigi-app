import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/scanned_bill.dart';
import '../providers/warranty_provider.dart';
import '../services/bill_scanner.dart';
import '../services/local_bill_vault.dart';
import '../utils/app_theme.dart';
import '../widgets/glass_container.dart';
import 'add_product_screen.dart';
import 'invoice_vault_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key, this.imagePicker, this.billScanner});

  final ImagePicker? imagePicker;
  final BillScanner? billScanner;

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  late final ImagePicker _picker;
  late final BillScanner _scanner;
  Uint8List? _photo;
  XFile? _photoFile;
  ScannedBill? _scannedBill;
  bool _readingBill = false;
  bool _scanFailed = false;
  bool _busy = true;
  String? _errorCode;
  String? _photoDocumentId;
  bool _savedToVault = false;

  bool get _isMobile =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  void initState() {
    super.initState();
    _picker = widget.imagePicker ?? ImagePicker();
    _scanner = widget.billScanner ?? BillScanner();
    WidgetsBinding.instance.addPostFrameCallback((_) => _openScanner());
  }

  Future<void> _openScanner() async {
    if (!mounted) return;
    try {
      // Recover a photo if Android restarted the activity while the camera
      // was open, before starting a new capture on entry to Scan Bill.
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        final recovered = await _picker.retrieveLostData();
        if (!mounted) return;
        if (recovered.exception != null) throw recovered.exception!;
        if (recovered.files?.isNotEmpty ?? false) {
          await _loadPhoto(recovered.files!.first);
          if (mounted) setState(() => _busy = false);
          return;
        }
      }
      if (!mounted) return;
      setState(() => _busy = false);
      if (_isMobile) await _pickPhoto(ImageSource.camera);
    } catch (error) {
      _handleError(error);
    }
  }

  Future<void> _pickPhoto(ImageSource source) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _errorCode = null;
    });
    try {
      final file = await _picker.pickImage(
        source: source,
        preferredCameraDevice: CameraDevice.rear,
        maxWidth: 2048,
        maxHeight: 3072,
        imageQuality: 90,
        requestFullMetadata: false,
      );
      if (!mounted) return;
      if (file != null) await _loadPhoto(file);
    } catch (error) {
      _handleError(error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _loadPhoto(XFile file) async {
    final bytes = await file.readAsBytes();
    final decoded = await decodeImageFromList(bytes);
    decoded.dispose();
    if (!mounted) return;
    setState(() {
      _photo = bytes;
      _photoFile = file;
      _scannedBill = null;
      _scanFailed = false;
      _errorCode = null;
      _photoDocumentId = LocalBillVault.newId();
      _savedToVault = false;
    });
    await _readBill();
  }

  Future<void> _readBill() async {
    final file = _photoFile;
    if (file == null || !_scanner.isSupported) return;
    setState(() {
      _readingBill = true;
      _scanFailed = false;
    });
    try {
      final result = await _scanner.scan(file);
      if (!mounted) return;
      setState(() => _scannedBill = result);
    } catch (_) {
      if (mounted) setState(() => _scanFailed = true);
    } finally {
      if (mounted) setState(() => _readingBill = false);
    }

    // A successful capture/gallery scan goes straight to its filled form.
    // Do this only once per recognition result, never from build(), so going
    // back to the photo does not immediately reopen the form.
    if (mounted &&
        !_scanFailed &&
        (_scannedBill?.fieldCount ?? 0) > 0 &&
        ModalRoute.of(context)?.isCurrent == true) {
      setState(() => _busy = false);
      await _enterDetails();
    }
  }

  void _handleError(Object error) {
    if (!mounted) return;
    setState(() {
      _busy = false;
      _errorCode = error is PlatformException ? error.code : 'capture_failed';
    });
  }

  String _errorMessage(bool hindi) {
    final code = _errorCode?.toLowerCase() ?? '';
    if (code == 'vault_save_failed') {
      return hindi
          ? 'फोटो सेव नहीं हो सकी। डिवाइस में खाली जगह जाँचें और फिर कोशिश करें। आपकी फोटो अभी यहाँ है।'
          : 'Could not save the photo. Check available storage and try again. Your photo is still here.';
    }
    if (code.contains('denied') || code.contains('restricted')) {
      return hindi
          ? 'कैमरा या फोटो की अनुमति नहीं मिली। फोन की Settings > Apps > MyDigi > Permissions में अनुमति देकर फिर कोशिश करें।'
          : 'Camera or photo access was denied. Allow access in Settings > Apps > MyDigi > Permissions, then try again.';
    }
    if (code.contains('no_available_camera') ||
        code.contains('not_supported')) {
      return hindi
          ? 'इस डिवाइस पर कैमरा उपलब्ध नहीं है। बिल की फोटो चुनें।'
          : 'A camera is not available on this device. Choose a bill photo instead.';
    }
    if (code.contains('already_active')) {
      return hindi
          ? 'कैमरा पहले से खुला है। उसे बंद करके फिर कोशिश करें।'
          : 'The camera is already open. Close it and try again.';
    }
    return hindi
        ? 'बिल की फोटो नहीं खुल सकी। फिर कोशिश करें या दूसरी फोटो चुनें।'
        : 'Could not open the bill photo. Try again or choose another photo.';
  }

  Future<void> _enterDetails() async {
    final photo = _photo;
    if (_busy || _readingBill || photo == null) return;
    setState(() => _busy = true);
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddProductScreen(
          billPhoto: photo,
          billDocumentId: _photoDocumentId,
          scannedBill: _scannedBill,
        ),
      ),
    );
    if (!mounted) return;
    if (saved == true) {
      Navigator.of(context).pop();
    } else {
      setState(() => _busy = false);
    }
  }

  Future<void> _saveToVault() async {
    final photo = _photo;
    if (_busy || photo == null) return;
    setState(() {
      _busy = true;
      _errorCode = null;
    });
    try {
      await context.read<WarrantyProvider>().saveBillPhoto(
        photo,
        documentId: _photoDocumentId,
      );
      if (!mounted) return;
      setState(() => _savedToVault = true);
      final hindi = context.read<WarrantyProvider>().language == 'hi';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            hindi
                ? 'बिल की फोटो वॉल्ट में सेव हो गई।'
                : 'Bill photo saved to your vault.',
          ),
        ),
      );
    } catch (_) {
      if (mounted) setState(() => _errorCode = 'vault_save_failed');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hindi = context.watch<WarrantyProvider>().language == 'hi';
    final photo = _photo;
    return Scaffold(
      appBar: AppBar(title: Text(hindi ? 'बिल स्कैन' : 'Scan Bill')),
      body: GlassScaffoldBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  photo == null
                      ? (hindi
                            ? 'बिल या इनवॉइस की साफ फोटो लें।'
                            : 'Take a clear photo of your bill or invoice.')
                      : (hindi
                            ? 'फोटो और बिल से पढ़ी गई जानकारी जाँचें।'
                            : 'Check the photo and review the details read from your bill.'),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GlassCard(
                    child: SizedBox.expand(
                      child: photo != null
                          ? InteractiveViewer(
                              minScale: 1,
                              maxScale: 5,
                              child: Center(
                                child: Image.memory(
                                  photo,
                                  key: const ValueKey('bill-photo-preview'),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            )
                          : Center(
                              child: _busy
                                  ? const CircularProgressIndicator()
                                  : Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.document_scanner_outlined,
                                          size: 64,
                                          color: AppTheme.primary,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          hindi
                                              ? 'बिल की फोटो लें या चुनें'
                                              : 'Capture or choose a bill photo',
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                            ),
                    ),
                  ),
                ),
                if (_errorCode != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage(hindi),
                    key: const ValueKey('camera-error'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (_isMobile || kIsWeb) ...[
                      Expanded(
                        child: OutlinedButton.icon(
                          key: const ValueKey('open-bill-camera'),
                          onPressed: _busy || _readingBill
                              ? null
                              : () => _pickPhoto(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt_outlined),
                          label: Text(
                            photo == null
                                ? (hindi ? 'कैमरा खोलें' : 'Open Camera')
                                : (hindi ? 'फिर फोटो लें' : 'Retake'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: OutlinedButton.icon(
                        key: const ValueKey('choose-bill-photo'),
                        onPressed: _busy || _readingBill
                            ? null
                            : () => _pickPhoto(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library_outlined),
                        label: Text(hindi ? 'फोटो चुनें' : 'Choose Photo'),
                      ),
                    ),
                  ],
                ),
                if (photo != null) ...[
                  const SizedBox(height: 8),
                  if (_readingBill) ...[
                    const LinearProgressIndicator(
                      key: ValueKey('bill-reading'),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      hindi
                          ? 'बिल से जानकारी पढ़ रहे हैं…'
                          : 'Reading your bill…',
                    ),
                  ] else ...[
                    Text(
                      _scanFailed
                          ? (hindi
                                ? 'बिल पढ़ा नहीं जा सका। फिर कोशिश करें या जानकारी खुद भरें।'
                                : 'Could not read the bill. Retry or enter the details manually.')
                          : ((_scannedBill?.fieldCount ?? 0) > 0
                                ? (hindi
                                      ? '${_scannedBill!.fieldCount} जानकारी मिलीं। सेव करने से पहले जाँचें।'
                                      : '${_scannedBill!.fieldCount} details found. Review them before saving.')
                                : (hindi
                                      ? 'जानकारी अपने आप नहीं मिली। फोटो देखकर खुद भरें।'
                                      : 'No details found automatically. Use the photo to fill in the fields.')),
                      key: const ValueKey('bill-scan-status'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12),
                    ),
                    if (_scanFailed)
                      TextButton(
                        key: const ValueKey('retry-bill-reading'),
                        onPressed: _busy ? null : _readBill,
                        child: Text(hindi ? 'फिर पढ़ें' : 'Retry Reading Bill'),
                      ),
                  ],
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    key: const ValueKey('enter-bill-details'),
                    onPressed: _busy || _readingBill ? null : _enterDetails,
                    icon: const Icon(Icons.edit_note),
                    label: Text(
                      (_scannedBill?.fieldCount ?? 0) > 0
                          ? (hindi
                                ? 'बिल की जानकारी जाँचें'
                                : 'Review Bill Details')
                          : (hindi
                                ? 'बिल की जानकारी भरें'
                                : 'Enter Bill Details'),
                    ),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                    ),
                  ),
                  const SizedBox(height: 4),
                  OutlinedButton.icon(
                    key: const ValueKey('save-bill-photo'),
                    onPressed: _busy || _readingBill
                        ? null
                        : (_savedToVault
                              ? () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const InvoiceVaultScreen(),
                                  ),
                                )
                              : _saveToVault),
                    icon: Icon(
                      _savedToVault ? Icons.folder_open : Icons.save_alt,
                    ),
                    label: Text(
                      _savedToVault
                          ? (hindi ? 'वॉल्ट खोलें' : 'Open Vault')
                          : (hindi
                                ? 'फोटो वॉल्ट में सेव करें'
                                : 'Save Photo to Vault'),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hindi ? 'इस डिवाइस पर सेव होगी।' : 'Saved on this device.',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
