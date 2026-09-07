import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/warranty_provider.dart';
import '../utils/app_theme.dart';
import '../utils/translations.dart';
import '../widgets/glass_container.dart';
import 'login_screen.dart';
import 'main_navigation_host.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingItem> _slides = const [
    _OnboardingItem(
      titleKey: 'onboardingTitle1',
      subKey: 'onboardingSub1',
      icon: Icons.qr_code_scanner_rounded,
      accentColor: Color(0xFF6366F1), // Indigo
      gradient: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
      tags: ['Smart OCR', 'Auto Detect', 'Zero Typing'],
    ),
    _OnboardingItem(
      titleKey: 'onboardingTitle2',
      subKey: 'onboardingSub2',
      icon: Icons.notifications_active_rounded,
      accentColor: Color(0xFFF59E0B), // Amber
      gradient: [Color(0xFFF59E0B), Color(0xFFEA580C)],
      tags: ['Timely Alerts', 'AMC Renewals', 'Free Service'],
    ),
    _OnboardingItem(
      titleKey: 'onboardingTitle3',
      subKey: 'onboardingSub3',
      icon: Icons.pie_chart_rounded,
      accentColor: Color(0xFF10B981), // Emerald
      gradient: [Color(0xFF10B981), Color(0xFF059669)],
      tags: ['TCO Analysis', 'Repair Logs', 'Asset Valuation'],
    ),
    _OnboardingItem(
      titleKey: 'onboardingTitle4',
      subKey: 'onboardingSub4',
      icon: Icons.verified_user_rounded,
      accentColor: Color(0xFF8B5CF6), // Violet
      gradient: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
      tags: ['256-Bit Cloud', 'Instant Proof', 'Family Share'],
    ),
  ];

  void _finishOnboarding({bool asGuest = false}) async {
    HapticFeedback.mediumImpact();
    final provider = Provider.of<WarrantyProvider>(context, listen: false);
    await provider.completeOnboarding();

    if (!mounted) return;

    if (asGuest) {
      await provider.loginAsGuest();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 350),
          pageBuilder: (_, animation, _) => const MainNavigationHost(),
          transitionsBuilder: (_, animation, _, child) => FadeTransition(opacity: animation, child: child),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 350),
          pageBuilder: (_, animation, _) => const LoginScreen(),
          transitionsBuilder: (_, animation, _, child) => FadeTransition(opacity: animation, child: child),
        ),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WarrantyProvider>(context);
    final lang = provider.language;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLastPage = _currentPage == _slides.length - 1;

    return Scaffold(
      body: GlassScaffoldBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar: Brand, Language Toggle, and Skip
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Brand Icon & Name
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
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
                        Text(
                          'MyDigi',
                          style: AppTheme.font(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),

                    // Language Switcher & Skip
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            provider.setLanguage(lang == 'en' ? 'hi' : 'en');
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: GlassCard(
                            borderRadius: 14,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            opacity: 0.85,
                            child: Text(
                              lang == 'en' ? '🇮🇳 हिंदी' : '🇬🇧 EN',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (!isLastPage)
                          TextButton(
                            onPressed: () => _finishOnboarding(),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            ),
                            child: Text(
                              AppTranslations.tr('skip', lang),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Middle: PageView with Slide Cards
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    HapticFeedback.selectionClick();
                    setState(() => _currentPage = index);
                  },
                  itemCount: _slides.length,
                  itemBuilder: (context, index) {
                    final item = _slides[index];
                    return _buildSlide(context, item, lang, isDark);
                  },
                ),
              ),

              // Bottom Area: Indicators, Action Buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Smooth Animated Dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_slides.length, (index) {
                        final isSelected = index == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 7,
                          width: isSelected ? 28 : 7,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? _slides[_currentPage].accentColor
                                : (isDark ? Colors.white24 : Colors.black12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),

                    // Primary Button (Next or Get Started)
                    Container(
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _slides[_currentPage].gradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: _slides[_currentPage].accentColor.withAlpha(110),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            if (isLastPage) {
                              _finishOnboarding();
                            } else {
                              HapticFeedback.lightImpact();
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 320),
                                curve: Curves.easeInOutCubic,
                              );
                            }
                          },
                          borderRadius: BorderRadius.circular(18),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  isLastPage
                                      ? AppTranslations.tr('getStarted', lang)
                                      : AppTranslations.tr('next', lang),
                                  style: AppTheme.font(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  isLastPage ? Icons.arrow_forward_rounded : Icons.chevron_right_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Quick Demo Explorer Mode Button
                    TextButton(
                      onPressed: () => _finishOnboarding(asGuest: true),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.play_circle_outline_rounded,
                            size: 16,
                            color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            AppTranslations.tr('exploreDemo', lang),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlide(
    BuildContext context,
    _OnboardingItem item,
    String lang,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration / Icon Pod with Ambient Glow
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: item.gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: item.accentColor.withAlpha(120),
                  blurRadius: 36,
                  spreadRadius: 4,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                item.icon,
                size: 64,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 38),

          // Slide Title
          Text(
            AppTranslations.tr(item.titleKey, lang),
            textAlign: TextAlign.center,
            style: AppTheme.font(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              height: 1.25,
              color: isDark ? Colors.white : AppTheme.textMainLight,
            ),
          ),
          const SizedBox(height: 14),

          // Slide Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              AppTranslations.tr(item.subKey, lang),
              textAlign: TextAlign.center,
              style: AppTheme.font(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.5,
                color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Feature Badges / Pills
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: item.tags.map((tag) {
              return GlassCard(
                borderRadius: 12,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                opacity: 0.8,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: item.accentColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      tag,
                      style: AppTheme.font(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white70 : const Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _OnboardingItem {
  final String titleKey;
  final String subKey;
  final IconData icon;
  final Color accentColor;
  final List<Color> gradient;
  final List<String> tags;

  const _OnboardingItem({
    required this.titleKey,
    required this.subKey,
    required this.icon,
    required this.accentColor,
    required this.gradient,
    required this.tags,
  });
}
