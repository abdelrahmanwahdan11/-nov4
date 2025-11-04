import 'dart:convert';

class CartLine {
  CartLine({
    required this.itemId,
    required this.qty,
    required this.size,
    required List<String> addons,
    required this.unitPrice,
  }) : addons = List<String>.unmodifiable(addons);

  factory CartLine.fromJson(Map<String, dynamic> json) {
    return CartLine(
      itemId: json['itemId'] as String,
      qty: json['qty'] as int,
      size: json['size'] as String,
      addons: (json['addons'] as List<dynamic>?)?.cast<String>() ?? <String>[],
      unitPrice: (json['unitPrice'] as num).toDouble(),
    );
  }

  final String itemId;
  final int qty;
  final String size;
  final List<String> addons;
  final double unitPrice;

  String get identifier {
    if (addons.isEmpty) {
      return '$itemId|$size';
    }
    return '$itemId|$size|${addons.join('+')}';
  }

  double get lineTotal => unitPrice * qty;

  CartLine copyWith({
    int? qty,
    String? size,
    List<String>? addons,
    double? unitPrice,
  }) {
    return CartLine(
      itemId: itemId,
      qty: qty ?? this.qty,
      size: size ?? this.size,
      addons: addons ?? this.addons,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'itemId': itemId,
      'qty': qty,
      'size': size,
      'addons': addons,
      'unitPrice': unitPrice,
    };
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
