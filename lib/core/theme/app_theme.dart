import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'tokens.dart';

class AppTheme {
  AppTheme._();

  static ThemeData lightTheme() => _themeFromPalette(AppTokens.lightColors, Brightness.light);
  static ThemeData darkTheme() => _themeFromPalette(AppTokens.darkColors, Brightness.dark);

  static ThemeData _themeFromPalette(_ColorPalette palette, Brightness brightness) {
    final base = ThemeData(brightness: brightness, useMaterial3: true);
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: palette.primary,
      onPrimary: palette.onPrimary,
      secondary: palette.primary,
      onSecondary: palette.onPrimary,
      error: palette.error,
      onError: palette.onPrimary,
      background: palette.background,
      onBackground: palette.textPrimary,
      surface: palette.surface,
      onSurface: palette.textPrimary,
      surfaceVariant: palette.surfaceVariant,
      onSurfaceVariant: palette.textSecondary,
      tertiary: palette.info,
      onTertiary: palette.onPrimary,
      tertiaryContainer: palette.primaryContainer,
      outline: palette.border,
      outlineVariant: palette.border,
      inversePrimary: palette.primary,
      shadow: Colors.black.withOpacity(brightness == Brightness.light ? 0.1 : 0.6),
      scrim: Colors.black,
      primaryContainer: palette.primaryContainer,
      secondaryContainer: palette.primaryContainer,
      onSecondaryContainer: palette.textPrimary,
      errorContainer: palette.error.withOpacity(0.12),
      onErrorContainer: palette.error,
      surfaceTint: palette.primary,
    );

    final textTheme = _buildTextTheme(base.textTheme, palette);

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: palette.background,
      canvasColor: palette.background,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      iconTheme: IconThemeData(color: palette.icon),
      dividerColor: palette.border,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: palette.textPrimary,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 96,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardTheme(
        color: palette.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppTokens.radius.lg),
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          elevation: const WidgetStatePropertyAll(0),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return palette.primary.withOpacity(0.4);
            }
            return palette.primary;
          }),
          foregroundColor: WidgetStatePropertyAll(palette.onPrimary),
          padding: WidgetStateProperty.all(
            EdgeInsets.symmetric(
              horizontal: AppTokens.spacing.xl,
              vertical: AppTokens.spacing.sm,
            ),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: AppTokens.radius.md),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(color: palette.border, thickness: 1, space: 1),
      listTileTheme: ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: AppTokens.spacing.md),
        iconColor: palette.icon,
        textColor: palette.textPrimary,
      ),
      switchTheme: SwitchThemeData(
        trackOutlineWidth: const WidgetStatePropertyAll(0),
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return palette.onPrimary;
          }
          return palette.icon;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return palette.primary;
          }
          return palette.muted;
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: palette.surfaceVariant,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: palette.textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppTokens.radius.md),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: AppTokens.radius.lg.topLeft)),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppTokens.radius.lg),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: palette.surface.withOpacity(0.94),
        indicatorColor: palette.primary.withOpacity(0.15),
        elevation: 0,
        height: 74,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: AppTokens.radius.md,
          borderSide: BorderSide(color: palette.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppTokens.radius.md,
          borderSide: BorderSide(color: palette.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppTokens.radius.md,
          borderSide: BorderSide(color: palette.primary, width: 1.5),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppTokens.spacing.md,
          vertical: AppTokens.spacing.sm,
        ),
      ),
    );
  }

  static TextTheme _buildTextTheme(TextTheme base, _ColorPalette palette) {
    TextTheme interTheme = GoogleFonts.interTextTheme(base);
    TextStyle _style(double size, FontWeight weight, double letterSpacing) {
      return TextStyle(
        fontSize: size,
        fontWeight: weight,
        letterSpacing: letterSpacing,
        color: palette.textPrimary,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
    }

    return interTheme.copyWith(
      displayLarge: _style(42, FontWeight.w700, -0.2),
      displayMedium: _style(32, FontWeight.w600, -0.1),
      displaySmall: _style(28, FontWeight.w600, -0.1),
      headlineLarge: _style(24, FontWeight.w600, -0.1),
      headlineMedium: _style(22, FontWeight.w600, -0.1),
      headlineSmall: _style(20, FontWeight.w600, -0.1),
      titleLarge: _style(18, FontWeight.w600, -0.1),
      titleMedium: _style(15, FontWeight.w500, 0.0),
      titleSmall: _style(13, FontWeight.w500, 0.0),
      bodyLarge: _style(15, FontWeight.w500, 0.0),
      bodyMedium: _style(14, FontWeight.w500, 0.0),
      bodySmall: _style(12, FontWeight.w400, 0.0),
      labelLarge: _style(14, FontWeight.w600, 0.0),
      labelMedium: _style(12, FontWeight.w500, 0.0),
      labelSmall: _style(11, FontWeight.w500, 0.0),
    );
  }
}
