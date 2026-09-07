import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors
  static const Color primary = Color(0xFF4F46E5); // Indigo 600
  static const Color primaryDark = Color(0xFF6366F1); // Indigo 500
  static const Color primaryLight = Color(0xFFEEF2FF);
  
  static const Color secondary = Color(0xFF0EA5E9); // Sky 500
  static const Color accent = Color(0xFF8B5CF6); // Violet 500
  
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color danger = Color(0xFFEF4444); // Red 500
  static const Color info = Color(0xFF3B82F6); // Blue 500

  // High-contrast Neutral Colors Light (WCAG AAA compliant)
  static const Color bgLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Colors.white;
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color textMainLight = Color(0xFF0F172A); // Pitch Black/Dark Slate for maximum sharpness
  static const Color textMutedLight = Color(0xFF475569); // High-contrast Slate 600

  // High-contrast Neutral Colors Dark
  static const Color bgDark = Color(0xFF0B0F19);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color surfaceDarkHigher = Color(0xFF334155);
  static const Color borderDark = Color(0xFF334155);
  static const Color textMainDark = Color(0xFFFFFFFF); // Pure white for crystal clear readability
  static const Color textMutedDark = Color(0xFFCBD5E1); // Bright readable Slate 300

  static const List<String> fontFallbacks = [
    'Roboto',
    'Noto Sans Devanagari',
    'Noto Sans',
    'Arial',
    'sans-serif',
  ];

  static TextStyle font({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      decoration: decoration,
      fontFamilyFallback: fontFallbacks,
    );
  }

  // Hint Text Colors - Soft, lighter contrast for placeholders
  static const Color textHintLight = Color(0xFF94A3B8); // Slate 400 - gentle and light
  static const Color textHintDark = Color(0xFF64748B);  // Slate 500 - subtle on dark surfaces

  static Color textHint(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? textHintDark : textHintLight;
  }

  static Color textMain(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? textMainDark : textMainLight;
  }

  static Color textMuted(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? textMutedDark : textMutedLight;
  }

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorSchemeSeed: primary,
    scaffoldBackgroundColor: bgLight,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: textMainLight,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        fontFamilyFallback: fontFallbacks,
      ),
      iconTheme: IconThemeData(color: textMainLight),
    ),
    cardTheme: CardThemeData(
      color: surfaceLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: borderLight, width: 1),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surfaceLight,
      elevation: 3,
      indicatorColor: primaryLight,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: primary,
            fontFamilyFallback: fontFallbacks,
          );
        }
        return const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.normal,
          color: textMutedLight,
          fontFamilyFallback: fontFallbacks,
        );
      }),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      hintStyle: TextStyle(
        color: textHintLight,
        fontSize: 13,
        fontWeight: FontWeight.normal,
        fontFamilyFallback: fontFallbacks,
      ),
      labelStyle: TextStyle(
        color: textMutedLight,
        fontSize: 13,
        fontFamilyFallback: fontFallbacks,
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: textMainLight, fontWeight: FontWeight.bold, fontFamilyFallback: fontFallbacks),
      displayMedium: TextStyle(color: textMainLight, fontWeight: FontWeight.bold, fontFamilyFallback: fontFallbacks),
      displaySmall: TextStyle(color: textMainLight, fontWeight: FontWeight.bold, fontFamilyFallback: fontFallbacks),
      headlineLarge: TextStyle(color: textMainLight, fontWeight: FontWeight.w800, fontFamilyFallback: fontFallbacks),
      headlineMedium: TextStyle(color: textMainLight, fontWeight: FontWeight.w700, fontFamilyFallback: fontFallbacks),
      headlineSmall: TextStyle(color: textMainLight, fontWeight: FontWeight.w700, fontFamilyFallback: fontFallbacks),
      titleLarge: TextStyle(color: textMainLight, fontWeight: FontWeight.w700, fontSize: 18, fontFamilyFallback: fontFallbacks),
      titleMedium: TextStyle(color: textMainLight, fontWeight: FontWeight.w600, fontSize: 15, fontFamilyFallback: fontFallbacks),
      titleSmall: TextStyle(color: textMainLight, fontWeight: FontWeight.w600, fontSize: 13, fontFamilyFallback: fontFallbacks),
      bodyLarge: TextStyle(color: textMainLight, fontWeight: FontWeight.w500, fontSize: 15, fontFamilyFallback: fontFallbacks),
      bodyMedium: TextStyle(color: textMainLight, fontWeight: FontWeight.normal, fontSize: 13.5, fontFamilyFallback: fontFallbacks),
      bodySmall: TextStyle(color: textMutedLight, fontWeight: FontWeight.normal, fontSize: 12, fontFamilyFallback: fontFallbacks),
      labelLarge: TextStyle(color: textMainLight, fontWeight: FontWeight.w700, fontSize: 13, fontFamilyFallback: fontFallbacks),
      labelMedium: TextStyle(color: textMutedLight, fontWeight: FontWeight.w600, fontSize: 11.5, fontFamilyFallback: fontFallbacks),
      labelSmall: TextStyle(color: textMutedLight, fontWeight: FontWeight.w500, fontSize: 10, fontFamilyFallback: fontFallbacks),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorSchemeSeed: primaryDark,
    scaffoldBackgroundColor: bgDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: textMainDark,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        fontFamilyFallback: fontFallbacks,
      ),
      iconTheme: IconThemeData(color: textMainDark),
    ),
    cardTheme: CardThemeData(
      color: surfaceDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: borderDark, width: 1),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surfaceDark,
      elevation: 3,
      indicatorColor: primary.withAlpha(80),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: primaryDark,
            fontFamilyFallback: fontFallbacks,
          );
        }
        return const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.normal,
          color: textMutedDark,
          fontFamilyFallback: fontFallbacks,
        );
      }),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      hintStyle: TextStyle(
        color: textHintDark,
        fontSize: 13,
        fontWeight: FontWeight.normal,
        fontFamilyFallback: fontFallbacks,
      ),
      labelStyle: TextStyle(
        color: textMutedDark,
        fontSize: 13,
        fontFamilyFallback: fontFallbacks,
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: textMainDark, fontWeight: FontWeight.bold, fontFamilyFallback: fontFallbacks),
      displayMedium: TextStyle(color: textMainDark, fontWeight: FontWeight.bold, fontFamilyFallback: fontFallbacks),
      displaySmall: TextStyle(color: textMainDark, fontWeight: FontWeight.bold, fontFamilyFallback: fontFallbacks),
      headlineLarge: TextStyle(color: textMainDark, fontWeight: FontWeight.w800, fontFamilyFallback: fontFallbacks),
      headlineMedium: TextStyle(color: textMainDark, fontWeight: FontWeight.w700, fontFamilyFallback: fontFallbacks),
      headlineSmall: TextStyle(color: textMainDark, fontWeight: FontWeight.w700, fontFamilyFallback: fontFallbacks),
      titleLarge: TextStyle(color: textMainDark, fontWeight: FontWeight.w700, fontSize: 18, fontFamilyFallback: fontFallbacks),
      titleMedium: TextStyle(color: textMainDark, fontWeight: FontWeight.w600, fontSize: 15, fontFamilyFallback: fontFallbacks),
      titleSmall: TextStyle(color: textMainDark, fontWeight: FontWeight.w600, fontSize: 13, fontFamilyFallback: fontFallbacks),
      bodyLarge: TextStyle(color: textMainDark, fontWeight: FontWeight.w500, fontSize: 15, fontFamilyFallback: fontFallbacks),
      bodyMedium: TextStyle(color: textMainDark, fontWeight: FontWeight.normal, fontSize: 13.5, fontFamilyFallback: fontFallbacks),
      bodySmall: TextStyle(color: textMutedDark, fontWeight: FontWeight.normal, fontSize: 12, fontFamilyFallback: fontFallbacks),
      labelLarge: TextStyle(color: textMainDark, fontWeight: FontWeight.w700, fontSize: 13, fontFamilyFallback: fontFallbacks),
      labelMedium: TextStyle(color: textMutedDark, fontWeight: FontWeight.w600, fontSize: 11.5, fontFamilyFallback: fontFallbacks),
      labelSmall: TextStyle(color: textMutedDark, fontWeight: FontWeight.w500, fontSize: 10, fontFamilyFallback: fontFallbacks),
    ),
  );
}
