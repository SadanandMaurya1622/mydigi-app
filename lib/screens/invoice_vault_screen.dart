import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/warranty_provider.dart';
import '../utils/app_theme.dart';
import '../utils/translations.dart';
import '../widgets/glass_container.dart';
import 'scanner_screen.dart';

class InvoiceVaultScreen extends StatefulWidget {
  const InvoiceVaultScreen({super.key});

  @override
  State<InvoiceVaultScreen> createState() => _InvoiceVaultScreenState();
}

class _InvoiceVaultScreenState extends State<InvoiceVaultScreen> {
  String _selectedType = 'All';

  final List<String> _types = [
    'All',
    'Invoice',
    'Warranty Card',
    'Insurance',
    'Manual',
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WarrantyProvider>(context);
    final lang = provider.language;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredDocs = _selectedType == 'All'
        ? provider.documents
        : provider.documents.where((d) => d.type == _selectedType).toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          AppTranslations.tr('vault', lang),
          style: AppTheme.font(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ScannerScreen()),
              );
            },
          ),
        ],
      ),
      body: GlassScaffoldBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Secure Cloud Vault Glass Banner
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: GlassCard(
                  borderRadius: 22,
                  padding: const EdgeInsets.all(16),
                  tintColor: const Color(0xFF1E293B),
                  isSolidGradient: true,
                  opacity: 0.88,
                  blur: 24,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withAlpha(50),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.lock_outline, color: AppTheme.secondary, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '256-Bit Encrypted Bill Vault',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5),
                            ),
                            Text(
                              '${provider.documents.length} Bills & Warranties safely archived in private cloud',
                              style: const TextStyle(color: Colors.white70, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Filter Glass Chips
              SizedBox(
                height: 42,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  itemCount: _types.length,
                  itemBuilder: (context, idx) {
                    final t = _types[idx];
                    final isSel = _selectedType == t;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedType = t),
                        child: GlassCard(
                          borderRadius: 14,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          opacity: isSel ? 0.9 : 0.6,
                          tintColor: isSel ? AppTheme.primary : null,
                          border: Border.all(
                            color: isSel ? AppTheme.primary : Colors.white.withAlpha(isDark ? 20 : 180),
                            width: 1.2,
                          ),
                          child: Text(
                            t,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                              color: isSel ? Colors.white : (isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),

              // Document Items List
              Expanded(
                child: filteredDocs.isEmpty
                    ? Center(
                        child: Text(
                          lang == 'en' ? 'No documents in this category' : 'कोई दस्तावेज़ नहीं मिला',
                          style: TextStyle(fontSize: 12, color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(left: 16, right: 16, top: 6, bottom: 100),
                        itemCount: filteredDocs.length,
                        itemBuilder: (context, idx) {
                          final doc = filteredDocs[idx];
                          return GlassCard(
                            margin: const EdgeInsets.only(bottom: 10),
                            borderRadius: 20,
                            padding: const EdgeInsets.all(14),
                            opacity: 0.82,
                            blur: 20,
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary.withAlpha(25),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(Icons.picture_as_pdf, color: AppTheme.primary, size: 24),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        doc.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        doc.productName,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${doc.size} • Uploaded ${doc.uploadDate}',
                                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.download_rounded, size: 20, color: AppTheme.primary),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Downloading ${doc.name} (PDF)...')),
                                    );
                                  },
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
        heroTag: 'fab_vault',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ScannerScreen()),
          );
        },
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_a_photo),
        label: const Text('Scan & Save Bill', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
