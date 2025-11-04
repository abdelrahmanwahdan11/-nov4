import 'package:flutter/material.dart';

class CartItemState {
  CartItemState({required this.id, required this.title, required this.price, this.quantity = 1});

  final String id;
  final String title;
  final double price;
  int quantity;
}

class CartController extends ChangeNotifier {
  final Map<String, CartItemState> _items = {};
  double _discount = 0;

  List<CartItemState> get items => _items.values.toList(growable: false);
  double get subtotal => _items.values.fold(0, (total, element) => total + element.price * element.quantity);
  double get discount => _discount;
  double get total => (subtotal - _discount).clamp(0, double.infinity);

  void addItem(CartItemState item) {
    if (_items.containsKey(item.id)) {
      _items[item.id]!.quantity += item.quantity;
    } else {
      _items[item.id] = item;
    }
    notifyListeners();
  }

  void updateQuantity(String id, int quantity) {
    final existing = _items[id];
    if (existing == null) return;
    existing.quantity = quantity.clamp(0, 99);
    if (existing.quantity <= 0) {
      _items.remove(id);
    }
    notifyListeners();
  }

  void applyCoupon(String code) {
    if (code.trim().toUpperCase() == 'GREEN10') {
      _discount = subtotal * 0.1;
    } else {
      _discount = 0;
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    _discount = 0;
    notifyListeners();
  }
}
