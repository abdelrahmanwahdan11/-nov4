import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../storage/app_preferences.dart';

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

  final AppPreferences _prefs;
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
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: _seedColor, brightness: brightness),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );

    return base.copyWith(
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
