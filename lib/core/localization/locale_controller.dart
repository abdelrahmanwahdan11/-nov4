import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../storage/app_preferences.dart';

class LocaleController extends ChangeNotifier {
  LocaleController(this._prefs) {
    final code = _prefs.getString(AppConstants.sharedPrefsLocaleKey);
    if (code != null) {
      _locale = Locale(code);
    }
  }

  final AppPreferences _prefs;
  Locale _locale = AppConstants.defaultLocale;

  Locale get locale => _locale;

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    await _prefs.setString(AppConstants.sharedPrefsLocaleKey, locale.languageCode);
    notifyListeners();
  }

  bool get isArabic => _locale.languageCode == 'ar';
}
