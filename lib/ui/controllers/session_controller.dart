import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';

class SessionController extends ChangeNotifier {
  SessionController(this._prefs) {
    _isGuest = _prefs.getBool(AppConstants.sharedPrefsGuestKey) ?? false;
  }

  final SharedPreferences _prefs;
  bool _isGuest = false;

  bool get isGuest => _isGuest;

  Future<void> setGuest(bool value) async {
    _isGuest = value;
    await _prefs.setBool(AppConstants.sharedPrefsGuestKey, value);
    notifyListeners();
  }
}
