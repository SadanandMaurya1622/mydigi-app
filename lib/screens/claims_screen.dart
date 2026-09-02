import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/warranty_provider.dart';
import '../utils/app_theme.dart';
import '../utils/translations.dart';
import '../widgets/glass_container.dart';

class ClaimsScreen extends StatefulWidget {
  final String? preselectedProductId;

  const ClaimsScreen({super.key, this.preselectedProductId});

  @override
  State<ClaimsScreen> createState() => _ClaimsScreenState();
}

class _ClaimsScreenState extends State<ClaimsScreen> {
  void _showNewClaimModal(BuildContext context, WarrantyProvider provider, String lang, bool isDark) {
    final validProductIds = provider.products.map((p) => p.id).toSet();
    String? selectedProdId = (widget.preselectedProductId != null && validProductIds.contains(widget.preselectedProductId))
        ? widget.preselectedProductId
        : (provider.products.isNotEmpty ? provider.products.first.id : null);
    final descController = TextEditingController();
    final serviceCenterController = TextEditingController(text: 'Authorized Brand Service Center');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) => SafeArea(
          child: GlassCard(
            borderRadius: 28,
            opacity: 0.92,
            blur: 28,
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(modalCtx).viewInsets.bottom,
            ),
            padding: const EdgeInsets.all(22),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppTranslations.tr('claimWarranty', lang),
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(modalCtx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Product Picker
                  const Text('Select Product for Claim *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: validProductIds.contains(selectedProdId) ? selectedProdId : (provider.products.isNotEmpty ? provider.products.first.id : null),
                        isExpanded: true,
                        items: provider.products
                            .map((p) => DropdownMenuItem(
                                  value: p.id,
                                  child: Text('${p.name} (${p.brand})', style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setModalState(() => selectedProdId = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Issue Description
                  const Text('Issue / Breakdown Description *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: descController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'e.g. Display backlight flickering, abnormal noise during operation',
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Service Center Name
                  const Text('Service Center / Channel', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: serviceCenterController,
                    decoration: InputDecoration(
                      hintText: 'Brand Authorized Care',
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Submit Button
                  ElevatedButton(
                    onPressed: () {
                      if (selectedProdId == null || selectedProdId!.isEmpty || descController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select a product and write the issue description')),
                        );
                        return;
                      }

                      final prod = provider.products.firstWhere(
                        (p) => p.id == selectedProdId,
                        orElse: () => provider.products.first,
                      );
                      final ticketNo = 'CLM-${1000 + provider.claims.length + 1}';

                      final newClaim = WarrantyClaim(
                        id: 'clm-${DateTime.now().millisecondsSinceEpoch}',
                        productId: selectedProdId!,
                        productName: prod.name,
                        ticketNumber: ticketNo,
                        description: descController.text.trim(),
                        claimDate: '01 Sep 2026',
                        status: 'Submitted',
                        serviceCenter: serviceCenterController.text,
                      );

                      provider.addClaim(newClaim);
                      Navigator.pop(modalCtx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('✨ Claim ticket $ticketNo generated!'),
                        backgroundColor: AppTheme.success,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Submit Warranty Claim', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WarrantyProvider>(context);
    final lang = provider.language;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          AppTranslations.tr('claims', lang),
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: GlassScaffoldBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Claims Header Glass Card
                GlassCard(
                  borderRadius: 22,
                  padding: const EdgeInsets.all(16),
                  tintColor: const Color(0xFFEC4899),
                  opacity: 0.88,
                  blur: 24,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(50),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.shield_outlined, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Hassle-Free OEM Warranty Claims',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text(
                              'Direct ticket routing with authorized brand service networks across India',
                              style: TextStyle(color: Colors.white70, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  'Active & Recent Claims (${provider.claims.length})',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),

                if (provider.claims.isEmpty)
                  GlassCard(
                    borderRadius: 20,
                    padding: const EdgeInsets.all(28),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.assignment_turned_in_outlined, size: 48, color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight),
                          const SizedBox(height: 12),
                          const Text('No warranty claims filed yet', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          const Text('Tap "File New Claim" below to request service from the manufacturer.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                  )
                else
                  ...provider.claims.map((clm) {
                    Color statusCol = AppTheme.warning;
                    if (clm.status == 'Approved' || clm.status == 'Resolved') statusCol = AppTheme.success;
                    if (clm.status == 'Rejected') statusCol = AppTheme.danger;

                    return GlassCard(
                      margin: const EdgeInsets.only(bottom: 12),
                      borderRadius: 20,
                      padding: const EdgeInsets.all(16),
                      opacity: 0.82,
                      blur: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(clm.ticketNumber, style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 15, color: AppTheme.primary)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusCol.withAlpha(30),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(clm.status, style: TextStyle(color: statusCol, fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(clm.productName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                          const SizedBox(height: 4),
                          Text(clm.description, style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.black87)),
                          const SizedBox(height: 10),
                          Divider(height: 1, color: isDark ? Colors.white.withAlpha(15) : Colors.black.withAlpha(10)),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.storefront_outlined, size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(clm.serviceCenter, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                ],
                              ),
                              Text(clm.claimDate, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_claims',
        onPressed: () => _showNewClaimModal(context, provider, lang, isDark),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('File New Claim', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
