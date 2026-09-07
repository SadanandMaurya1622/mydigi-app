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
import 'invoice_vault_screen.dart';
import 'claims_screen.dart';
import 'amc_screen.dart';
import 'notifications_sheet.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All'; // 'All', 'Active', 'Expiring Soon', 'Expired'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getGreeting(bool isHindi) {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return isHindi ? 'सुप्रभात ☀️' : 'Good Morning ☀️';
    } else if (hour < 17) {
      return isHindi ? 'शुभ दोपहर 🌤️' : 'Good Afternoon 🌤️';
    } else {
      return isHindi ? 'शुभ संध्या 🌙' : 'Good Evening 🌙';
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WarrantyProvider>(context);
    final lang = provider.language;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isHindi = lang == 'hi';

    final products = provider.products;
    final totalCount = products.length;
    final activeCount = products.where((p) => p.warrantyStatus == 'Active').length;
    final expiringCount = products.where((p) => p.warrantyStatus == 'Expiring Soon').length;
    final expiredCount = products.where((p) => p.warrantyStatus == 'Expired').length;
    final totalValue = products.fold<double>(0.0, (sum, p) => sum + p.purchasePrice);

    // Filtered list for search or status
    final filteredProducts = products.where((p) {
      final matchesQuery = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.brand.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesStatus = _selectedFilter == 'All' || p.warrantyStatus == _selectedFilter;

      return matchesQuery && matchesStatus;
    }).toList();

    // Expiring soon items for gentle reminder
    final expiringItems = products.where((p) => p.warrantyStatus == 'Expiring Soon').toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            // User Avatar
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                image: provider.userProfile.photoUrl != null && provider.userProfile.photoUrl!.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(provider.userProfile.photoUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: provider.userProfile.photoUrl == null || provider.userProfile.photoUrl!.isEmpty
                  ? Center(
                      child: Text(
                        provider.userProfile.name.isNotEmpty ? provider.userProfile.name[0].toUpperCase() : 'U',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 10),

            // Greeting + Name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getGreeting(isHindi),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                    ),
                  ),
                  Text(
                    provider.userProfile.name.isNotEmpty ? provider.userProfile.name : (isHindi ? 'नमस्ते' : 'Welcome'),
                    style: AppTheme.font(fontWeight: FontWeight.w800, fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // 1-Tap Language Switcher (Easy & Prominent)
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              provider.setLanguage(lang == 'hi' ? 'en' : 'hi');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Text(
                lang == 'hi' ? '🇮🇳 हिंदी' : '🇬🇧 English',
                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Notification Bell
          IconButton(
            icon: Stack(
              children: [
                Icon(
                  Icons.notifications_outlined,
                  size: 22,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
                if (expiringCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppTheme.danger,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            tooltip: isHindi ? 'सूचनाएं' : 'Notifications',
            onPressed: () {
              HapticFeedback.lightImpact();
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (_) => const NotificationsSheet(),
              );
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: GlassScaffoldBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. SIMPLE & FRIENDLY SUMMARY CARD
                _buildSimpleSummaryCard(
                  context,
                  totalCount: totalCount,
                  totalValue: totalValue,
                  activeCount: activeCount,
                  expiredCount: expiredCount,
                  isDark: isDark,
                  isHindi: isHindi,
                ),
                const SizedBox(height: 16),

                // 2. GENTLE EXPIRY ALERT (Only shows if something is expiring soon!)
                if (expiringItems.isNotEmpty) ...[
                  _buildGentleExpiryBanner(context, expiringItems.first, isDark, isHindi),
                  const SizedBox(height: 16),
                ],

                // 3. 4 BIG & EASY ACTION BUTTONS
                _buildEasyActionHub(context, isDark, isHindi),
                const SizedBox(height: 18),

                // 4. SEARCH BAR (Simple & Clean)
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(isDark ? 30 : 6),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
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
                      hintText: isHindi ? 'सामान या ब्रांड का नाम खोजें...' : 'Search your items or brands...',
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
                const SizedBox(height: 14),

                // 5. SIMPLE FILTER CHIPS (All, Active, Expired)
                Row(
                  children: [
                    _buildFilterChip('All', isHindi ? 'सभी सामान' : 'All Items', totalCount, isDark),
                    const SizedBox(width: 8),
                    _buildFilterChip('Active', isHindi ? '🟢 सुरक्षित' : '🟢 Active', activeCount, isDark),
                    const SizedBox(width: 8),
                    _buildFilterChip('Expired', isHindi ? '🔴 समाप्त' : '🔴 Expired', expiredCount, isDark),
                  ],
                ),
                const SizedBox(height: 16),

                // 6. SECTION TITLE: RECENT ITEMS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isHindi ? 'आपके सुरक्षित सामान' : 'Your Saved Items',
                      style: AppTheme.font(fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                    if (products.isNotEmpty)
                      Text(
                        '${filteredProducts.length} ${isHindi ? 'दिख रहे हैं' : 'items'}',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),

                // 7. PRODUCT LIST (EASY TO READ CARDS)
                if (filteredProducts.isEmpty)
                  _buildEmptyPlaceholder(context, isDark, isHindi, products.isEmpty)
                else
                  ...filteredProducts.map((product) => _buildSimpleProductCard(context, product, isDark, isHindi)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // 1. SIMPLE & FRIENDLY SUMMARY CARD
  // -------------------------------------------------------------
  Widget _buildSimpleSummaryCard(
    BuildContext context, {
    required int totalCount,
    required double totalValue,
    required int activeCount,
    required int expiredCount,
    required bool isDark,
    required bool isHindi,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withAlpha(80),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isHindi ? 'कुल सुरक्षित सामान' : 'Total Saved Items',
            style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),

          // Big number & Value
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$totalCount ${isHindi ? 'सामान' : 'Items'}',
                style: AppTheme.font(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (totalValue > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(35),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '₹${totalValue.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Simple Active / Expired indicators
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '🟢 $activeCount ${isHindi ? 'वारंटी सक्रिय' : 'Active'}',
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              if (expiredCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '🔴 $expiredCount ${isHindi ? 'समाप्त' : 'Expired'}',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Big Friendly "+ Add New Item" button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddProductScreen()),
                );
              },
              icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
              label: Text(
                isHindi ? '+ नया प्रोडक्ट या बिल जोड़ें' : '+ Add New Item / Bill',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF3B82F6),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // 2. GENTLE EXPIRY ALERT BANNER
  // -------------------------------------------------------------
  Widget _buildGentleExpiryBanner(BuildContext context, ProductItem product, bool isDark, bool isHindi) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withAlpha(isDark ? 30 : 18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF59E0B).withAlpha(80), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withAlpha(40),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isHindi ? 'वारंटी जल्द समाप्त होगी' : 'Warranty Expiring Soon',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD97706),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${product.name} (${product.daysRemaining} ${isHindi ? 'दिन बाकी' : 'days left'})',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark ? Colors.white70 : const Color(0xFF475569),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
              );
            },
            child: Text(
              isHindi ? 'देखें' : 'View',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD97706), fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // 3. 4 BIG & EASY ACTION BUTTONS
  // -------------------------------------------------------------
  Widget _buildEasyActionHub(BuildContext context, bool isDark, bool isHindi) {
    return Row(
      children: [
        Expanded(
          child: _buildBigActionButton(
            context,
            icon: Icons.qr_code_scanner_rounded,
            color: const Color(0xFF3B82F6),
            title: isHindi ? 'बिल स्कैन' : 'Scan Bill',
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ScannerScreen()));
            },
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildBigActionButton(
            context,
            icon: Icons.receipt_long_rounded,
            color: const Color(0xFF10B981),
            title: isHindi ? 'बिल वॉल्ट' : 'My Bills',
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.push(context, MaterialPageRoute(builder: (_) => const InvoiceVaultScreen()));
            },
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildBigActionButton(
            context,
            icon: Icons.shield_outlined,
            color: const Color(0xFFEC4899),
            title: isHindi ? 'क्लेम' : 'Claims',
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ClaimsScreen()));
            },
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildBigActionButton(
            context,
            icon: Icons.headset_mic_rounded,
            color: const Color(0xFF8B5CF6),
            title: isHindi ? 'सपोर्ट' : 'Support',
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AMCScreen()));
            },
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildBigActionButton(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 20 : 6),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
                fontFamilyFallback: AppTheme.fontFallbacks,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // 4. FILTER CHIP
  // -------------------------------------------------------------
  Widget _buildFilterChip(String key, String label, int count, bool isDark) {
    final isSelected = _selectedFilter == key;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedFilter = key);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary
              : (isDark ? const Color(0xFF1E293B) : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primary : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          ),
        ),
        child: Text(
          '$label ($count)',
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF475569)),
            fontFamilyFallback: AppTheme.fontFallbacks,
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // 5. SIMPLE & CLEAN PRODUCT CARD
  // -------------------------------------------------------------
  Widget _buildSimpleProductCard(
    BuildContext context,
    ProductItem product,
    bool isDark,
    bool isHindi,
  ) {
    Color statusColor;
    String statusText;

    if (product.warrantyStatus == 'Active') {
      statusColor = const Color(0xFF10B981);
      statusText = product.daysRemaining > 0
          ? (isHindi ? 'वारंटी: ${product.daysRemaining} दिन शेष' : 'Active • ${product.daysRemaining} days left')
          : (isHindi ? 'वारंटी सक्रिय' : 'Active Warranty');
    } else if (product.warrantyStatus == 'Expiring Soon') {
      statusColor = const Color(0xFFF59E0B);
      statusText = isHindi ? 'जल्द समाप्त (${product.daysRemaining} दिन)' : 'Expiring Soon (${product.daysRemaining}d)';
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
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 68,
                height: 68,
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                    child: const Icon(Icons.devices_other_rounded, color: AppTheme.primary, size: 28),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.brand.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
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
                      fontSize: 14,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${product.purchasePrice.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                        style: AppTheme.font(
                          fontWeight: FontWeight.w900,
                          fontSize: 14.5,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: statusColor.withAlpha(25),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 10,
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

            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, size: 20, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // 6. EMPTY STATE
  // -------------------------------------------------------------
  Widget _buildEmptyPlaceholder(BuildContext context, bool isDark, bool isHindi, bool isTotalEmpty) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B).withAlpha(120) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          Icon(
            isTotalEmpty ? Icons.inventory_2_outlined : Icons.search_off_rounded,
            size: 44,
            color: AppTheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            isTotalEmpty
                ? (isHindi ? 'कोई सामान सुरक्षित नहीं है' : 'No Items Added Yet')
                : (isHindi ? 'कोई मिलता-जुलता सामान नहीं मिला' : 'No matching items found'),
            style: AppTheme.font(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 6),
          Text(
            isTotalEmpty
                ? (isHindi
                    ? 'नीचे बटन दबाकर अपने बिल या वारंटी कार्ड सेव करें।'
                    : 'Add your first product or bill to start warranty tracking.')
                : (isHindi ? 'सर्च कीवर्ड बदलकर देखें' : 'Try searching with different keywords'),
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
            ),
            textAlign: TextAlign.center,
          ),
          if (isTotalEmpty) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddProductScreen()),
                );
              },
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(
                isHindi ? '+ नया प्रोडक्ट जोड़ें' : '+ Add First Item',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
