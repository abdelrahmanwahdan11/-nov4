import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../storage/app_preferences.dart';

class AppStore extends ChangeNotifier {
  AppStore(this._prefs) {
    final savedTheme = _prefs.getString(AppConstants.sharedPrefsThemeModeKey);
    if (savedTheme != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (mode) => mode.name == savedTheme,
        orElse: () => ThemeMode.system,
      );
    }

    final savedLocaleCode = _prefs.getString(AppConstants.sharedPrefsLocaleKey);
    if (savedLocaleCode != null) {
      final candidate = AppConstants.supportedLocales
          .firstWhere((locale) => locale.languageCode == savedLocaleCode, orElse: () => AppConstants.defaultLocale);
      _locale = candidate;
    }

    final seedValue = _prefs.getInt(AppConstants.sharedPrefsSeedColorKey);
    if (seedValue != null) {
      _seedColor = Color(seedValue);
    }
  }

  final AppPreferences _prefs;

  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = AppConstants.defaultLocale;
  Color _seedColor = AppConstants.defaultSeedColor;

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  Color get seedColor => _seedColor;

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == _themeMode) return;
    _themeMode = mode;
    await _prefs.setString(AppConstants.sharedPrefsThemeModeKey, mode.name);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    await _prefs.setString(AppConstants.sharedPrefsLocaleKey, locale.languageCode);
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
    _locale = AppConstants.defaultLocale;
    _seedColor = AppConstants.defaultSeedColor;
    await _prefs.remove(AppConstants.sharedPrefsThemeModeKey);
    await _prefs.remove(AppConstants.sharedPrefsLocaleKey);
    await _prefs.remove(AppConstants.sharedPrefsSeedColorKey);
    notifyListeners();
  }

  ThemeData buildTheme(Brightness brightness) {
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

class AppStoreScope extends InheritedNotifier<AppStore> {
  const AppStoreScope({
    super.key,
    required AppStore store,
    required super.child,
  }) : super(notifier: store);

  static AppStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStoreScope>();
    assert(scope != null, 'No AppStoreScope found in context');
    return scope!.notifier!;
  }

  static AppStore read(BuildContext context) {
    final scope = context.getElementForInheritedWidgetOfExactType<AppStoreScope>()?.widget as AppStoreScope?;
    assert(scope != null, 'No AppStoreScope found in context');
    return scope!.notifier!;
  }
}
