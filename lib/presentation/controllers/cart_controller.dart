import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../data/local/cart_local_data_source.dart';
import '../../data/local/food_local_data_source.dart';
import '../../domain/models/cart_line.dart';
import '../../domain/models/food_item.dart';

enum CartEventType { promoApplied, checkoutSuccess }

class CartEvent {
  const CartEvent._(this.type, {this.code, this.orderId});

  const CartEvent.promoApplied(String code) : this._(CartEventType.promoApplied, code: code);
  const CartEvent.checkoutSuccess(String orderId)
      : this._(CartEventType.checkoutSuccess, orderId: orderId);

  final CartEventType type;
  final String? code;
  final String? orderId;
}

class CartEntry {
  CartEntry({required this.line, required this.item});

  final CartLine line;
  final FoodItem item;

  double get lineTotal => line.lineTotal;
}

class CartController extends ChangeNotifier {
  CartController({
    required FoodLocalDataSource catalogDataSource,
    required CartLocalDataSource localDataSource,
  })  : _catalogDataSource = catalogDataSource,
        _localDataSource = localDataSource,
        entries = ValueNotifier<List<CartEntry>>(<CartEntry>[]),
        subtotal = ValueNotifier<double>(0),
        discount = ValueNotifier<double>(0),
        total = ValueNotifier<double>(0),
        promoCode = ValueNotifier<String?>(null),
        promoError = ValueNotifier<String?>(null),
        isProcessingCheckout = ValueNotifier<bool>(false);

  static const Map<String, double> _promoDiscounts = <String, double>{
    'GREEN10': 0.1,
    'FRESH15': 0.15,
  };

  final FoodLocalDataSource _catalogDataSource;
  final CartLocalDataSource _localDataSource;

  final ValueNotifier<List<CartEntry>> entries;
  final ValueNotifier<double> subtotal;
  final ValueNotifier<double> discount;
  final ValueNotifier<double> total;
  final ValueNotifier<String?> promoCode;
  final ValueNotifier<String?> promoError;
  final ValueNotifier<bool> isProcessingCheckout;

  final StreamController<CartEvent> _eventsController = StreamController<CartEvent>.broadcast();

  Stream<CartEvent> get events => _eventsController.stream;

