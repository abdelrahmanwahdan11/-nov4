import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/storage/app_preferences.dart';

class TutorialState {
  const TutorialState({
    required this.homeShown,
    required this.catalogShown,
  });

  final bool homeShown;
  final bool catalogShown;

  TutorialState copyWith({bool? homeShown, bool? catalogShown}) {
    return TutorialState(
      homeShown: homeShown ?? this.homeShown,
      catalogShown: catalogShown ?? this.catalogShown,
    );
  }
}

class TutorialController extends ValueNotifier<TutorialState> {
  TutorialController(this._prefs)
      : super(TutorialState(
          homeShown: _prefs.getBool(AppConstants.sharedPrefsTutorialHomeKey) ?? false,
          catalogShown: _prefs.getBool(AppConstants.sharedPrefsTutorialCatalogKey) ?? false,
        ));

  final AppPreferences _prefs;

  bool get homeShown => value.homeShown;
  bool get catalogShown => value.catalogShown;

  Future<void> setHomeShown(bool shown) async {
    value = value.copyWith(homeShown: shown);
    await _prefs.setBool(AppConstants.sharedPrefsTutorialHomeKey, shown);
  }

  Future<void> setCatalogShown(bool shown) async {
    value = value.copyWith(catalogShown: shown);
    await _prefs.setBool(AppConstants.sharedPrefsTutorialCatalogKey, shown);
  }

  Future<void> reset() async {
    value = value.copyWith(homeShown: false, catalogShown: false);
    await _prefs.remove(AppConstants.sharedPrefsTutorialHomeKey);
    await _prefs.remove(AppConstants.sharedPrefsTutorialCatalogKey);
  }
}
