import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [Locale('en'), Locale('ar')];

  static AppLocalizations of(BuildContext context) {
    final instance = Localizations.of<AppLocalizations>(context, AppLocalizations);
    assert(instance != null, 'AppLocalizations not found in context');
    return instance!;
  }

  static const _localizedStrings = <String, Map<String, String>>{
    'en': {
      'onboarding_title_1': 'Discover & Compare',
      'signin': 'Sign In',
      'signup': 'Create Account',
      'continue_guest': 'Continue as Guest',
      'email': 'Email',
      'password': 'Password',
      'forgot_password': 'Forgot Password?',
      'search_hint': 'Search items...',
      'filters': 'Filters',
      'apply': 'Apply',
      'clear': 'Clear',
      'compare': 'Compare',
      'settings': 'Settings',
      'theme': 'Theme',
      'language': 'Language',
      'primary_color': 'Primary Color',
      'home_placeholder': 'Home Shell',
      'catalog_placeholder': 'Catalog Placeholder',
      'compare_placeholder': 'Compare Placeholder',
      'settings_placeholder': 'Settings Placeholder',
    },
    'ar': {
      'onboarding_title_1': 'اكتشف وقارن',
      'signin': 'تسجيل الدخول',
      'signup': 'إنشاء حساب',
      'continue_guest': 'الدخول كضيف',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'forgot_password': 'نسيت كلمة المرور؟',
      'search_hint': 'ابحث داخل العناصر...',
      'filters': 'الفلاتر',
      'apply': 'تطبيق',
      'clear': 'مسح',
      'compare': 'المقارنة',
      'settings': 'الإعدادات',
      'theme': 'المظهر',
      'language': 'اللغة',
      'primary_color': 'اللون الأساسي',
      'home_placeholder': 'الصفحة الرئيسية',
      'catalog_placeholder': 'كتالوج مبدئي',
      'compare_placeholder': 'واجهة المقارنة',
      'settings_placeholder': 'الإعدادات',
    },
  };

  String translate(String key) {
    final languageCode = locale.languageCode;
    final values = _localizedStrings[languageCode] ?? _localizedStrings['en']!;
    return values[key] ?? key;
  }

  static bool isSupported(Locale locale) {
    return supportedLocales.any((element) => element.languageCode == locale.languageCode);
  }

  static LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  @override
  bool isSupported(Locale locale) => AppLocalizations.isSupported(locale);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture(AppLocalizations(locale));
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}