  bool _initialized = false;
  List<CartLine> _lines = <CartLine>[];
  Map<String, FoodItem> _catalog = <String, FoodItem>{};

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    final items = await _catalogDataSource.fetchAll();
    _catalog = <String, FoodItem>{for (final item in items) item.id: item};
    final persistence = await _localDataSource.read();
    _lines = persistence.lines
        .map((line) => line.addons.isEmpty
            ? line
            : line.copyWith(addons: (List<String>.from(line.addons)..sort())))
        .toList();
    if (persistence.promoCode != null && persistence.promoCode!.isNotEmpty) {
      promoCode.value = persistence.promoCode;
    }
    _rebuildEntries();
    _initialized = true;
  }

  Future<void> addItem(
    FoodItem item, {
    String? sizeId,
    List<String>? addons,
    int quantity = 1,
  }) async {
    await initialize();
    if (quantity <= 0) {
      return;
    }
    final sizeOption = item.sizeById(sizeId ?? item.defaultSize.id) ?? item.defaultSize;
    final normalizedAddons = List<String>.from(addons ?? const <String>[]);
    normalizedAddons.removeWhere((addon) => addon.isEmpty);
    normalizedAddons.sort();
    final addonTotal = normalizedAddons.fold<double>(
      0,
      (previousValue, addonId) => previousValue + (item.addonById(addonId)?.price ?? 0),
    );
    final unitPrice = double.parse((sizeOption.priceFor(item) + addonTotal).toStringAsFixed(2));
    final key = _composeKey(item.id, sizeOption.id, normalizedAddons);
    final index = _lines.indexWhere((line) => line.identifier == key);
    if (index >= 0) {
      final existing = _lines[index];
      _lines[index] = existing.copyWith(qty: existing.qty + quantity);
    } else {
      _lines = List<CartLine>.from(_lines)
        ..add(
          CartLine(
            itemId: item.id,
            qty: quantity,
            size: sizeOption.id,
            addons: normalizedAddons,
            unitPrice: unitPrice,
          ),
        );
    }
    _rebuildEntries();
    await _persist();
  }

  Future<void> increment(String identifier) async {
    await initialize();
    final index = _lines.indexWhere((line) => line.identifier == identifier);
    if (index < 0) {
      return;
    }
    final line = _lines[index];
    _lines[index] = line.copyWith(qty: line.qty + 1);
    _rebuildEntries();
    await _persist();
  }

  Future<void> decrement(String identifier) async {
    await initialize();
    final index = _lines.indexWhere((line) => line.identifier == identifier);
    if (index < 0) {
      return;
    }
    final line = _lines[index];
    if (line.qty <= 1) {
      _lines.removeAt(index);
    } else {
      _lines[index] = line.copyWith(qty: line.qty - 1);
    }
    _rebuildEntries();
    await _persist();
  }

  Future<void> remove(String identifier) async {
    await initialize();
    _lines.removeWhere((line) => line.identifier == identifier);
    _rebuildEntries();
    await _persist();
  }

  Future<void> applyPromo(String code) async {
    await initialize();
    final trimmed = code.trim();
    if (trimmed.isEmpty) {
      promoError.value = 'empty';
      promoCode.value = null;
      _rebuildEntries();
      await _persist();
      return;
    }
    final normalized = trimmed.toUpperCase();
    final discountValue = _promoDiscounts[normalized];
    if (discountValue == null) {
      promoError.value = 'invalid';
      promoCode.value = null;
      _rebuildEntries();
      await _persist();
      return;
    }
    promoError.value = null;
    promoCode.value = normalized;
    _rebuildEntries();
    await _persist();
    _eventsController.add(CartEvent.promoApplied(normalized));
  }

  Future<void> clearPromo() async {
    await initialize();
    promoCode.value = null;
    promoError.value = null;
    _rebuildEntries();
    await _persist();
  }

  Future<String?> checkout() async {
    await initialize();
    if (_lines.isEmpty) {
      return null;
    }
    isProcessingCheckout.value = true;
    await Future<void>.delayed(const Duration(milliseconds: 420));
    final orderId = _generateOrderId();
    _lines = <CartLine>[];
    promoCode.value = null;
    promoError.value = null;
    _rebuildEntries();
    await _localDataSource.clear();
    isProcessingCheckout.value = false;
    _eventsController.add(CartEvent.checkoutSuccess(orderId));
    return orderId;
  }

  Future<void> disposeAsync() async {
    await _eventsController.close();
  }

  @override
  void dispose() {
    entries.dispose();
    subtotal.dispose();
    discount.dispose();
    total.dispose();
    promoCode.dispose();
    promoError.dispose();
    isProcessingCheckout.dispose();
    _eventsController.close();
    super.dispose();
  }

  String _composeKey(String itemId, String size, List<String> addons) {
    if (addons.isEmpty) {
      return '$itemId|$size';
    }
    final normalized = List<String>.from(addons)..sort();
    return '$itemId|$size|${normalized.join('+')}';
  }

  void _rebuildEntries() {
    final view = <CartEntry>[];
    for (final line in _lines) {
      final item = _catalog[line.itemId];
      if (item != null) {
        view.add(CartEntry(line: line, item: item));
      }
    }
    entries.value = List<CartEntry>.unmodifiable(view);
    final subtotalValue = view.fold<double>(0, (previousValue, entry) => previousValue + entry.lineTotal);
    subtotal.value = subtotalValue;
    final discountValue = _calculateDiscount(subtotalValue, promoCode.value);
    discount.value = discountValue;
    total.value = max(0, subtotalValue - discountValue);
    notifyListeners();
  }

  double _calculateDiscount(double base, String? code) {
    if (code == null || code.isEmpty || base <= 0) {
      return 0;
    }
    final normalized = code.toUpperCase();
    final percent = _promoDiscounts[normalized];
    if (percent == null) {
      return 0;
    }
    return double.parse((base * percent).toStringAsFixed(2));
  }

  Future<void> _persist() {
    return _localDataSource.save(_lines, promoCode.value);
  }

  String _generateOrderId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch % 1000000;
    return 'GB${timestamp.toString().padLeft(6, '0')}';
  }
}

class CartScope extends InheritedNotifier<CartController> {
  const CartScope({required super.child, required CartController controller, super.key})
      : super(notifier: controller);

  static CartController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<CartScope>();
    assert(scope != null, 'CartScope not found in context');
    return scope!.notifier!;
  }
}
