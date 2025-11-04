import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  AppLocalizations(this.locale, this._values);

  final Locale locale;
  final Map<String, String> _values;

  static const supportedLocales = ['en', 'ar'];

  String translate(String key) => _values[key] ?? key;

  static Future<AppLocalizations> load(Locale locale) async {
    final languageCode = supportedLocales.contains(locale.languageCode)
        ? locale.languageCode
        : supportedLocales.first;
    final data = await rootBundle.loadString('assets/locale/$languageCode.json');
    final Map<String, dynamic> decoded = json.decode(data) as Map<String, dynamic>;
    final values = decoded.map(
      (key, value) => MapEntry(key, value.toString()),
    );
    return AppLocalizations(locale, values);
  }

  static AppLocalizations of(BuildContext context) {
    final delegate = Localizations.of<AppLocalizations>(context, AppLocalizations);
    assert(delegate != null, 'AppLocalizations not found in context');
    return delegate!;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations.supportedLocales.contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) => AppLocalizations.load(locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}
