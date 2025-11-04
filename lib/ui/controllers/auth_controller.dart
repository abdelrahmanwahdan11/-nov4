import 'package:flutter/material.dart';

class AuthController extends ChangeNotifier {
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  Future<void> login(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _isAuthenticated = true;
    notifyListeners();
  }

  Future<void> register(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _isAuthenticated = true;
    notifyListeners();
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    notifyListeners();
  }
}
