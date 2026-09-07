import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/warranty_provider.dart';
import '../services/auth_service.dart';
import '../utils/app_theme.dart';
import '../widgets/glass_container.dart';
import 'main_navigation_host.dart';

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
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    final provider = Provider.of<WarrantyProvider>(context, listen: false);
    final isHindi = provider.language == 'hi';

    setState(() => _isLoading = true);

    try {
      final userCredential = await AuthService().signInWithGoogle();

      if (userCredential != null && userCredential.user != null) {
        final user = userCredential.user!;
        final realName = (user.displayName != null && user.displayName!.trim().isNotEmpty)
            ? user.displayName!.trim()
            : (user.email != null && user.email!.contains('@'))
                ? user.email!.split('@').first
                : 'Google User';
        final realEmail = user.email ?? '';
        final realPhoto = user.photoURL;

        await provider.login(
          realName,
          realEmail,
          user.phoneNumber ?? '',
          photoUrl: realPhoto,
          uid: user.uid,
        );

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 280),
            pageBuilder: (_, animation, secondaryAnimation) => const MainNavigationHost(),
            transitionsBuilder: (_, animation, _, child) => FadeTransition(opacity: animation, child: child),
          ),
        );
      } else {
        // User dismissed the Google sign-in sheet
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isHindi ? 'Google साइन-इन त्रुटि: $error' : 'Google Sign-In Error: $error',
          ),
          backgroundColor: AppTheme.danger,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WarrantyProvider>(context);
    final lang = provider.language;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isHindi = lang == 'hi';

    return Scaffold(
      body: GlassScaffoldBackground(
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    // 1. Top Bar (Brand Capsule + Language Switcher)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // App Brand Pill
                        GlassCard(
                          borderRadius: 20,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          opacity: 0.8,
                          child: Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(colors: [AppTheme.primary, AppTheme.accent]),
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Text('M', style: TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w900)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'MyDigi',
                                style: AppTheme.font(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ],
                          ),
                        ),

                        // Language Toggle Pill
                        GestureDetector(
                          onTap: () {
                            provider.setLanguage(lang == 'en' ? 'hi' : 'en');
                          },
                          child: GlassCard(
                            borderRadius: 16,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            opacity: 0.8,
                            child: Row(
                              children: [
                                const Icon(Icons.language_rounded, size: 14, color: AppTheme.primary),
                                const SizedBox(width: 6),
                                Text(
                                  isHindi ? '🇬🇧 English' : '🇮🇳 हिंदी',
                                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(flex: 1),

                    // 2. Central 3D Glowing App Emblem
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED), Color(0xFF9333EA)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4F46E5).withAlpha(140),
                            blurRadius: 30,
                            spreadRadius: 4,
                            offset: const Offset(0, 10),
                          ),
                          BoxShadow(
                            color: const Color(0xFF9333EA).withAlpha(80),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.white.withAlpha(180),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'M',
                          style: AppTheme.font(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 48,
                            letterSpacing: -1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // App Title & Tagline
                    Text(
                      'MyDigi',
                      style: AppTheme.font(
                        fontSize: 34,
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
                            : 'All-in-One Product, Warranty & Ownership Expense Vault',
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

                    // 3. Glassy Enterprise Feature Cards (2x2 Grid)
                    Row(
                      children: [
                        _buildFeatureCard(
                          icon: Icons.qr_code_scanner,
                          iconColor: const Color(0xFF6366F1),
                          title: isHindi ? 'AI बिल स्कैनर' : 'AI OCR Scanner',
                          subtitle: isHindi ? 'स्मार्ट डेटा एक्सट्रैक्शन' : 'Instant invoice extraction',
                          isDark: isDark,
                        ),
                        const SizedBox(width: 10),
                        _buildFeatureCard(
                          icon: Icons.notifications_active_outlined,
                          iconColor: const Color(0xFFF59E0B),
                          title: isHindi ? 'वारंटी अलर्ट' : 'Warranty Alerts',
                          subtitle: isHindi ? 'समय पर रिमाइंडर' : 'Never miss free service',
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
                          subtitle: isHindi ? '256-Bit प्राइवेट बैकअप' : '256-Bit cloud backup',
                          isDark: isDark,
                        ),
                      ],
                    ),

                    const Spacer(flex: 2),

                    // 4. Professional "Continue with Google" Action Button
                    GlassCard(
                      borderRadius: 22,
                      padding: EdgeInsets.zero,
                      opacity: 0.88,
                      blur: 24,
                      onTap: _isLoading ? null : _handleGoogleSignIn,
                      shadows: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withAlpha(140)
                              : AppTheme.primary.withAlpha(45),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: _isLoading
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Text(
                                    isHindi ? 'Google से कनेक्ट हो रहे हैं...' : 'Signing in with Google...',
                                    style: AppTheme.font(
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
                                  // Authentic 4-Color Google Logo
                                  _buildGoogleLogo(),
                                  const SizedBox(width: 14),
                                  Text(
                                    'Continue with Google',
                                    style: AppTheme.font(
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

                    const SizedBox(height: 10),

                    // Demo / Guest Login button
                    TextButton(
                      onPressed: () async {
                        final nav = Navigator.of(context);
                        final provider = Provider.of<WarrantyProvider>(context, listen: false);
                        await provider.loginAsGuest();
                        if (!mounted) return;
                        nav.pushReplacement(
                          PageRouteBuilder(
                            transitionDuration: const Duration(milliseconds: 300),
                            pageBuilder: (_, animation, _) => const MainNavigationHost(),
                            transitionsBuilder: (_, animation, _, child) => FadeTransition(opacity: animation, child: child),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.play_circle_outline_rounded,
                            size: 16,
                            color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isHindi ? 'डेमो मोड में ऐप देखें (Explore Demo)' : 'Explore Demo / Guest Mode',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Subtext Helper
                    Text(
                      isHindi ? '1-Tap सुरक्षित Google साइन-इन • Cloud Firestore पर लाइव डेटा सिंक' : '1-Tap Google Sign-In • Real-Time Sync with Cloud Firestore',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // 5. Trust & Security Badges
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.verified_user_rounded, size: 14, color: AppTheme.success),
                        const SizedBox(width: 6),
                        Text(
                          isHindi ? 'Firebase & Google Cloud द्वारा सत्यापित • 100% सुरक्षित' : 'Firebase & Google Cloud Verified • 100% Encrypted',
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
      child: GlassCard(
        borderRadius: 18,
        padding: const EdgeInsets.all(12),
        opacity: 0.8,
        blur: 20,
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
