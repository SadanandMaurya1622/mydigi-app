import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? tintColor;
  final double opacity;
  final double blur;
  final Border? border;
  final VoidCallback? onTap;
  final List<BoxShadow>? shadows;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 22,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.tintColor,
    this.opacity = 0.75,
    this.blur = 20,
    this.border,
    this.onTap,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final baseColor = isDark
        ? const Color(0xFF1E293B)
        : Colors.white;

    final effectiveColor = tintColor != null
        ? tintColor!.withAlpha((tintColor!.a * 255.0 * opacity).round().clamp(0, 255))
        : baseColor.withAlpha(isDark ? (255 * 0.70).toInt() : (255 * 0.82).toInt());

    final effectiveBorder = border ??
        Border.all(
          color: isDark
              ? Colors.white.withAlpha(25)
              : Colors.white.withAlpha(220),
          width: 1.2,
        );

    final defaultShadows = shadows ??
        [
          BoxShadow(
            color: isDark
                ? Colors.black.withAlpha(120)
                : AppTheme.primary.withAlpha(18),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: isDark
                ? const Color(0xFF1E1B4B).withAlpha(40)
                : Colors.black.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ];

    Widget content = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: effectiveColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: effectiveBorder,
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: content,
        ),
      );
    }

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: defaultShadows,
      ),
      child: content,
    );
  }
}

class GlassScaffoldBackground extends StatelessWidget {
  final Widget child;

  const GlassScaffoldBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // Ambient Mesh Gradient Background
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        const Color(0xFF090D16),
                        const Color(0xFF0F172A),
                        const Color(0xFF131127),
                      ]
                    : [
                        const Color(0xFFF1F5F9),
                        const Color(0xFFEEF2FF),
                        const Color(0xFFF8FAFC),
                      ],
              ),
            ),
          ),
        ),

        // Glowing Ambient Light Orbs (Top Right & Bottom Left)
        Positioned(
          top: -80,
          right: -80,
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  (isDark ? const Color(0xFF4F46E5) : const Color(0xFF818CF8)).withAlpha(isDark ? 55 : 45),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 300,
          left: -100,
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  (isDark ? const Color(0xFF7C3AED) : const Color(0xFFA78BFA)).withAlpha(isDark ? 40 : 35),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 80,
          right: -60,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  (isDark ? const Color(0xFF0EA5E9) : const Color(0xFF38BDF8)).withAlpha(isDark ? 45 : 30),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Main content
        Positioned.fill(child: child),
      ],
    );
  }
}
