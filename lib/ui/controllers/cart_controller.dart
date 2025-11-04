import 'package:flutter/material.dart';

class CartItemState {
  const CartItemState({
    required this.id,
    required this.title,
    required this.price,
    this.quantity = 1,
  });

  final String id;
  final String title;
  final double price;
  final int quantity;

  CartItemState copyWith({int? quantity}) {
    return CartItemState(
      id: id,
      title: title,
      price: price,
      quantity: quantity ?? this.quantity,
    );
  }
}

class CartState {
  const CartState({
    this.items = const <CartItemState>[],
    this.discount = 0,
  });

  final List<CartItemState> items;
  final double discount;

  double get subtotal =>
      items.fold<double>(0, (total, item) => total + item.price * item.quantity);

  double get total => (subtotal - discount).clamp(0, double.infinity);

  CartState copyWith({List<CartItemState>? items, double? discount}) {
    return CartState(
      items: items ?? this.items,
      discount: discount ?? this.discount,
    );
  }
}

class CartController extends ValueNotifier<CartState> {
  CartController() : super(const CartState());

  List<CartItemState> get items => value.items;
  double get subtotal => value.subtotal;
  double get discount => value.discount;
  double get total => value.total;

  void addItem(CartItemState item) {
    final existingIndex = value.items.indexWhere((element) => element.id == item.id);
    final updatedItems = value.items.toList(growable: true);
    if (existingIndex >= 0) {
      final existing = updatedItems[existingIndex];
      updatedItems[existingIndex] = existing.copyWith(quantity: existing.quantity + item.quantity);
    } else {
      updatedItems.add(item);
    }
    value = value.copyWith(items: List<CartItemState>.unmodifiable(updatedItems));
  }

  void updateQuantity(String id, int quantity) {
    final clamped = quantity.clamp(0, 99).toInt();
    final updatedItems = value.items
        .map((item) => item.id == id ? item.copyWith(quantity: clamped) : item)
        .where((item) => item.quantity > 0)
        .toList(growable: false);
    value = value.copyWith(items: List<CartItemState>.unmodifiable(updatedItems));
  }

  bool applyCoupon(String code) {
    final normalized = code.trim().toUpperCase();
    final newDiscount =
        normalized == 'GREEN10' && value.items.isNotEmpty ? value.subtotal * 0.1 : 0.0;
    final changed = newDiscount != value.discount;
    if (changed) {
      value = value.copyWith(discount: newDiscount);
    }
    return newDiscount > 0;
  }

  void clear() {
    value = const CartState();
  }
}
