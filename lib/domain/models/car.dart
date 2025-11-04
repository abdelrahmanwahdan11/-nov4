import 'package:flutter/material.dart';

@immutable
class Car {
  const Car({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.imageUrl,
    required this.asset3D,
    required this.specs,
  });

  final String id;
  final String brand;
  final String model;
  final int year;
  final String imageUrl;
  final String asset3D;
  final Map<String, String> specs;

  String get displayName => '$brand $model';

  Car copyWith({
    String? id,
    String? brand,
    String? model,
    int? year,
    String? imageUrl,
    String? asset3D,
    Map<String, String>? specs,
  }) {
    return Car(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      imageUrl: imageUrl ?? this.imageUrl,
      asset3D: asset3D ?? this.asset3D,
      specs: specs ?? this.specs,
    );
  }
}
