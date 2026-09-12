import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/product_model.dart';
import '../providers/warranty_provider.dart';

class DocumentPreviewScreen extends StatefulWidget {
  const DocumentPreviewScreen({super.key, required this.document});

  final DocumentRecord document;

  @override
  State<DocumentPreviewScreen> createState() => _DocumentPreviewScreenState();
}

class _DocumentPreviewScreenState extends State<DocumentPreviewScreen> {
  Future<Uint8List>? _photo;
  late final String _owner;

  @override
  void initState() {
    super.initState();
    final provider = context.read<WarrantyProvider>();
    _owner = provider.vaultOwner;
    if (widget.document.isLocal) {
      _photo = provider.readBillPhoto(widget.document);
    }
  }

  Widget _unavailable(bool hindi, {bool retry = false}) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.image_not_supported_outlined,
            color: Colors.white70,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            hindi
                ? 'इस रिकॉर्ड की फोटो उपलब्ध नहीं है।'
                : 'No photo is available for this record.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
          if (retry)
            TextButton(
              onPressed: () => setState(() {
                _photo = context.read<WarrantyProvider>().readBillPhoto(
                  widget.document,
                );
              }),
              child: Text(hindi ? 'फिर कोशिश करें' : 'Try Again'),
            ),
        ],
      ),
    ),
  );

  Widget _zoom(Widget image) =>
      InteractiveViewer(minScale: 1, maxScale: 8, child: Center(child: image));

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WarrantyProvider>();
    final hindi = provider.language == 'hi';
    final document = widget.document;
    final url = Uri.tryParse(document.previewUrl ?? '');
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(document.name, style: const TextStyle(fontSize: 15)),
      ),
      body: SafeArea(
        child: provider.vaultOwner != _owner
            ? _unavailable(hindi)
            : document.isLocal
            ? FutureBuilder<Uint8List>(
                future: _photo,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return _unavailable(hindi, retry: true);
                  }
                  return _zoom(
                    Image.memory(
                      snapshot.data!,
                      key: const ValueKey('saved-bill-photo'),
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => _unavailable(hindi),
                    ),
                  );
                },
              )
            : (url?.scheme == 'https' && url!.host.isNotEmpty)
            ? _zoom(
                Image.network(
                  url.toString(),
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => _unavailable(hindi),
                ),
              )
            : _unavailable(hindi),
      ),
    );
  }
}
