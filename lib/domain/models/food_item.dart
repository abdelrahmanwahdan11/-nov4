import 'package:flutter/material.dart';

class FoodItem {
  const FoodItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.weight,
    required this.kcal,
    required this.tags,
    required this.imageUrl,
    required this.isNew,
    required this.isVegan,
  });

  final String id;
  final String name;
  final String description;
  final double price;
  final int weight;
  final int kcal;
  final List<String> tags;
  final String imageUrl;
  final bool isNew;
  final bool isVegan;

  bool get isLowCalorie => kcal <= 420;

  FoodItem copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    int? weight,
    int? kcal,
    List<String>? tags,
    String? imageUrl,
    bool? isNew,
    bool? isVegan,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      weight: weight ?? this.weight,
      kcal: kcal ?? this.kcal,
      tags: tags ?? List<String>.from(this.tags),
      imageUrl: imageUrl ?? this.imageUrl,
      isNew: isNew ?? this.isNew,
      isVegan: isVegan ?? this.isVegan,
    );
  }
}

@immutable
class CatalogFilters {
  const CatalogFilters({
    required this.priceRange,
    required this.weightRange,
    required this.kcalRange,
    required this.selectedTags,
  });

  final RangeValues priceRange;
  final RangeValues weightRange;
  final RangeValues kcalRange;
  final Set<String> selectedTags;

  CatalogFilters copyWith({
    RangeValues? priceRange,
    RangeValues? weightRange,
    RangeValues? kcalRange,
    Set<String>? selectedTags,
  }) {
    return CatalogFilters(
      priceRange: priceRange ?? this.priceRange,
      weightRange: weightRange ?? this.weightRange,
      kcalRange: kcalRange ?? this.kcalRange,
      selectedTags: selectedTags ?? Set<String>.from(this.selectedTags),
    );
  }
}
