import 'package:flutter/material.dart';

class ThemeTokens {
  const ThemeTokens._();

  static const Color seedPrimary = Color(0xFF45D16E);

  static const _lightBackground = Color(0xFFEAF7EF);
  static const _lightSurface = Color(0xFFFFFFFF);
  static const _lightTextPrimary = Color(0xFF0B0B0B);
  static const _lightTextSecondary = Color(0xFF2E3A2F);
  static const _lightChip = Color(0xFFDDF6E7);
  static const _lightPillBg = Color(0xFF000000);
  static const _lightPillFg = Color(0xFFFFFFFF);

  static const _darkBackground = Color(0xFF0E1210);
  static const _darkSurface = Color(0xFF151A17);
  static const _darkTextPrimary = Color(0xFFFFFFFF);
  static const _darkTextSecondary = Color(0xFFC9D2CB);
  static const _darkChip = Color(0xFF1E2621);
  static const _darkPillBg = Color(0xFFFFFFFF);
  static const _darkPillFg = Color(0xFF000000);

  static const double cornerRadius = 24;

  static const String fontFamily = 'PlusJakartaSans';

  static ThemeData tokensToTheme(
    Brightness brightness, {
    required Color seed,
  }) {
    final isLight = brightness == Brightness.light;
    final background = isLight ? _lightBackground : _darkBackground;
    final surface = isLight ? _lightSurface : _darkSurface;
    final textPrimary = isLight ? _lightTextPrimary : _darkTextPrimary;
    final textSecondary = isLight ? _lightTextSecondary : _darkTextSecondary;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
    );

    final textTheme = ThemeData(brightness: brightness).textTheme.apply(
          fontFamily: fontFamily,
          bodyColor: textPrimary,
          displayColor: textPrimary,
        );

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      cardTheme: CardTheme(
        color: surface,
        surfaceTintColor: colorScheme.surfaceTint,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cornerRadius),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isLight ? _lightChip : _darkChip,
        shape: StadiumBorder(
          side: BorderSide.none,
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(color: textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: isLight ? _lightPillFg : _darkPillFg,
          backgroundColor: isLight ? _lightPillBg : _darkPillBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(cornerRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: seed.withOpacity(0.15),
        labelTextStyle: MaterialStateProperty.all(
          textTheme.labelMedium?.copyWith(color: textSecondary),
        ),
      ),
    );
  }
}
