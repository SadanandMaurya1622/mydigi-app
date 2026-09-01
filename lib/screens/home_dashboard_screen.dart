import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/warranty_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/glass_container.dart';
import 'product_detail_screen.dart';
import 'add_product_screen.dart';
import 'scanner_screen.dart';
import 'expenses_screen.dart';
import 'invoice_vault_screen.dart';
import 'claims_screen.dart';
import 'amc_screen.dart';
import 'analytics_reports_screen.dart';
import 'notifications_sheet.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  String _searchQuery = '';
  String _selectedStatusFilter = 'All'; // 'All', 'Active', 'Expiring Soon', 'Expired'

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WarrantyProvider>(context);
    final lang = provider.language;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isHindi = lang == 'hi';

    // Filtered products on Home for instant ease of search
    final filteredProducts = provider.products.where((p) {
      final matchesQuery = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.brand.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.category.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesStatus = _selectedStatusFilter == 'All' || p.warrantyStatus == _selectedStatusFilter;

      return matchesQuery && matchesStatus;
    }).toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withAlpha(90),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'M',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MyDigi',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                Text(
                  '${isHindi ? 'नमस्ते' : 'Hello'}, ${provider.userProfile.name.split(' ').first} 👋',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // 1-Tap Language Switcher
          TextButton(
            onPressed: () {
              provider.setLanguage(lang == 'en' ? 'hi' : 'en');
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: GlassCard(
              borderRadius: 14,
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              opacity: 0.8,
              child: Text(
                lang == 'en' ? '🇮🇳 हिंदी' : '🇬🇧 EN',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 4),

          // Notifications Bell with Badge
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const NotificationsSheet(),
                  );
                },
              ),
              if (provider.unreadNotificationsCount > 0)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppTheme.danger,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${provider.unreadNotificationsCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: GlassScaffoldBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Frosted Glassy Search Bar
                  GlassCard(
                    borderRadius: 20,
                    padding: EdgeInsets.zero,
                    opacity: 0.82,
                    blur: 24,
                    child: TextField(
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: InputDecoration(
                        hintText: isHindi
                            ? 'प्रोडक्ट, बिल, या ब्रांड खोजें (Search)...'
                            : 'Search products, warranties, or bills...',
                        hintStyle: TextStyle(
                          fontSize: 12.5,
                          color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                        ),
                        prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppTheme.primary),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () => setState(() => _searchQuery = ''),
                              )
                            : IconButton(
                                icon: const Icon(Icons.qr_code_scanner, size: 20, color: AppTheme.primary),
                                tooltip: 'Scan Bill',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const ScannerScreen()),
                                  );
                                },
                              ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 2. Glassy KPI Stats Grid (Tappable to filter)
                  Row(
                    children: [
                      _buildGlassStatCard(
                        title: isHindi ? 'कुल प्रोडक्ट्स' : 'Total Assets',
                        value: '${provider.products.length}',
                        sub: '₹${(provider.totalAssetValue / 100000).toStringAsFixed(1)}L ${isHindi ? 'मूल्य' : 'Value'}',
                        color: AppTheme.primary,
                        icon: Icons.inventory_2_outlined,
                        isSelected: _selectedStatusFilter == 'All',
                        onTap: () => setState(() => _selectedStatusFilter = 'All'),
                        isDark: isDark,
                      ),
                      const SizedBox(width: 10),
                      _buildGlassStatCard(
                        title: isHindi ? 'समाप्त होने वाली' : 'Expiring Soon',
                        value: '${provider.expiringSoonCount}',
                        sub: isHindi ? 'ध्यान दें (Alert)' : 'Action Needed',
                        color: AppTheme.warning,
                        icon: Icons.warning_amber_rounded,
                        isSelected: _selectedStatusFilter == 'Expiring Soon',
                        onTap: () => setState(() => _selectedStatusFilter = _selectedStatusFilter == 'Expiring Soon' ? 'All' : 'Expiring Soon'),
                        isDark: isDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildGlassStatCard(
                        title: isHindi ? 'सक्रिय वारंटी' : 'Active Safe',
                        value: '${provider.activeCount}',
                        sub: isHindi ? '100% सुरक्षित' : '100% Protected',
                        color: AppTheme.success,
                        icon: Icons.verified_user_outlined,
                        isSelected: _selectedStatusFilter == 'Active',
                        onTap: () => setState(() => _selectedStatusFilter = _selectedStatusFilter == 'Active' ? 'All' : 'Active'),
                        isDark: isDark,
                      ),
                      const SizedBox(width: 10),
                      _buildGlassStatCard(
                        title: isHindi ? 'कुल खर्चे' : 'Expenses & TCO',
                        value: '₹${provider.totalExpenseValue.toInt()}',
                        sub: isHindi ? 'सर्विस व AMC' : 'Service & AMC',
                        color: AppTheme.secondary,
                        icon: Icons.receipt_long_outlined,
                        isSelected: false,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ExpensesScreen()),
                          );
                        },
                        isDark: isDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // 3. Urgent Expiry Action Card (Only when products are expiring)
                  if (provider.expiringSoonCount > 0)
                    GlassCard(
                      borderRadius: 22,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 18),
                      tintColor: const Color(0xFFE11D48),
                      opacity: 0.88,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(60),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.alarm_on_rounded, color: Colors.white, size: 24),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isHindi
                                          ? 'सैमसंग एसी की वारंटी 7 दिनों में समाप्त!'
                                          : 'Samsung AC Warranty Ends in 7 Days!',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      isHindi
                                          ? 'मुफ़्त वार्षिक सर्विस क्लेम करें या AMC रीन्यू कराएं।'
                                          : 'Claim free annual service or renew AMC today.',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  final acProduct = provider.products.firstWhere(
                                    (p) => p.daysRemaining <= 7,
                                    orElse: () => provider.products.first,
                                  );
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ProductDetailScreen(product: acProduct),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.arrow_forward_rounded, size: 14),
                                label: Text(
                                  isHindi ? 'अभी देखें (Act Now)' : 'View & Renew',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFFE11D48),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  // 4. Quick Action Tools (Glassy Floating Pods)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isHindi ? 'त्वरित कार्य (Quick Actions)' : 'Quick Actions Hub',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        isHindi ? '1-टैप शॉर्टकट' : '1-Tap Shortcuts',
                        style: TextStyle(fontSize: 11, color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 104,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      children: [
                        _buildEasyActionButton(
                          context: context,
                          label: isHindi ? 'बिल स्कैन' : 'Scan Bill',
                          sub: isHindi ? 'AI कैमरा' : 'AI Camera',
                          icon: Icons.qr_code_scanner,
                          gradient: const [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScannerScreen())),
                        ),
                        const SizedBox(width: 10),
                        _buildEasyActionButton(
                          context: context,
                          label: isHindi ? 'नया प्रोडक्ट' : 'Add Item',
                          sub: isHindi ? 'मैन्युअल' : 'Manual Form',
                          icon: Icons.add_box_rounded,
                          gradient: const [Color(0xFF0EA5E9), Color(0xFF2563EB)],
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductScreen())),
                        ),
                        const SizedBox(width: 10),
                        _buildEasyActionButton(
                          context: context,
                          label: isHindi ? 'खर्चा जोड़ें' : 'Log Expense',
                          sub: isHindi ? 'सर्विस/मरम्मत' : 'Service/Repair',
                          icon: Icons.receipt_long,
                          gradient: const [Color(0xFF10B981), Color(0xFF059669)],
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpensesScreen())),
                        ),
                        const SizedBox(width: 10),
                        _buildEasyActionButton(
                          context: context,
                          label: isHindi ? 'दस्तावेज़ वॉल्ट' : 'Bills Vault',
                          sub: isHindi ? 'PDF रसीदें' : 'PDF Invoices',
                          icon: Icons.folder_shared_rounded,
                          gradient: const [Color(0xFFF59E0B), Color(0xFFD97706)],
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InvoiceVaultScreen())),
                        ),
                        const SizedBox(width: 10),
                        _buildEasyActionButton(
                          context: context,
                          label: isHindi ? 'वारंटी क्लेम' : 'File Claim',
                          sub: isHindi ? 'कंपनी सर्विस' : 'OEM Claim',
                          icon: Icons.shield_rounded,
                          gradient: const [Color(0xFFEC4899), Color(0xFFBE185D)],
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClaimsScreen())),
                        ),
                        const SizedBox(width: 10),
                        _buildEasyActionButton(
                          context: context,
                          label: isHindi ? 'AMC व बीमा' : 'AMC & Care',
                          sub: isHindi ? 'हेल्पलाइन' : 'Helplines',
                          icon: Icons.support_agent_rounded,
                          gradient: const [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AMCScreen())),
                        ),
                        const SizedBox(width: 10),
                        _buildEasyActionButton(
                          context: context,
                          label: isHindi ? 'TCO रिपोर्ट' : 'TCO Report',
                          sub: isHindi ? 'फाइनेंशियल' : 'Financials',
                          icon: Icons.insights_rounded,
                          gradient: const [Color(0xFF6366F1), Color(0xFF4338CA)],
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsReportsScreen())),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 5. Products Section with Status Filter Chips
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isHindi ? 'सुरक्षित प्रोडक्ट्स' : 'Protected Products',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        '${filteredProducts.length} ${isHindi ? 'आइटम्स' : 'items'}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Filter Chips
                  Row(
                    children: [
                      _buildFilterChip('All', isHindi ? 'सभी (${provider.products.length})' : 'All (${provider.products.length})', isDark),
                      const SizedBox(width: 6),
                      _buildFilterChip('Active', isHindi ? 'सक्रिय (${provider.activeCount})' : 'Active (${provider.activeCount})', isDark),
                      const SizedBox(width: 6),
                      _buildFilterChip('Expiring Soon', isHindi ? 'समाप्त होने वाली (${provider.expiringSoonCount})' : 'Expiring (${provider.expiringSoonCount})', isDark),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Products List / Empty State
                  if (filteredProducts.isEmpty)
                    GlassCard(
                      borderRadius: 20,
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        children: [
                          Icon(Icons.search_off_rounded, size: 42, color: isDark ? Colors.white38 : Colors.black38),
                          const SizedBox(height: 8),
                          Text(
                            isHindi ? 'कोई प्रोडक्ट नहीं मिला' : 'No matching products found',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isHindi ? 'कृपया सर्च टर्म बदलें या नया प्रोडक्ट जोड़ें।' : 'Try changing your search or add a new item.',
                            style: TextStyle(fontSize: 12, color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight),
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        return _buildGlassProductCard(context, product, lang, isDark, isHindi);
                      },
                    ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String status, String label, bool isDark) {
    final isSelected = _selectedStatusFilter == status;
    Color chipColor = AppTheme.primary;
    if (status == 'Active') chipColor = AppTheme.success;
    if (status == 'Expiring Soon') chipColor = AppTheme.warning;

    return GestureDetector(
      onTap: () => setState(() => _selectedStatusFilter = status),
      child: GlassCard(
        borderRadius: 14,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        opacity: isSelected ? 0.9 : 0.6,
        tintColor: isSelected ? chipColor : null,
        border: Border.all(
          color: isSelected ? chipColor : Colors.white.withAlpha(isDark ? 20 : 180),
          width: 1.2,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Colors.white : (isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassStatCard({
    required String title,
    required String value,
    required String sub,
    required Color color,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Expanded(
      child: GlassCard(
        borderRadius: 20,
        padding: const EdgeInsets.all(14),
        opacity: isSelected ? 0.88 : 0.75,
        tintColor: color,
        border: Border.all(
          color: isSelected ? color : Colors.white.withAlpha(isDark ? 30 : 200),
          width: isSelected ? 1.8 : 1.0,
        ),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 22),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withAlpha(40),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'LIVE',
                    style: TextStyle(
                      color: color,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 21,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11.5,
                color: isDark ? Colors.white : AppTheme.textMainLight,
              ),
            ),
            Text(
              sub,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEasyActionButton({
    required BuildContext context,
    required String label,
    required String sub,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: gradient.first.withAlpha(90),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
              border: Border.all(
                color: Colors.white.withAlpha(180),
                width: 1.2,
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 5),
          SizedBox(
            width: 68,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            width: 68,
            child: Text(
              sub,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 9, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassProductCard(
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
      padding: const EdgeInsets.all(12),
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
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  product.imageUrl,
                  width: 68,
                  height: 68,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 68,
                    height: 68,
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    child: const Icon(Icons.devices_other_rounded, color: Colors.grey, size: 28),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Product Details
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: statusColor.withAlpha(30),
                            borderRadius: BorderRadius.circular(10),
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
                            fontSize: 14,
                            color: AppTheme.primary,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.schedule, size: 12, color: statusColor),
                            const SizedBox(width: 3),
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
          const SizedBox(height: 10),
          Divider(
            height: 1,
            thickness: 0.8,
            color: isDark ? Colors.white.withAlpha(20) : Colors.black.withAlpha(15),
          ),
          const SizedBox(height: 8),

          // 1-Tap Quick Action Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
              Row(
                children: [
                  // Direct 1-Tap Helpline / Care
                  GestureDetector(
                    onTap: () {
                      final contact = product.sellerContact.isNotEmpty ? product.sellerContact : '1800-200-4000';
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('📞 Dialing ${product.brand} Support: $contact'),
                          backgroundColor: AppTheme.primary,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A).withAlpha(150) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.call, size: 11, color: AppTheme.success),
                          const SizedBox(width: 4),
                          Text(
                            isHindi ? 'हेल्पलाइन' : 'Call Care',
                            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),

                  // Direct 1-Tap QR Passport
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.qr_code, size: 11, color: AppTheme.primary),
                        const SizedBox(width: 4),
                        Text(
                          isHindi ? 'पासपोर्ट' : 'QR View',
                          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppTheme.primary),
                        ),
                      ],
                    ),
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
