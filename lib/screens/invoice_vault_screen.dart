import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/product_model.dart';
import '../providers/warranty_provider.dart';
import '../utils/app_theme.dart';
import '../utils/translations.dart';
import '../widgets/glass_container.dart';
import 'document_preview_screen.dart';
import 'scanner_screen.dart';

class InvoiceVaultScreen extends StatefulWidget {
  const InvoiceVaultScreen({super.key});

  @override
  State<InvoiceVaultScreen> createState() => _InvoiceVaultScreenState();
}

class _InvoiceVaultScreenState extends State<InvoiceVaultScreen> {
  String _selectedType = 'All';
  bool _loading = true;
  bool _loadFailed = false;
  static const _types = [
    'All',
    'Invoice',
    'Warranty Card',
    'Insurance',
    'Manual',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _loadFailed = false;
    });
    try {
      await context.read<WarrantyProvider>().loadLocalBills();
    } catch (_) {
      if (mounted) setState(() => _loadFailed = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _open(DocumentRecord document) => Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => DocumentPreviewScreen(document: document),
    ),
  );

  String _date(String value) {
    final date = DateTime.tryParse(value);
    return date == null
        ? value
        : DateFormat('dd MMM yyyy, h:mm a').format(date.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WarrantyProvider>();
    final hindi = provider.language == 'hi';
    final docs = provider.documents
        .where((doc) => _selectedType == 'All' || doc.type == _selectedType)
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.tr('vault', provider.language)),
        actions: [
          IconButton(
            tooltip: hindi ? 'फिर लोड करें' : 'Refresh vault',
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: GlassScaffoldBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: GlassCard(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.folder_copy_outlined,
                        color: AppTheme.primary,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hindi ? 'बिल और दस्तावेज़' : 'Bills & documents',
                              style: AppTheme.font(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              hindi
                                  ? 'स्कैन की गई फोटो इस डिवाइस पर सेव होती हैं। फोटो देखने के लिए बिल पर टैप करें।'
                                  : 'Scanned photos are saved on this device. Tap a bill to view its photo.',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 44,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: _types.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) => ChoiceChip(
                    label: Text(_types[index]),
                    selected: _selectedType == _types[index],
                    onSelected: (_) =>
                        setState(() => _selectedType = _types[index]),
                  ),
                ),
              ),
              if (_loadFailed)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: TextButton.icon(
                    key: const ValueKey('retry-vault-load'),
                    onPressed: _load,
                    icon: const Icon(Icons.refresh),
                    label: Text(
                      hindi
                          ? 'सेव किए गए बिल नहीं खुले। फिर कोशिश करें।'
                          : 'Could not load saved bills. Try again.',
                    ),
                  ),
                ),
              if (_loading) const LinearProgressIndicator(),
              Expanded(
                child: docs.isEmpty
                    ? Center(
                        child: Text(
                          hindi
                              ? 'अभी कोई बिल नहीं है।'
                              : 'No bills saved yet.',
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final doc = docs[index];
                          return GlassCard(
                            key: ValueKey('vault-document-${doc.id}'),
                            margin: const EdgeInsets.only(bottom: 12),
                            onTap: () => _open(doc),
                            child: Row(
                              children: [
                                Icon(
                                  doc.isLocal
                                      ? Icons.receipt_long
                                      : Icons.description_outlined,
                                  color: AppTheme.primary,
                                  size: 30,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        doc.name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        doc.productName,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      Text(
                                        '${doc.size} • ${_date(doc.uploadDate)}',
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                      if (doc.isLocal)
                                        Text(
                                          hindi
                                              ? 'इस डिवाइस पर सेव है'
                                              : 'Saved on this device',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppTheme.primary,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  tooltip: hindi ? 'बिल खोलें' : 'View bill',
                                  onPressed: () => _open(doc),
                                  icon: const Icon(
                                    Icons.open_in_full,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const ScannerScreen())),
        icon: const Icon(Icons.add_a_photo),
        label: Text(hindi ? 'बिल स्कैन करें' : 'Scan & Save Bill'),
      ),
    );
  }
}
