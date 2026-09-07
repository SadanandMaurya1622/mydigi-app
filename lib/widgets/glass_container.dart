import 'dart:ui';
import 'package:flutter/material.dart';

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
  final bool enableBlur;
  final bool isSolidGradient;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 22,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.tintColor,
    this.opacity = 0.75,
    this.blur = 0,
    this.border,
    this.onTap,
    this.shadows,
    this.enableBlur = false,
    this.isSolidGradient = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final baseColor = isDark
        ? const Color(0xFF1E293B)
        : Colors.white;

    final baseSecondary = isDark
        ? const Color(0xFF0F172A)
        : const Color(0xFFF8FAFC);

    final effectiveBorder = border ??
        Border.all(
          color: isDark
              ? const Color(0xFF334155).withAlpha(140)
              : const Color(0xFFE2E8F0),
          width: 1.0,
        );

    final defaultShadows = shadows ??
        [
          BoxShadow(
            color: isDark
                ? Colors.black.withAlpha(90)
                : Colors.black.withAlpha(12),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ];

    final List<Color> gradientColors;
    if (tintColor != null) {
      if (isSolidGradient) {
        gradientColors = [
          tintColor!.withAlpha(240),
          tintColor!.withAlpha(210),
        ];
      } else {
        gradientColors = [
          Color.alphaBlend(tintColor!.withAlpha(isDark ? 36 : 18), baseColor),
          Color.alphaBlend(tintColor!.withAlpha(isDark ? 20 : 10), baseSecondary),
        ];
      }
    } else {
      gradientColors = [
        baseColor,
        baseSecondary,
      ];
    }

    final cardDecoration = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: gradientColors,
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      border: effectiveBorder,
    );

    Widget innerContent = Container(
      padding: padding,
      decoration: cardDecoration,
      child: child,
    );

    // Only apply heavy BackdropFilter if explicitly requested and blur > 0 (e.g. Floating Navbar or Modals)
    Widget content;
    if (enableBlur && blur > 0) {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: innerContent,
        ),
      );
    } else {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: innerContent,
      );
    }

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
        // RepaintBoundary isolates ambient background so scrolling lists don't trigger GPU repaints
        RepaintBoundary(
          child: Stack(
            children: [
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
                        (isDark ? const Color(0xFF4F46E5) : const Color(0xFF818CF8)).withAlpha(isDark ? 45 : 35),
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
                        (isDark ? const Color(0xFF7C3AED) : const Color(0xFFA78BFA)).withAlpha(isDark ? 35 : 28),
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
                        (isDark ? const Color(0xFF0EA5E9) : const Color(0xFF38BDF8)).withAlpha(isDark ? 35 : 25),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Main content
        Positioned.fill(child: child),
      ],
    );
  }
}
