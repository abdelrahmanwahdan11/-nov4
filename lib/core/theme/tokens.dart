import 'package:flutter/material.dart';

class AppTokens {
  AppTokens._();

  static const radius = _RadiusTokens();
  static const spacing = _SpacingTokens();
  static const motion = _MotionTokens();
  static const gradients = _GradientTokens();

  static const lightColors = _ColorPalette(
    background: Color(0xFFF7F8FA),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFFAFBFC),
    border: Color(0xFFE8EDF2),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF475569),
    textTertiary: Color(0xFF94A3B8),
    primary: Color(0xFF2BAA7D),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFE7F4EE),
    success: Color(0xFF22C55E),
    error: Color(0xFFF04438),
    warning: Color(0xFFF59E0B),
    info: Color(0xFF0EA5E9),
    icon: Color(0xFF98A2B3),
    muted: Color(0xFFF1F5F9),
  );

  static const darkColors = _ColorPalette(
    background: Color(0xFF0E1114),
    surface: Color(0xFF111417),
    surfaceVariant: Color(0xFF151A1E),
    border: Color(0xFF2B3238),
    textPrimary: Color(0xFFE6EAF0),
    textSecondary: Color(0xFFB3BEC8),
    textTertiary: Color(0xFF6B7280),
    primary: Color(0xFF8FD9BC),
    onPrimary: Color(0xFF0B1210),
    primaryContainer: Color(0xFF173229),
    success: Color(0xFF22C55E),
    error: Color(0xFFF87171),
    warning: Color(0xFFFBBF24),
    info: Color(0xFF38BDF8),
    icon: Color(0xFF9AA6B2),
    muted: Color(0xFF1C2329),
  );
}

class _RadiusTokens {
  const _RadiusTokens();
  BorderRadius get xs => BorderRadius.circular(10);
  BorderRadius get sm => BorderRadius.circular(12);
  BorderRadius get md => BorderRadius.circular(16);
  BorderRadius get lg => BorderRadius.circular(20);
  BorderRadius get xl => BorderRadius.circular(24);
}

class _SpacingTokens {
  const _SpacingTokens();
  double get xxs => 4;
  double get xs => 8;
  double get sm => 12;
  double get md => 16;
  double get lg => 20;
  double get xl => 24;
  double get xxl => 32;
}

class _MotionTokens {
  const _MotionTokens();
  Duration get fast => const Duration(milliseconds: 150);
  Duration get normal => const Duration(milliseconds: 250);
  Duration get slow => const Duration(milliseconds: 400);
  Curve get curve => Curves.easeInOutCubic;
}

class _GradientTokens {
  const _GradientTokens();

  Gradient headerLight = const RadialGradient(
    colors: [Color(0xFFEAF7F1), Color(0xFFF7EAEA), Color(0xFFFFFFFF)],
    stops: [0.0, 0.42, 1.0],
    center: Alignment(0.5, -0.2),
    radius: 1.2,
  );

  Gradient headerDark = const RadialGradient(
    colors: [Color(0xFF0F241C), Color(0xFF1C1414), Color(0xFF0E1114)],
    stops: [0.0, 0.46, 1.0],
    center: Alignment(0.5, -0.2),
    radius: 1.2,
  );
}

class _ColorPalette {
  const _ColorPalette({
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.success,
    required this.error,
    required this.warning,
    required this.info,
    required this.icon,
    required this.muted,
  });

  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color success;
  final Color error;
  final Color warning;
  final Color info;
  final Color icon;
  final Color muted;
}
