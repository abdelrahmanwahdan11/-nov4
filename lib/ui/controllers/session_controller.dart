import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/storage/app_preferences.dart';

class SessionState {
  const SessionState({required this.isGuest});

  final bool isGuest;

  SessionState copyWith({bool? isGuest}) {
    return SessionState(isGuest: isGuest ?? this.isGuest);
  }
}

class SessionController extends ValueNotifier<SessionState> {
  SessionController(this._prefs)
      : super(SessionState(
          isGuest: _prefs.getBool(AppConstants.sharedPrefsGuestKey) ?? false,
        ));

  final AppPreferences _prefs;

  bool get isGuest => value.isGuest;

  Future<void> setGuest(bool isGuest) async {
    value = value.copyWith(isGuest: isGuest);
    await _prefs.setBool(AppConstants.sharedPrefsGuestKey, isGuest);
  }
}
