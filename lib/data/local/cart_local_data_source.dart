import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/cart_line.dart';

class CartPersistence {
  const CartPersistence({required this.lines, this.promoCode});

  final List<CartLine> lines;
  final String? promoCode;
}

class CartLocalDataSource {
  CartLocalDataSource({SharedPreferences? sharedPreferences})
      : _prefsFuture = sharedPreferences != null
            ? Future<SharedPreferences>.value(sharedPreferences)
            : SharedPreferences.getInstance();

  static const String _linesKey = 'cart_lines';
  static const String _promoKey = 'cart_promo_code';

  final Future<SharedPreferences> _prefsFuture;

  Future<CartPersistence> read() async {
    final prefs = await _prefsFuture;
    final raw = prefs.getString(_linesKey);
    final promo = prefs.getString(_promoKey);
    if (raw == null || raw.isEmpty) {
      return CartPersistence(lines: <CartLine>[], promoCode: promo);
    }
    final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
    final lines = decoded
        .map((entry) => CartLine.fromJson(entry as Map<String, dynamic>))
        .toList();
    return CartPersistence(lines: lines, promoCode: promo);
  }

  Future<void> save(List<CartLine> lines, String? promoCode) async {
    final prefs = await _prefsFuture;
    final payload = lines.map((line) => line.toJson()).toList();
    await prefs.setString(_linesKey, jsonEncode(payload));
    if (promoCode == null || promoCode.isEmpty) {
      await prefs.remove(_promoKey);
    } else {
      await prefs.setString(_promoKey, promoCode);
    }
  }

  Future<void> clear() async {
    final prefs = await _prefsFuture;
    await prefs.remove(_linesKey);
    await prefs.remove(_promoKey);
  }
}
