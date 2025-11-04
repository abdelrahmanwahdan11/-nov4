import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';

class TutorialController extends ChangeNotifier {
  TutorialController(this._prefs) {
    _homeShown = _prefs.getBool(AppConstants.sharedPrefsTutorialHomeKey) ?? false;
    _catalogShown = _prefs.getBool(AppConstants.sharedPrefsTutorialCatalogKey) ?? false;
  }

  final SharedPreferences _prefs;
  late bool _homeShown;
  late bool _catalogShown;

  bool get homeShown => _homeShown;
  bool get catalogShown => _catalogShown;

  Future<void> setHomeShown(bool value) async {
    _homeShown = value;
    await _prefs.setBool(AppConstants.sharedPrefsTutorialHomeKey, value);
    notifyListeners();
  }

  Future<void> setCatalogShown(bool value) async {
    _catalogShown = value;
    await _prefs.setBool(AppConstants.sharedPrefsTutorialCatalogKey, value);
    notifyListeners();
  }

  Future<void> reset() async {
    _homeShown = false;
    _catalogShown = false;
    await _prefs.remove(AppConstants.sharedPrefsTutorialHomeKey);
    await _prefs.remove(AppConstants.sharedPrefsTutorialCatalogKey);
    notifyListeners();
  }
}
