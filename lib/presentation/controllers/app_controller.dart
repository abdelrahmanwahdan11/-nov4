import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/theme_tokens.dart';

enum ConnectionOverride { normal, offline, error }

class AppController extends ChangeNotifier {
  AppController();

  static const _themeModeKey = 'theme_mode';
  static const _localeKey = 'locale';
  static const _primarySeedKey = 'primary_seed';
  static const _firstRunKey = 'first_run';
  static const _guestKey = 'guest_mode';
  static const _seenOnboardingKey = 'seen_onboarding';
  static const _connectionKey = 'connection_override';
  static const _catalogLayoutKey = 'catalog_layout';
  static const _contentDensityKey = 'content_density';

  ThemeMode _themeMode = ThemeMode.system;
  Locale? _locale;
  Color _primarySeed = ThemeTokens.seedPrimary;
  bool _firstRun = true;
  bool _isGuest = false;
  bool _seenOnboarding = false;
  SharedPreferences? _prefs;
  Completer<void>? _initCompleter;
  final ValueNotifier<ConnectionOverride> connectionOverride =
      ValueNotifier<ConnectionOverride>(ConnectionOverride.normal);
  final ValueNotifier<bool> catalogGridMode = ValueNotifier<bool>(true);
  final ValueNotifier<ContentDensity> contentDensity =
      ValueNotifier<ContentDensity>(ContentDensity.comfortable);

  ThemeMode get themeMode => _themeMode;
  Locale? get locale => _locale;
  Color get primarySeed => _primarySeed;
  bool get firstRun => _firstRun;
  bool get isGuest => _isGuest;
  bool get seenOnboarding => _seenOnboarding;
  bool get isInitialized => _prefs != null;

  Future<void> initialize() {
    if (_initCompleter != null) {
      return _initCompleter!.future;
    }
    _initCompleter = Completer<void>();
    _loadPreferences();
    return _initCompleter!.future;
  }

  Future<void> _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    final prefs = _prefs!;

    final themeValue = prefs.getString(_themeModeKey);
    switch (themeValue) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      default:
        _themeMode = ThemeMode.system;
    }

    final localeValue = prefs.getString(_localeKey);
    if (localeValue != null) {
      _locale = Locale(localeValue);
    }

    final seedValue = prefs.getInt(_primarySeedKey);
    if (seedValue != null) {
      _primarySeed = Color(seedValue);
    }

    _firstRun = prefs.getBool(_firstRunKey) ?? true;
    _isGuest = prefs.getBool(_guestKey) ?? false;
    _seenOnboarding = prefs.getBool(_seenOnboardingKey) ?? false;
    final connectionValue = prefs.getString(_connectionKey);
    connectionOverride.value = switch (connectionValue) {
      'offline' => ConnectionOverride.offline,
      'error' => ConnectionOverride.error,
      _ => ConnectionOverride.normal,
    };

    final layoutValue = prefs.getString(_catalogLayoutKey);
    catalogGridMode.value = layoutValue != 'list';

    final densityValue = prefs.getString(_contentDensityKey);
    contentDensity.value = densityValue == 'compact'
        ? ContentDensity.compact
        : ContentDensity.comfortable;

    _initCompleter?.complete();
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _prefs?.setString(
      _themeModeKey,
      switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        _ => 'system',
      },
    );
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    await _prefs?.setString(_localeKey, locale.languageCode);
    notifyListeners();
  }

  Future<void> setPrimarySeed(Color color) async {
    _primarySeed = color;
    await _prefs?.setInt(_primarySeedKey, color.value);
    notifyListeners();
  }

  Future<void> markFirstRunComplete() async {
    _firstRun = false;
    await _prefs?.setBool(_firstRunKey, false);
    notifyListeners();
  }

  Future<void> setGuestMode(bool value) async {
    _isGuest = value;
    await _prefs?.setBool(_guestKey, value);
    notifyListeners();
  }

  Future<void> setSeenOnboarding(bool value) async {
    _seenOnboarding = value;
    await _prefs?.setBool(_seenOnboardingKey, value);
    notifyListeners();
  }

  Future<void> resetFirstRun() async {
    _firstRun = true;
    await _prefs?.setBool(_firstRunKey, true);
    notifyListeners();
  }

  Future<void> setConnectionOverride(ConnectionOverride value) async {
    connectionOverride.value = value;
    await _prefs?.setString(
      _connectionKey,
      switch (value) {
        ConnectionOverride.offline => 'offline',
        ConnectionOverride.error => 'error',
        ConnectionOverride.normal => 'normal',
      },
    );
    notifyListeners();
  }

  Future<void> setCatalogGridMode(bool isGrid) async {
    catalogGridMode.value = isGrid;
    await _prefs?.setString(_catalogLayoutKey, isGrid ? 'grid' : 'list');
    notifyListeners();
  }

  Future<void> setContentDensity(ContentDensity density) async {
    contentDensity.value = density;
    await _prefs?.setString(
      _contentDensityKey,
      density == ContentDensity.compact ? 'compact' : 'comfortable',
    );
    notifyListeners();
  }

  @override
  void dispose() {
    connectionOverride.dispose();
    catalogGridMode.dispose();
    contentDensity.dispose();
    super.dispose();
  }
}

class AppScope extends InheritedNotifier<AppController> {
  const AppScope({required super.child, required AppController controller, super.key})
      : super(notifier: controller);

  static AppController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found in context');
    return scope!.notifier!;
  }
}
