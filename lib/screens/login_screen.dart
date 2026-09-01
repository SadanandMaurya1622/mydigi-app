import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/warranty_provider.dart';
import '../utils/app_theme.dart';
import 'splash_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleGoogleSignIn() {
    final provider = Provider.of<WarrantyProvider>(context, listen: false);
    setState(() => _isLoading = true);

    // Simulate Google Sign-In OAuth flow
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() => _isLoading = false);

      // Set user profile
      provider.login(
        'Sadanand Gupta',
        'sadanand.gupta@gmail.com',
        '+91 98200 12345',
      );

      // Navigate to SplashScreen which then transitions to MainNavigationHost
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, animation, secondaryAnimation) => const SplashScreen(),
          transitionsBuilder: (_, animation, _, child) => FadeTransition(opacity: animation, child: child),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WarrantyProvider>(context);
    final lang = provider.language;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isHindi = lang == 'hi';

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF0B0F19), const Color(0xFF111827), const Color(0xFF1E1B4B)]
                : [const Color(0xFFF8FAFC), const Color(0xFFEEF2FF), const Color(0xFFE0E7FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    // Top Actions Bar (Language & Theme Mode)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // App Brand Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDark ? const Color(0xFF334155) : AppTheme.borderLight,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 18,
                                height: 18,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(colors: [AppTheme.primary, AppTheme.accent]),
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Text('M', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900)),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'MyDigi',
                                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ],
                          ),
                        ),

                        // Language Toggle Pill
                        TextButton(
                          onPressed: () {
                            provider.setLanguage(lang == 'en' ? 'hi' : 'en');
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            minimumSize: Size.zero,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E293B) : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isDark ? const Color(0xFF334155) : AppTheme.borderLight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(isDark ? 30 : 10),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              isHindi ? '🇬🇧 Switch to English' : '🇮🇳 हिंदी में बदलें',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(flex: 1),

                    // Center Hero Graphic: Glowing App Icon
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED), Color(0xFF9333EA)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4F46E5).withAlpha(140),
                            blurRadius: 28,
                            spreadRadius: 4,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'M',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 48,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // App Title & Tagline
                    Text(
                      'MyDigi',
                      style: GoogleFonts.outfit(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        color: isDark ? Colors.white : AppTheme.textMainLight,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        isHindi
                            ? 'अपने हर प्रोडक्ट का खर्चा और वारंटी, एक ही ऐप में।'
                            : 'All-in-one Product, Warranty, Expense & Service Manager',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                          height: 1.4,
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Feature Showcase Cards (2x2 Compact Grid)
                    Row(
                      children: [
                        _buildFeatureCard(
                          icon: Icons.qr_code_scanner,
                          iconColor: const Color(0xFF6366F1),
                          title: isHindi ? 'AI बिल स्कैनर' : 'AI Bill Scanner',
                          subtitle: isHindi ? 'स्मार्ट OCR एक्सट्रैक्शन' : 'Instant OCR data extraction',
                          isDark: isDark,
                        ),
                        const SizedBox(width: 10),
                        _buildFeatureCard(
                          icon: Icons.notifications_active_outlined,
                          iconColor: const Color(0xFFF59E0B),
                          title: isHindi ? 'वारंटी अलर्ट' : 'Warranty Alerts',
                          subtitle: isHindi ? 'समय पर रीन्यूअल रिमाइंडर' : 'Never miss warranty expiry',
                          isDark: isDark,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildFeatureCard(
                          icon: Icons.receipt_long_outlined,
                          iconColor: const Color(0xFF10B981),
                          title: isHindi ? 'खर्च और TCO' : 'TCO Expense Log',
                          subtitle: isHindi ? 'सर्विस व AMC ट्रैकिंग' : 'Track maintenance costs',
                          isDark: isDark,
                        ),
                        const SizedBox(width: 10),
                        _buildFeatureCard(
                          icon: Icons.lock_outline,
                          iconColor: const Color(0xFFEC4899),
                          title: isHindi ? 'सुरक्षित वॉल्ट' : 'Encrypted Vault',
                          subtitle: isHindi ? '256-Bit प्राइवेट क्लाउड' : '256-Bit secure cloud',
                          isDark: isDark,
                        ),
                      ],
                    ),

                    const Spacer(flex: 2),

                    // Google Sign-In Primary Action Button
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: isDark ? Colors.black.withAlpha(80) : const Color(0xFF4F46E5).withAlpha(40),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Material(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        child: InkWell(
                          onTap: _isLoading ? null : _handleGoogleSignIn,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                width: 1.5,
                              ),
                            ),
                            child: _isLoading
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary)),
                                      ),
                                      const SizedBox(width: 14),
                                      Text(
                                        isHindi ? 'गूगल से कनेक्ट हो रहे हैं...' : 'Signing in with Google...',
                                        style: GoogleFonts.outfit(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? Colors.white : AppTheme.textMainLight,
                                        ),
                                      ),
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Authentic 4-Color Google 'G' Icon
                                      _buildGoogleLogo(),
                                      const SizedBox(width: 14),
                                      Text(
                                        isHindi ? 'Continue with Google' : 'Continue with Google',
                                        style: GoogleFonts.outfit(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.2,
                                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Quick Tap Helper Text
                    Text(
                      isHindi ? '1-Tap सुरक्षित लॉगिन • पासवर्ड की ज़रूरत नहीं' : 'Fast 1-Tap Secure Sign-In • No Password Needed',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Trust Badges & Terms
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.verified_user_rounded, size: 14, color: AppTheme.success),
                        const SizedBox(width: 5),
                        Text(
                          isHindi ? 'Google द्वारा सत्यापित • 100% सुरक्षित' : 'Google Verified • 100% Private & Encrypted',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isHindi
                          ? 'आगे बढ़कर, आप MyDigi की सेवा शर्तों और गोपनीयता नीति से सहमत होते हैं।'
                          : 'By continuing, you agree to MyDigi Terms of Service & Privacy Policy.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B).withAlpha(180) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 40 : 8),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 9.5,
                      color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoogleLogo() {
    return Container(
      width: 26,
      height: 26,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: SizedBox(
          width: 18,
          height: 18,
          child: CustomPaint(
            painter: _GoogleLogoPainter(),
          ),
        ),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Google Blue (#4285F4)
    final paintBlue = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;

    // Google Green (#34A853)
    final paintGreen = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.fill;

    // Google Yellow (#FBBC05)
    final paintYellow = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.fill;

    // Google Red (#EA4335)
    final paintRed = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.fill;

    final center = Offset(w / 2, h / 2);
    final radius = w / 2;

    // Draw Google 4-color arcs
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -0.785, 1.57, true, paintBlue);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), 0.785, 1.57, true, paintGreen);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), 2.356, 1.57, true, paintYellow);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), 3.927, 1.57, true, paintRed);

    // Inner cutout
    final innerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.55, innerPaint);

    // Blue horizontal bar for 'G'
    final barRect = Rect.fromLTRB(w * 0.45, h * 0.38, w * 0.95, h * 0.62);
    canvas.drawRect(barRect, paintBlue);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
