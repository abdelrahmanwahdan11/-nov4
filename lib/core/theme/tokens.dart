import 'dart:ui';

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color seed = Color(0xFF2BAA7D);

  static const _light = _Palette(
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
    info: Color(0xFF38BDF8),
    icon: Color(0xFF64748B),
    muted: Color(0xFFE5E7EB),
  );

  static const _dark = _Palette(
    background: Color(0xFF0B1210),
    surface: Color(0xFF0E1114),
    surfaceVariant: Color(0xFF111518),
    border: Color(0xFF1F2937),
    textPrimary: Color(0xFFE6EDF5),
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

  static _Palette of(Brightness brightness) {
    return brightness == Brightness.dark ? _dark : _light;
  }
}

class AppSpacing {
  AppSpacing._();

  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
}

class AppRadii {
  AppRadii._();

  static const Radius xs = Radius.circular(10);
  static const Radius sm = Radius.circular(12);
  static const Radius md = Radius.circular(16);
  static const Radius lg = Radius.circular(20);
  static const Radius xl = Radius.circular(24);

  static const BorderRadius xsAll = BorderRadius.all(xs);
  static const BorderRadius smAll = BorderRadius.all(sm);
  static const BorderRadius mdAll = BorderRadius.all(md);
  static const BorderRadius lgAll = BorderRadius.all(lg);
  static const BorderRadius xlAll = BorderRadius.all(xl);
}

class AppMotion {
  AppMotion._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
  static const Curve standard = Curves.easeInOutCubic;
}

class AppGradients {
  AppGradients._();

  static const Gradient headerLight = RadialGradient(
    colors: [Color(0xFFEAF7F1), Color(0xFFF7EAEA), Color(0xFFFFFFFF)],
    stops: [0.0, 0.42, 1.0],
    center: Alignment(0.0, -0.2),
    radius: 1.2,
  );

  static const Gradient headerDark = RadialGradient(
    colors: [Color(0xFF0F241C), Color(0xFF1C1414), Color(0xFF0E1114)],
    stops: [0.0, 0.46, 1.0],
    center: Alignment(0.0, -0.2),
    radius: 1.2,
  );
}

class _Palette {
  const _Palette({
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
