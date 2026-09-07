import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/warranty_provider.dart';
import '../utils/app_theme.dart';
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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedStatus = 'All';

  final List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'hi': 'सभी', 'icon': Icons.grid_view_rounded},
    {'name': 'Electronics', 'hi': 'इलेक्ट्रॉनिक्स', 'icon': Icons.laptop_chromebook_rounded},
    {'name': 'Appliances', 'hi': 'उपकरण (TV/AC/Fridge)', 'icon': Icons.kitchen_rounded},
    {'name': 'Gadgets', 'hi': 'मोबाइल व गैजेट्स', 'icon': Icons.smartphone_rounded},
    {'name': 'Vehicle', 'hi': 'गाड़ी / बाइक', 'icon': Icons.directions_car_rounded},
    {'name': 'Furniture', 'hi': 'फर्नीचर', 'icon': Icons.chair_rounded},
    {'name': 'Other', 'hi': 'अन्य सामान', 'icon': Icons.devices_other_rounded},
  ];

  final List<Map<String, dynamic>> _statuses = [
    {'key': 'All', 'name': 'All', 'hi': 'सभी'},
    {'key': 'Active', 'name': 'Active', 'hi': '🟢 सुरक्षित'},
    {'key': 'Expired', 'name': 'Expired', 'hi': '🔴 समाप्त'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _confirmDeleteProduct(BuildContext context, WarrantyProvider provider, ProductItem product, bool isHindi) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isHindi ? 'सामान हटाएं?' : 'Remove Item?',
          style: AppTheme.font(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        content: Text(
          isHindi
              ? 'क्या आप वास्तव में "${product.name}" को अपनी लिस्ट से हटाना चाहते हैं?'
              : 'Are you sure you want to remove "${product.name}" from your saved items?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isHindi ? 'रद्द करें' : 'Cancel', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              provider.deleteProduct(product.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isHindi ? 'सामान हटा दिया गया' : 'Item removed successfully'),
                  backgroundColor: AppTheme.danger,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(isHindi ? 'हटाएं' : 'Delete', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WarrantyProvider>(context);
    final lang = provider.language;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isHindi = lang == 'hi';

    final allProducts = provider.products;

    // Filter Logic
    final filtered = allProducts.where((p) {
      final matchesQuery = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.brand.toLowerCase().contains(_searchQuery.toLowerCase());

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isHindi ? 'मेरे सभी सामान' : 'My Saved Items',
              style: AppTheme.font(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            Text(
              '${allProducts.length} ${isHindi ? 'आइटम्स सुरक्षित' : 'items protected'}',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded, size: 22, color: AppTheme.primary),
            tooltip: isHindi ? 'स्कैन करें' : 'Scan',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ScannerScreen()));
            },
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppTheme.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_rounded, size: 18, color: Colors.white),
            ),
            tooltip: isHindi ? 'नया सामान जोड़ें' : 'Add Item',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductScreen()));
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: GlassScaffoldBackground(
        child: SafeArea(
          child: Column(
            children: [
              // 1. SIMPLE SEARCH BAR
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      fontFamilyFallback: AppTheme.fontFallbacks,
                    ),
                    decoration: InputDecoration(
                      hintText: isHindi ? 'नाम या ब्रांड से खोजें...' : 'Search by name or brand...',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppTheme.textHintDark : AppTheme.textHintLight,
                        fontFamilyFallback: AppTheme.fontFallbacks,
                      ),
                      prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppTheme.primary),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                ),
              ),

              // 2. CATEGORY HORIZONTAL CHIPS
              SizedBox(
                height: 38,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  itemCount: _categories.length,
                  itemBuilder: (context, idx) {
                    final cat = _categories[idx];
                    final catName = cat['name'] as String;
                    final isSelected = _selectedCategory == catName;
                    final label = isHindi ? cat['hi'] as String : catName;
                    final icon = cat['icon'] as IconData;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedCategory = catName);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primary
                                : (isDark ? const Color(0xFF1E293B) : Colors.white),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.primary
                                  : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(icon, size: 14, color: isSelected ? Colors.white : AppTheme.primary),
                              const SizedBox(width: 5),
                              Text(
                                label,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                  color: isSelected ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF334155)),
                                  fontFamilyFallback: AppTheme.fontFallbacks,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),

              // 3. STATUS FILTER PILLS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: _statuses.map((st) {
                    final key = st['key'] as String;
                    final isSelected = _selectedStatus == key;
                    final label = isHindi ? st['hi'] as String : st['name'] as String;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedStatus = key);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.primary
                                  : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                            ),
                          ),
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              color: isDark ? Colors.white : const Color(0xFF1E293B),
                              fontFamilyFallback: AppTheme.fontFallbacks,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 10),

              // 4. PRODUCT LIST
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.inventory_2_outlined, size: 48, color: AppTheme.primary),
                              const SizedBox(height: 12),
                              Text(
                                allProducts.isEmpty
                                    ? (isHindi ? 'कोई सामान सेव नहीं है' : 'No items saved yet')
                                    : (isHindi ? 'कोई सामान नहीं मिला' : 'No matching items found'),
                                style: AppTheme.font(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                allProducts.isEmpty
                                    ? (isHindi
                                        ? 'अपना पहला सामान जोड़ें और वारंटी ट्रैक करें।'
                                        : 'Add your first product to start tracking warranty.')
                                    : (isHindi ? 'सर्च या फ़िल्टर बदलकर देखें' : 'Try searching with different terms'),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                                ),
                              ),
                              if (allProducts.isEmpty) ...[
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductScreen()));
                                  },
                                  icon: const Icon(Icons.add_rounded, size: 18),
                                  label: Text(isHindi ? 'सामान जोड़ें' : 'Add First Item', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 4,
                          bottom: MediaQuery.of(context).padding.bottom + 150,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, idx) {
                          final product = filtered[idx];
                          return _buildEasyProductCard(context, provider, product, isDark, isHindi);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton.extended(
          heroTag: 'fab_products_simple',
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductScreen()));
          },
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          icon: const Icon(Icons.add_rounded, size: 20),
          label: Text(
            isHindi ? 'नया सामान जोड़ें' : 'Add Item',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // EASY & CLEAR PRODUCT CARD
  // -------------------------------------------------------------
  Widget _buildEasyProductCard(
    BuildContext context,
    WarrantyProvider provider,
    ProductItem product,
    bool isDark,
    bool isHindi,
  ) {
    Color statusColor;
    String statusText;

    if (product.warrantyStatus == 'Active') {
      statusColor = const Color(0xFF10B981);
      statusText = product.daysRemaining > 0
          ? (isHindi ? 'सुरक्षित • ${product.daysRemaining} दिन बाकी' : 'Active • ${product.daysRemaining}d left')
          : (isHindi ? 'वारंटी सक्रिय' : 'Active Warranty');
    } else if (product.warrantyStatus == 'Expiring Soon') {
      statusColor = const Color(0xFFF59E0B);
      statusText = isHindi ? 'जल्द समाप्त (${product.daysRemaining} दिन)' : 'Expires Soon (${product.daysRemaining}d)';
    } else {
      statusColor = const Color(0xFFE11D48);
      statusText = isHindi ? 'वारंटी समाप्त' : 'Warranty Expired';
    }

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 25 : 6),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 72,
                height: 72,
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                    child: const Icon(Icons.devices_other_rounded, color: AppTheme.primary, size: 30),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.brand.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.font(
                      fontWeight: FontWeight.w800,
                      fontSize: 14.5,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Price & Status Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${product.purchasePrice.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                        style: AppTheme.font(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withAlpha(25),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                            fontFamilyFallback: AppTheme.fontFallbacks,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 3-Dots Menu
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded, size: 18, color: Colors.grey),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              onSelected: (val) {
                if (val == 'view') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
                  );
                } else if (val == 'edit') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AddProductScreen(editingProduct: product)),
                  );
                } else if (val == 'delete') {
                  _confirmDeleteProduct(context, provider, product, isHindi);
                }
              },
              itemBuilder: (ctx) => [
                PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      const Icon(Icons.visibility_outlined, size: 16),
                      const SizedBox(width: 8),
                      Text(isHindi ? 'विवरण देखें' : 'View Details', style: const TextStyle(fontSize: 12.5)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      const Icon(Icons.edit_outlined, size: 16, color: AppTheme.primary),
                      const SizedBox(width: 8),
                      Text(isHindi ? 'बदलाव करें' : 'Edit', style: const TextStyle(fontSize: 12.5)),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete_outline_rounded, size: 16, color: AppTheme.danger),
                      const SizedBox(width: 8),
                      Text(
                        isHindi ? 'हटाएं' : 'Delete',
                        style: const TextStyle(fontSize: 12.5, color: AppTheme.danger, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
