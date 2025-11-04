import 'package:flutter/material.dart';

class AuthState {
  const AuthState({required this.isAuthenticated});

  final bool isAuthenticated;

  AuthState copyWith({bool? isAuthenticated}) {
    return AuthState(isAuthenticated: isAuthenticated ?? this.isAuthenticated);
  }
}

class AuthController extends ValueNotifier<AuthState> {
  AuthController() : super(const AuthState(isAuthenticated: false));

  bool get isAuthenticated => value.isAuthenticated;

  Future<void> login(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    value = value.copyWith(isAuthenticated: true);
  }

  Future<void> register(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    value = value.copyWith(isAuthenticated: true);
  }

  Future<void> logout() async {
    value = value.copyWith(isAuthenticated: false);
  }
}
