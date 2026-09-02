import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/warranty_provider.dart';
import '../utils/app_theme.dart';
import '../utils/translations.dart';
import '../widgets/glass_container.dart';
import 'product_detail_screen.dart';
import 'add_product_screen.dart';
import 'scanner_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedStatus = 'All';

  final List<String> _categories = [
    'All',
    'Electronics',
    'Appliances',
    'Vehicle',
    'Gadgets',
    'Furniture',
    'Other',
  ];

  final List<String> _statuses = ['All', 'Active', 'Expiring Soon', 'Expired'];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WarrantyProvider>(context);
    final lang = provider.language;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isHindi = lang == 'hi';

    // Filter products
    final filteredProducts = provider.products.where((p) {
      final matchesQuery = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.brand.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.modelNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.serialNumber.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory =
          _selectedCategory == 'All' || p.category.toLowerCase() == _selectedCategory.toLowerCase();

      final matchesStatus = _selectedStatus == 'All' || p.warrantyStatus == _selectedStatus;

      return matchesQuery && matchesCategory && matchesStatus;
    }).toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          isHindi ? 'सभी सुरक्षित प्रोडक्ट्स' : 'Protected Products',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
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
          const SizedBox(width: 8),
        ],
      ),
      body: GlassScaffoldBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Glassy Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: GlassCard(
                  borderRadius: 18,
                  padding: EdgeInsets.zero,
                  opacity: 0.82,
                  blur: 20,
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: isHindi ? 'ब्रांड, मॉडल, सीरियल से खोजें...' : 'Search by name, brand, model...',
                      hintStyle: TextStyle(
                        fontSize: 12.5,
                        color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                      ),
                      prefixIcon: const Icon(Icons.search, size: 20, color: AppTheme.primary),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () => setState(() => _searchQuery = ''),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
              ),

              // Categories Horizontal Glassy Scroll
              SizedBox(
                height: 44,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedCategory = cat),
                        child: GlassCard(
                          borderRadius: 14,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          opacity: isSelected ? 0.9 : 0.6,
                          tintColor: isSelected ? AppTheme.primary : null,
                          border: Border.all(
                            color: isSelected ? AppTheme.primary : Colors.white.withAlpha(isDark ? 20 : 180),
                            width: 1.2,
                          ),
                          child: Text(
                            cat,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Colors.white : (isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 6),

              // Status Filter Tabs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: _statuses.map((st) {
                    final isSelected = _selectedStatus == st;
                    Color statusBadgeColor = AppTheme.primary;
                    if (st == 'Active') statusBadgeColor = AppTheme.success;
                    if (st == 'Expiring Soon') statusBadgeColor = AppTheme.warning;
                    if (st == 'Expired') statusBadgeColor = AppTheme.danger;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedStatus = st),
                        child: GlassCard(
                          borderRadius: 12,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          opacity: isSelected ? 0.88 : 0.5,
                          tintColor: isSelected ? statusBadgeColor : null,
                          border: Border.all(
                            color: isSelected ? statusBadgeColor : Colors.white.withAlpha(isDark ? 15 : 140),
                            width: 1.2,
                          ),
                          child: Text(
                            st,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),

              // Product List
              Expanded(
                child: filteredProducts.isEmpty
                    ? Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                provider.products.isEmpty ? Icons.inventory_2_outlined : Icons.search_off_rounded,
                                size: 56,
                                color: AppTheme.primary.withAlpha(180),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                provider.products.isEmpty
                                    ? (isHindi ? 'कोई प्रोडक्ट सेव नहीं है' : 'No Products Saved Yet')
                                    : (isHindi ? 'कोई प्रोडक्ट नहीं मिला' : 'No matching products found'),
                                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                provider.products.isEmpty
                                    ? (isHindi
                                        ? 'अपना पहला प्रोडक्ट जोड़ें और Firebase Cloud में सुरक्षित करें।'
                                        : 'Add your first product to sync with Firebase Cloud.')
                                    : (isHindi ? 'सर्च टर्म या फिल्टर बदलकर देखें' : 'Try changing filters or search terms'),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                                ),
                              ),
                              if (provider.products.isEmpty) ...[
                                const SizedBox(height: 18),
                                ElevatedButton.icon(
                                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductScreen())),
                                  icon: const Icon(Icons.add_rounded, size: 18),
                                  label: Text(
                                    isHindi ? '+ नया प्रोडक्ट जोड़ें' : '+ Add Product',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 100),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          return _buildProductCard(context, product, lang, isDark, isHindi);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_products',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddProductScreen()),
          );
        },
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(
          AppTranslations.tr('addProduct', lang),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    ProductItem product,
    String lang,
    bool isDark,
    bool isHindi,
  ) {
    Color statusColor;
    String statusText;
    if (product.warrantyStatus == 'Active') {
      statusColor = AppTheme.success;
      statusText = isHindi ? 'सक्रिय (Active)' : 'Active';
    } else if (product.warrantyStatus == 'Expiring Soon') {
      statusColor = AppTheme.warning;
      statusText = isHindi ? '7 दिन शेष' : 'Expiring Soon';
    } else {
      statusColor = AppTheme.danger;
      statusText = isHindi ? 'समाप्त (Expired)' : 'Expired';
    }

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      borderRadius: 22,
      padding: const EdgeInsets.all(14),
      opacity: 0.82,
      blur: 24,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  product.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 80,
                    height: 80,
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    child: const Icon(Icons.devices_other_rounded, color: Colors.grey, size: 32),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: statusColor.withAlpha(30),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${product.brand} • ${product.category}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₹${product.purchasePrice.toInt()}',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                            color: AppTheme.primary,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.schedule, size: 12, color: statusColor),
                            const SizedBox(width: 4),
                            Text(
                              product.daysRemaining > 0
                                  ? '${product.daysRemaining} ${isHindi ? 'दिन बचे हैं' : 'Days Left'}'
                                  : (isHindi ? 'समाप्त' : 'Expired'),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(
            height: 1,
            thickness: 0.8,
            color: isDark ? Colors.white.withAlpha(20) : Colors.black.withAlpha(15),
          ),
          const SizedBox(height: 8),

          // Lower quick specs row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.qr_code, size: 13, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    product.serialNumber,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.receipt_long, size: 13, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'TCO: ₹${product.totalCostOfOwnership.toInt()}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
