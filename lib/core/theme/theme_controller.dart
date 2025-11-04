import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

class ThemeController extends ChangeNotifier {
  ThemeController(this._prefs) {
    final savedMode = _prefs.getString(AppConstants.sharedPrefsThemeModeKey);
    if (savedMode != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (mode) => mode.name == savedMode,
        orElse: () => ThemeMode.system,
      );
    }
    final colorValue = _prefs.getInt(AppConstants.sharedPrefsSeedColorKey);
    if (colorValue != null) {
      _seedColor = Color(colorValue);
    }
  }

  final SharedPreferences _prefs;
  ThemeMode _themeMode = ThemeMode.system;
  Color _seedColor = AppConstants.defaultSeedColor;

  ThemeMode get themeMode => _themeMode;
  Color get seedColor => _seedColor;

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == _themeMode) return;
    _themeMode = mode;
    await _prefs.setString(AppConstants.sharedPrefsThemeModeKey, mode.name);
    notifyListeners();
  }

  Future<void> setSeedColor(Color color) async {
    if (_seedColor == color) return;
    _seedColor = color;
    await _prefs.setInt(AppConstants.sharedPrefsSeedColorKey, color.value);
    notifyListeners();
  }

  Future<void> resetDefaults() async {
    _themeMode = ThemeMode.system;
    _seedColor = AppConstants.defaultSeedColor;
    await _prefs.remove(AppConstants.sharedPrefsThemeModeKey);
    await _prefs.remove(AppConstants.sharedPrefsSeedColorKey);
    notifyListeners();
  }

  ThemeData buildTheme(Brightness brightness, Locale locale) {
    final typography = Typography.material2021(platform: TargetPlatform.android);
    final isArabic = locale.languageCode == 'ar';
    TextTheme withLocalizedFont(TextTheme baseTheme) =>
        isArabic ? GoogleFonts.cairoTextTheme(baseTheme) : GoogleFonts.poppinsTextTheme(baseTheme);

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: _seedColor, brightness: brightness),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );

    return base.copyWith(
      fontFamily: isArabic ? GoogleFonts.cairo().fontFamily : GoogleFonts.poppins().fontFamily,
      textTheme: withLocalizedFont(base.textTheme),
      primaryTextTheme: withLocalizedFont(base.primaryTextTheme),
      typography: typography.copyWith(
        black: withLocalizedFont(typography.black),
        white: withLocalizedFont(typography.white),
        englishLike: withLocalizedFont(typography.englishLike),
        dense: withLocalizedFont(typography.dense),
        tall: withLocalizedFont(typography.tall),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: SharedAxisPageTransitionsBuilder(transitionType: SharedAxisTransitionType.horizontal),
        TargetPlatform.iOS: SharedAxisPageTransitionsBuilder(transitionType: SharedAxisTransitionType.horizontal),
      }),
    );
  }
}
