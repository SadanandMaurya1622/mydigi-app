import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/warranty_provider.dart';
import '../utils/app_theme.dart';
import '../utils/translations.dart';
import 'home_dashboard_screen.dart';
import 'products_screen.dart';
import 'scanner_screen.dart';
import 'expenses_screen.dart';
import 'more_settings_screen.dart';

class MainNavigationHost extends StatefulWidget {
  const MainNavigationHost({super.key});

  @override
  State<MainNavigationHost> createState() => _MainNavigationHostState();
}

class _MainNavigationHostState extends State<MainNavigationHost> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeDashboardScreen(),
    ProductsScreen(),
    SizedBox.shrink(), // Center OCR Action placeholder
    ExpensesScreen(),
    MoreSettingsScreen(),
  ];

  void _onTabTapped(int index) {
    HapticFeedback.selectionClick();
    if (index == 2) {
      Navigator.push(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 320),
          pageBuilder: (_, _, _) => const ScannerScreen(),
          transitionsBuilder: (_, animation, _, child) {
            return SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              child: child,
            );
          },
        ),
      );
    } else {
      if (_currentIndex != index) {
        setState(() => _currentIndex = index);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WarrantyProvider>(context);
    final lang = provider.language;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex == 2 ? 0 : _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildPremiumFloatingNavBar(context, isDark, lang),
    );
  }

  Widget _buildPremiumFloatingNavBar(BuildContext context, bool isDark, String lang) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      margin: EdgeInsets.only(
        left: 14,
        right: 14,
        bottom: bottomPadding > 0 ? bottomPadding : 12,
      ),
      height: 68,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // 1. Sleek Frosted Glass Floating Dock
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withAlpha(160)
                        : AppTheme.primary.withAlpha(35),
                    blurRadius: 24,
                    spreadRadius: 1,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: isDark
                        ? const Color(0xFF1E1B4B).withAlpha(80)
                        : Colors.black.withAlpha(10),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [
                                const Color(0xFF0F172A).withAlpha(235),
                                const Color(0xFF1E293B).withAlpha(225),
                              ]
                            : [
                                Colors.white.withAlpha(245),
                                const Color(0xFFF8FAFC).withAlpha(235),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withAlpha(25)
                            : Colors.white.withAlpha(210),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Tab 0: Home
                        _buildNavItem(
                          index: 0,
                          icon: Icons.home_outlined,
                          activeIcon: Icons.home_rounded,
                          label: AppTranslations.tr('home', lang),
                          isSelected: _currentIndex == 0,
                          isDark: isDark,
                        ),

                        // Tab 1: Products
                        _buildNavItem(
                          index: 1,
                          icon: Icons.inventory_2_outlined,
                          activeIcon: Icons.inventory_2_rounded,
                          label: AppTranslations.tr('products', lang),
                          isSelected: _currentIndex == 1,
                          isDark: isDark,
                        ),

                        // Spacer for Center Floating Pod
                        const SizedBox(width: 58),

                        // Tab 3: Expenses
                        _buildNavItem(
                          index: 3,
                          icon: Icons.receipt_long_outlined,
                          activeIcon: Icons.receipt_long_rounded,
                          label: AppTranslations.tr('expenses', lang),
                          isSelected: _currentIndex == 3,
                          isDark: isDark,
                        ),

                        // Tab 4: More
                        _buildNavItem(
                          index: 4,
                          icon: Icons.grid_view_outlined,
                          activeIcon: Icons.grid_view_rounded,
                          label: AppTranslations.tr('more', lang),
                          isSelected: _currentIndex == 4,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 2. Elevated Floating AI Center Pod
          Positioned(
            top: -14,
            child: _buildCenterScanButton(isDark, lang),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isSelected,
    required bool isDark,
  }) {
    final activeColor = AppTheme.primary;
    final inactiveColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onTabTapped(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? AppTheme.primary.withAlpha(30) : AppTheme.primary.withAlpha(18))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: isSelected ? 1.15 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutBack,
                child: Icon(
                  isSelected ? activeIcon : icon,
                  color: isSelected ? activeColor : inactiveColor,
                  size: 22,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.font(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? activeColor : inactiveColor,
                ),
              ),
              const SizedBox(height: 2),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isSelected ? 14 : 0,
                height: 2.5,
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterScanButton(bool isDark, String lang) {
    return GestureDetector(
      onTap: () => _onTabTapped(2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF4F46E5), // Indigo
                  Color(0xFF7C3AED), // Violet
                  Color(0xFF9333EA), // Purple
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withAlpha(130),
                  blurRadius: 16,
                  spreadRadius: 2,
                  offset: const Offset(0, 6),
                ),
              ],
              border: Border.all(
                color: Colors.white.withAlpha(220),
                width: 2.5,
              ),
            ),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.qr_code_scanner_rounded,
                    color: Colors.white,
                    size: 25,
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF38BDF8), // Cyan indicator dot
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            AppTranslations.tr('scan', lang),
            style: AppTheme.font(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
