import 'dart:math' as math;

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
    required this.sizes,
    required this.addons,
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
  final List<FoodSizeOption> sizes;
  final List<FoodAddonOption> addons;

  bool get isLowCalorie => kcal <= 420;

  FoodSizeOption get defaultSize {
    for (final option in sizes) {
      if (option.priceDelta == 0) {
        return option;
      }
    }
    return sizes.isNotEmpty ? sizes.first : FoodSizeOption.fallback();
  }

  FoodSizeOption? sizeById(String id) {
    for (final option in sizes) {
      if (option.id == id) {
        return option;
      }
    }
    return null;
  }

  FoodAddonOption? addonById(String id) {
    for (final addon in addons) {
      if (addon.id == id) {
        return addon;
      }
    }
    return null;
  }

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
    List<FoodSizeOption>? sizes,
    List<FoodAddonOption>? addons,
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
      sizes: sizes ?? List<FoodSizeOption>.from(this.sizes),
      addons: addons ?? List<FoodAddonOption>.from(this.addons),
    );
  }
}

@immutable
class FoodSizeOption {
  const FoodSizeOption({
    required this.id,
    required this.label,
    required this.description,
    required this.priceDelta,
    required this.weightDelta,
    required this.kcalDelta,
  });

  final String id;
  final String label;
  final String description;
  final double priceDelta;
  final int weightDelta;
  final int kcalDelta;

  static FoodSizeOption fallback() {
    return const FoodSizeOption(
      id: 'regular',
      label: 'Regular',
      description: 'Standard portion',
      priceDelta: 0,
      weightDelta: 0,
      kcalDelta: 0,
    );
  }

  double priceFor(FoodItem item) {
    return double.parse((item.price + priceDelta).toStringAsFixed(2));
  }

  int weightFor(FoodItem item) {
    return math.max(0, item.weight + weightDelta);
  }

  int kcalFor(FoodItem item) {
    return math.max(0, item.kcal + kcalDelta);
  }
}

@immutable
class FoodAddonOption {
  const FoodAddonOption({
    required this.id,
    required this.label,
    required this.price,
  });

  final String id;
  final String label;
  final double price;
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
