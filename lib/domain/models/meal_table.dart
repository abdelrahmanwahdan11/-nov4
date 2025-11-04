import 'package:flutter/material.dart';

@immutable
class MealTable {
  const MealTable({
    required this.id,
    required this.country,
    required this.mealType,
    required this.region,
    required this.imageUrl,
    required this.description,
    required this.highlights,
    required this.stats,
  });

  final String id;
  final String country;
  final String mealType;
  final String region;
  final String imageUrl;
  final String description;
  final List<String> highlights;
  final Map<String, String> stats;

  String get displayName => '$country $mealType';

  MealTable copyWith({
    String? id,
    String? country,
    String? mealType,
    String? region,
    String? imageUrl,
    String? description,
    List<String>? highlights,
    Map<String, String>? stats,
  }) {
    return MealTable(
      id: id ?? this.id,
      country: country ?? this.country,
      mealType: mealType ?? this.mealType,
      region: region ?? this.region,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      highlights: highlights ?? this.highlights,
      stats: stats ?? this.stats,
    );
  }
}
