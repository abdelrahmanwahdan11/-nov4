import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ayna_catalog/core/theme/tokens.dart';

class AppController extends ChangeNotifier {
  AppController._(this._prefs);

  static const _themeModeKey = 'themeMode';
  static const _primaryColorKey = 'primaryColorHex';
  static const _localeKey = 'localeCode';
  static const _guestModeKey = 'guestMode';
  static const _favoritesKey = 'favorites';
  static const _compareListKey = 'compareList';
  static const String buildPhaseKey = 'buildPhaseIndex';

  final SharedPreferences _prefs;

  late ThemeMode _themeMode;
  late Locale _locale;
  late Color _primaryColor;
  bool _guestMode = false;
  final ValueNotifier<int> rebuildTick = ValueNotifier<int>(0);

  final Set<String> _favorites = <String>{};
  final Set<String> _compareList = <String>{};

  static Future<AppController> initialize(SharedPreferences prefs) async {
    final controller = AppController._(prefs);
    controller._hydrate();
    return controller;
  }

  void _hydrate() {
    final themeValue = _prefs.getString(_themeModeKey);
    _themeMode = _themeModeFromString(themeValue) ?? ThemeMode.system;

    final localeValue = _prefs.getString(_localeKey);
    _locale = switch (localeValue) {
      'ar' => const Locale('ar'),
      _ => const Locale('en'),
    };

    final colorHex = _prefs.getInt(_primaryColorKey);
    _primaryColor = colorHex != null ? Color(colorHex) : AppColors.seed;

    _guestMode = _prefs.getBool(_guestModeKey) ?? false;

    final favoritesJson = _prefs.getString(_favoritesKey);
    if (favoritesJson != null) {
      _favorites
        ..clear()
        ..addAll(List<String>.from(jsonDecode(favoritesJson) as List<dynamic>));
    }

    final compareJson = _prefs.getString(_compareListKey);
    if (compareJson != null) {
      _compareList
        ..clear()
        ..addAll(List<String>.from(jsonDecode(compareJson) as List<dynamic>));
    }
  }

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  Color get primaryColor => _primaryColor;
  bool get guestMode => _guestMode;
  Set<String> get favorites => Set.unmodifiable(_favorites);
  Set<String> get compareList => Set.unmodifiable(_compareList);
  int get buildPhaseIndex => _prefs.getInt(buildPhaseKey) ?? 0;

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    _prefs.setString(_themeModeKey, mode.name);
    notifyListeners();
  }

  void setLocale(Locale locale) {
    if (_locale == locale) return;
    _locale = locale;
    _prefs.setString(_localeKey, locale.languageCode);
    notifyListeners();
  }

  void setPrimaryColor(Color color) {
    if (_primaryColor == color) return;
    _primaryColor = color;
    _prefs.setInt(_primaryColorKey, color.value);
    notifyListeners();
  }

  void setGuestMode(bool value) {
    if (_guestMode == value) return;
    _guestMode = value;
    _prefs.setBool(_guestModeKey, value);
    notifyListeners();
  }

  void toggleFavorite(String id) {
    if (_favorites.contains(id)) {
      _favorites.remove(id);
    } else {
      _favorites.add(id);
    }
    _persistSet(_favoritesKey, _favorites);
    notifyListeners();
  }

  void toggleCompare(String id) {
    if (_compareList.contains(id)) {
      _compareList.remove(id);
    } else {
      _compareList.add(id);
    }
    _persistSet(_compareListKey, _compareList);
    notifyListeners();
  }

  void ping([int code = 0]) {
    rebuildTick.value = rebuildTick.value + 1 + code;
  }

  void markPhaseProgress(int value) {
    final int? currentValue = _prefs.getInt(buildPhaseKey);
    if (currentValue == value) {
      return;
    }
    _prefs.setInt(buildPhaseKey, value);
  }

  void _persistSet(String key, Set<String> values) {
    _prefs.setString(key, jsonEncode(values.toList()));
  }

  ThemeMode? _themeModeFromString(String? value) {
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => null,
    };
  }
}
