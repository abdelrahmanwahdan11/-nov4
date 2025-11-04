import 'package:flutter/material.dart';

class AppConstants {
  const AppConstants._();

  static const defaultSeedColor = Color(0xFF4CAF50);
  static const supportedLocales = [Locale('en'), Locale('ar')];
  static const defaultLocale = Locale('en');

  static const sharedPrefsThemeModeKey = 'themeMode';
  static const sharedPrefsSeedColorKey = 'seedColor';
  static const sharedPrefsLocaleKey = 'localeCode';
  static const sharedPrefsFirstRunKey = 'firstRunCompleted';
  static const sharedPrefsGuestKey = 'isGuest';
  static const sharedPrefsSlowNetworkKey = 'slowNetwork';
  static const sharedPrefsTutorialHomeKey = 'tutorialHomeShown';
  static const sharedPrefsTutorialCatalogKey = 'tutorialCatalogShown';

  static const pageSizeFoods = 20;
  static const pageSizeCars = 10;

  static const double tabletBreakpoint = 768;
  static const double desktopBreakpoint = 1100;

  static const primaryColorPalette = [
    Color(0xFF4CAF50),
    Color(0xFF009688),
    Color(0xFF8BC34A),
    Color(0xFF03A9F4),
    Color(0xFFFF9800),
    Color(0xFFE91E63),
    Color(0xFF9C27B0),
  ];

  static const carSortOptions = [
    'price_asc',
    'price_desc',
    'power_desc',
    'range_desc',
  ];
}
