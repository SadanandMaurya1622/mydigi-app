import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/product_model.dart';
import '../providers/warranty_provider.dart';
import '../utils/app_theme.dart';
import '../utils/translations.dart';
import '../widgets/glass_container.dart';
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
    final isHindi = lang == 'hi';

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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          currentProduct.name,
          style: AppTheme.font(fontWeight: FontWeight.bold, fontSize: 16),
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
      body: GlassScaffoldBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Hero Image Card with Glassy Overlays
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

                // 2. Product Name & Brand Info
                Text(
                  currentProduct.name,
                  style: AppTheme.font(fontSize: 20, fontWeight: FontWeight.bold),
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

                // 3. Glassy Total Cost of Ownership (TCO) Card
                GlassCard(
                  borderRadius: 22,
                  padding: const EdgeInsets.all(16),
                  tintColor: const Color(0xFF6366F1),
                  opacity: 0.86,
                  blur: 24,
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
                                isHindi ? 'खरीद + सर्विस + मेंटेनेंस + AMC' : 'Purchase + Service + Maintenance + AMC',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '₹${currentProduct.totalCostOfOwnership.toInt()}',
                            style: AppTheme.font(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Divider(height: 1, color: isDark ? Colors.white.withAlpha(20) : Colors.black.withAlpha(15)),
                      const SizedBox(height: 12),
                      // Breakdown Row
                      Wrap(
                        spacing: 10,
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
                const SizedBox(height: 16),

                // 4. Quick Action Buttons
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
                              builder: (_) => const ClaimsScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.shield_outlined, size: 16),
                        label: Text(
                          AppTranslations.tr('claimWarranty', lang),
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primary,
                          side: const BorderSide(color: AppTheme.primary),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 5. Glassy Purchase & Warranty Specs Card
                GlassCard(
                  borderRadius: 22,
                  padding: const EdgeInsets.all(16),
                  opacity: 0.82,
                  blur: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Warranty & Invoice Details',
                        style: AppTheme.font(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow('Warranty Period', currentProduct.warrantyPeriod, isDark),
                      const Divider(height: 16),
                      _buildDetailRow('Warranty End Date', currentProduct.warrantyEndDate, isDark),
                      const Divider(height: 16),
                      _buildDetailRow('Days Remaining', '${currentProduct.daysRemaining} days', isDark, valueColor: statusColor),
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
                const SizedBox(height: 16),

                // 6. QR Code Asset Passport Section
                GlassCard(
                  borderRadius: 22,
                  padding: const EdgeInsets.all(16),
                  opacity: 0.82,
                  blur: 24,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppTranslations.tr('qrPassport', lang),
                            style: AppTheme.font(fontWeight: FontWeight.bold, fontSize: 14),
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
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(30),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: QrImageView(
                            data: 'MYDIGI:${currentProduct.id}:${currentProduct.serialNumber}',
                            version: QrVersions.auto,
                            size: 140.0,
                            eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: AppTheme.primary),
                            dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: AppTheme.primary),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Show this QR code to authorized service technician for instant warranty validation.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10.5,
                          color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 7. Attached Documents Section
                GlassCard(
                  borderRadius: 22,
                  padding: const EdgeInsets.all(16),
                  opacity: 0.82,
                  blur: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppTranslations.tr('attachedDocs', lang),
                            style: AppTheme.font(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const InvoiceVaultScreen()),
                              );
                            },
                            child: const Text('Open Vault', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (productDocs.isEmpty)
                        Text(
                          'No documents attached yet. Invoices from bill scans will appear here.',
                          style: TextStyle(fontSize: 11, color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight),
                        )
                      else
                        ...productDocs.map(
                          (doc) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isDark ? const Color(0xFF334155) : AppTheme.borderLight),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.picture_as_pdf, color: AppTheme.danger, size: 22),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(doc.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                      Text('${doc.size} • Uploaded ${doc.uploadDate}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.download, size: 18),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Downloading ${doc.name}...')),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 8. Expense & Maintenance History
                GlassCard(
                  borderRadius: 22,
                  padding: const EdgeInsets.all(16),
                  opacity: 0.82,
                  blur: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppTranslations.tr('expenseHistory', lang),
                        style: AppTheme.font(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 10),
                      if (productExpenses.isEmpty)
                        Text(
                          'No maintenance or service logs recorded for this product yet.',
                          style: TextStyle(fontSize: 11, color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight),
                        )
                      else
                        ...productExpenses.map(
                          (exp) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${exp.category} (${exp.serviceProvider})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                    Text(exp.date, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                  ],
                                ),
                                Text(
                                  '₹${exp.amount.toInt()}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.danger),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTcoPill(String title, String amount, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF334155) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? const Color(0xFF475569) : AppTheme.borderLight,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$title: ', style: const TextStyle(fontSize: 10, color: Colors.grey)),
          Text(amount, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark, {Color? valueColor}) {
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
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: valueColor ?? (isDark ? Colors.white : AppTheme.textMainLight),
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, WarrantyProvider provider, ProductItem product, String lang) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Product?'),
        content: Text('Are you sure you want to remove ${product.name}? All attached invoices and warranty logs will be archived.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteProduct(product.id);
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Go back to products list
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Product deleted successfully')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
