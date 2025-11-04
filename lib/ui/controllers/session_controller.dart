import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/storage/app_preferences.dart';

class SessionController extends ChangeNotifier {
  SessionController(this._prefs) {
    _isGuest = _prefs.getBool(AppConstants.sharedPrefsGuestKey) ?? false;
  }

  final AppPreferences _prefs;
  bool _isGuest = false;

  bool get isGuest => _isGuest;

  Future<void> setGuest(bool value) async {
    _isGuest = value;
    await _prefs.setBool(AppConstants.sharedPrefsGuestKey, value);
    notifyListeners();
  }
}
