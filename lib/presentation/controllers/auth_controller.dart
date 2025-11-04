import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_controller.dart';

class AuthController extends ChangeNotifier {
  AuthController({required this.appController});

  final AppController appController;

  static const _userEmailKey = 'auth_user_email';

  SharedPreferences? _prefs;
  Completer<void>? _initCompleter;
  bool _isAuthenticated = false;
  String? _email;

  bool get isAuthenticated => _isAuthenticated;
  String? get email => _email;
  bool get isGuest => appController.isGuest;

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
    final storedEmail = _prefs!.getString(_userEmailKey);
    final isGuest = appController.isGuest;
    if (storedEmail != null && storedEmail.isNotEmpty && !isGuest) {
      _isAuthenticated = true;
      _email = storedEmail;
    } else {
      _isAuthenticated = false;
      _email = null;
      if (isGuest) {
        await _prefs!.remove(_userEmailKey);
      }
    }
    _initCompleter?.complete();
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _isAuthenticated = true;
    _email = email;
    await _prefs?.setString(_userEmailKey, email);
    if (appController.isGuest) {
      await appController.setGuestMode(false);
    }
    notifyListeners();
  }

  Future<void> register(String email, String password) => login(email, password);

  Future<void> logout() async {
    _isAuthenticated = false;
    _email = null;
    await _prefs?.remove(_userEmailKey);
    await appController.setGuestMode(false);
    notifyListeners();
  }

  Future<void> continueAsGuest() async {
    _isAuthenticated = false;
    _email = null;
    await _prefs?.remove(_userEmailKey);
    await appController.setGuestMode(true);
    notifyListeners();
  }
}

class AuthScope extends InheritedNotifier<AuthController> {
  const AuthScope({required super.child, required AuthController controller, super.key})
      : super(notifier: controller);

  static AuthController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AuthScope>();
    assert(scope != null, 'AuthScope not found in context');
    return scope!.notifier!;
  }
}
