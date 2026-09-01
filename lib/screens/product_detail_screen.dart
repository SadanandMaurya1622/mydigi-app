import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/product_model.dart';
import '../providers/warranty_provider.dart';
import '../utils/app_theme.dart';
import '../utils/translations.dart';
import 'add_product_screen.dart';
import 'expenses_screen.dart';
import 'claims_screen.dart';
import 'invoice_vault_screen.dart';

class ProductDetailScreen extends StatelessWidget {
  final ProductItem product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WarrantyProvider>(context);
    final lang = provider.language;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Get current product state from provider (in case updated)
    final currentProduct = provider.products.firstWhere(
      (p) => p.id == product.id,
      orElse: () => product,
    );

    final productExpenses = provider.expenses
        .where((e) => e.productId == currentProduct.id)
        .toList();

    final productDocs = provider.documents
        .where((d) => d.productId == currentProduct.id)
        .toList();

    Color statusColor;
    if (currentProduct.warrantyStatus == 'Active') {
      statusColor = AppTheme.success;
    } else if (currentProduct.warrantyStatus == 'Expiring Soon') {
      statusColor = AppTheme.warning;
    } else {
      statusColor = AppTheme.danger;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          currentProduct.name,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: AppTranslations.tr('editProduct', lang),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddProductScreen(editingProduct: currentProduct),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppTheme.danger),
            tooltip: AppTranslations.tr('deleteProduct', lang),
            onPressed: () {
              _showDeleteConfirmDialog(context, provider, currentProduct, lang);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image Card
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.network(
                    currentProduct.imageUrl,
                    width: double.infinity,
                    height: 210,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: double.infinity,
                      height: 210,
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                      child: const Icon(Icons.image_outlined, size: 48, color: Colors.grey),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: statusColor.withAlpha(100),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      currentProduct.warrantyStatus,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(165),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      currentProduct.category,
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Product Name & Brand Row
            Text(
              currentProduct.name,
              style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '${currentProduct.brand} • Model: ${currentProduct.modelNumber} • Serial: ${currentProduct.serialNumber}',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
              ),
            ),
            const SizedBox(height: 16),

            // Total Cost of Ownership (TCO) Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFC7D2FE),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppTranslations.tr('costOfOwnership', lang),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Text(
                            lang == 'en' ? 'Purchase + Service + Maintenance + AMC' : 'खरीद + सर्विस + मेंटेनेंस + AMC',
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '₹${currentProduct.totalCostOfOwnership.toInt()}',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  // Breakdown Row
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _buildTcoPill('Purchase', '₹${currentProduct.purchasePrice.toInt()}', isDark),
                      _buildTcoPill('Maintenance', '₹${currentProduct.costBreakdown.maintenance.toInt()}', isDark),
                      _buildTcoPill('Repair', '₹${currentProduct.costBreakdown.repair.toInt()}', isDark),
                      _buildTcoPill('AMC', '₹${currentProduct.costBreakdown.amc.toInt()}', isDark),
                      _buildTcoPill('Accessories', '₹${currentProduct.costBreakdown.accessories.toInt()}', isDark),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Quick Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ExpensesScreen(filterProductId: currentProduct.id),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add, size: 16),
                    label: Text(
                      AppTranslations.tr('addServiceLog', lang),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ClaimsScreen(preselectedProductId: currentProduct.id),
                        ),
                      );
                    },
                    icon: const Icon(Icons.shield_outlined, size: 16),
                    label: Text(
                      AppTranslations.tr('claimWarranty', lang),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: AppTheme.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Specifications & Warranty Grid
            Text(
              'Warranty & Purchase Details',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : AppTheme.borderLight,
                ),
              ),
              child: Column(
                children: [
                  _buildDetailRow('Warranty Period', currentProduct.warrantyPeriod, isDark),
                  const Divider(height: 16),
                  _buildDetailRow('Warranty End Date', currentProduct.warrantyEndDate, isDark),
                  const Divider(height: 16),
                  _buildDetailRow(
                    'Days Remaining',
                    '${currentProduct.daysRemaining} days left',
                    isDark,
                    highlightColor: statusColor,
                  ),
                  const Divider(height: 16),
                  _buildDetailRow('Purchase Date', currentProduct.purchaseDate, isDark),
                  const Divider(height: 16),
                  _buildDetailRow('Purchase Price', '₹${currentProduct.purchasePrice.toInt()}', isDark),
                  const Divider(height: 16),
                  _buildDetailRow('Invoice Number', currentProduct.invoiceNumber, isDark),
                  const Divider(height: 16),
                  _buildDetailRow('Seller / Store', currentProduct.sellerName, isDark),
                  if (currentProduct.sellerContact.isNotEmpty) ...[
                    const Divider(height: 16),
                    _buildDetailRow('Seller Contact', currentProduct.sellerContact, isDark),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // QR Code Asset Passport Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : AppTheme.borderLight,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppTranslations.tr('qrPassport', lang),
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withAlpha(25),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Verified Digital ID',
                          style: TextStyle(color: AppTheme.primary, fontSize: 9.5, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(20),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: QrImageView(
                        data: 'https://mydigi.app/verify/${currentProduct.id}?serial=${currentProduct.serialNumber}',
                        version: QrVersions.auto,
                        size: 150.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    AppTranslations.tr('qrPassportSub', lang),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Service & Expense History Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppTranslations.tr('expenseHistory', lang),
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  '${productExpenses.length} logs',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (productExpenses.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    lang == 'en' ? 'No service or repair expenses logged yet' : 'कोई खर्च रिकॉर्ड नहीं मिला',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                    ),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: productExpenses.length,
                itemBuilder: (context, idx) {
                  final exp = productExpenses[idx];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : AppTheme.borderLight,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              exp.category,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                            ),
                            Text(
                              '${exp.date} • ${exp.serviceProvider}',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '₹${exp.amount.toInt()}',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppTheme.danger,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: 20),

            // Attached Documents & Invoices Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppTranslations.tr('attachedDocs', lang),
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const InvoiceVaultScreen()),
                    );
                  },
                  child: Text(
                    AppTranslations.tr('viewAll', lang),
                    style: const TextStyle(fontSize: 12, color: AppTheme.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (productDocs.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    lang == 'en' ? 'No invoices attached' : 'कोई बिल संलग्न नहीं है',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                    ),
                  ),
                ),
              )
            else
              ...productDocs.map(
                (doc) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : AppTheme.borderLight,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withAlpha(25),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.picture_as_pdf, color: AppTheme.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doc.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${doc.type} • ${doc.size} • ${doc.uploadDate}',
                              style: TextStyle(
                                fontSize: 10.5,
                                color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.download_rounded, size: 20, color: AppTheme.primary),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Downloading ${doc.name}...'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildTcoPill(String label, String value, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white70 : AppTheme.textMainLight,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark, {Color? highlightColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: highlightColor ?? (isDark ? Colors.white : AppTheme.textMainLight),
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmDialog(
    BuildContext context,
    WarrantyProvider provider,
    ProductItem prod,
    String lang,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(lang == 'en' ? 'Delete Product?' : 'प्रोडक्ट हटाएं?'),
        content: Text(
          lang == 'en'
              ? 'Are you sure you want to delete "${prod.name}" and all associated expenses and documents?'
              : 'क्या आप "${prod.name}" और उससे जुड़े सभी खर्चे व बिल हटाना चाहते हैं?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppTranslations.tr('cancel', lang)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            onPressed: () {
              provider.deleteProduct(prod.id);
              Navigator.pop(ctx); // close dialog
              Navigator.pop(context); // close details screen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(lang == 'en' ? 'Product deleted' : 'प्रोडक्ट हटा दिया गया'),
                  backgroundColor: AppTheme.danger,
                ),
              );
            },
            child: Text(
              AppTranslations.tr('deleteProduct', lang),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
