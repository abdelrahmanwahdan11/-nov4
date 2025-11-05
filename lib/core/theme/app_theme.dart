import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:ayna_catalog/core/theme/tokens.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light({
    required Locale locale,
    required Color seed,
  }) {
    const brightness = Brightness.light;
    final palette = AppColors.of(brightness);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
      background: palette.background,
      surface: palette.surface,
      primary: palette.primary,
    );

    return _baseTheme(
      locale: locale,
      colorScheme: colorScheme,
      brightness: brightness,
    );
  }

  static ThemeData dark({
    required Locale locale,
    required Color seed,
  }) {
    const brightness = Brightness.dark;
    final palette = AppColors.of(brightness);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
      background: palette.background,
      surface: palette.surface,
      primary: palette.primary,
    );

    return _baseTheme(
      locale: locale,
      colorScheme: colorScheme,
      brightness: brightness,
    );
  }

  static ThemeData _baseTheme({
    required Locale locale,
    required ColorScheme colorScheme,
    required Brightness brightness,
  }) {
    final palette = AppColors.of(brightness);
    final typography = _textTheme(locale: locale, base: colorScheme);

    final cardTheme = CardTheme(
      clipBehavior: Clip.antiAlias,
      color: palette.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: AppRadii.lgAll),
    );

    final inputBorder = OutlineInputBorder(
      borderRadius: AppRadii.mdAll,
      borderSide: BorderSide(color: palette.border),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: palette.background,
      cardTheme: cardTheme,
      textTheme: typography,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: palette.textPrimary,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
        ),
        errorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: palette.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        labelStyle: typography.bodyMedium?.copyWith(color: palette.textSecondary),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: palette.icon,
          minimumSize: const Size.square(40),
          padding: const EdgeInsets.all(AppSpacing.xs),
          shape: RoundedRectangleBorder(borderRadius: AppRadii.mdAll),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          foregroundColor: colorScheme.onPrimary,
          backgroundColor: colorScheme.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.lgAll),
        ).copyWith(
          overlayColor: MaterialStateProperty.resolveWith(
            (states) => colorScheme.primary.withOpacity(
              states.contains(MaterialState.pressed) ? 0.12 : 0.08,
            ),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.lgAll),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.lgAll),
          side: BorderSide(color: palette.border),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: palette.surfaceVariant,
        selectedColor: colorScheme.primaryContainer,
        shape: const StadiumBorder(),
        labelStyle: typography.labelMedium,
        side: BorderSide(color: palette.border),
      ),
      dividerColor: palette.border,
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: palette.surface.withOpacity(0.92),
        elevation: 0,
        height: 72,
        indicatorColor: colorScheme.primary.withOpacity(0.12),
        iconTheme: MaterialStateProperty.all(IconThemeData(color: palette.icon)),
        labelTextStyle: MaterialStateProperty.all(
          typography.labelMedium?.copyWith(color: palette.textSecondary),
        ),
      ),
    );
  }

  static TextTheme _textTheme({
    required Locale locale,
    required ColorScheme base,
  }) {
    final isArabic = locale.languageCode.toLowerCase() == 'ar';
    final textTheme = isArabic
        ? GoogleFonts.cairoTextTheme()
        : GoogleFonts.interTextTheme();

    return textTheme.apply(
      bodyColor: base.onBackground,
      displayColor: base.onBackground,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }
}
