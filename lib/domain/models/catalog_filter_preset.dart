import 'package:flutter/material.dart';

import 'food_item.dart';

class CatalogFilterPreset {
  CatalogFilterPreset({
    required this.id,
    required this.name,
    required this.filters,
    required this.usageCount,
    required this.createdAt,
    DateTime? lastUsedAt,
  }) : lastUsedAt = lastUsedAt ?? createdAt;

  final String id;
  final String name;
  final CatalogFilters filters;
  final int usageCount;
  final DateTime createdAt;
  final DateTime lastUsedAt;

  CatalogFilterPreset copyWith({
    String? id,
    String? name,
    CatalogFilters? filters,
    int? usageCount,
    DateTime? createdAt,
    DateTime? lastUsedAt,
  }) {
    return CatalogFilterPreset(
      id: id ?? this.id,
      name: name ?? this.name,
      filters: filters ?? this.filters,
      usageCount: usageCount ?? this.usageCount,
      createdAt: createdAt ?? this.createdAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'lastUsedAt': lastUsedAt.toIso8601String(),
      'usageCount': usageCount,
      'filters': <String, dynamic>{
        'priceStart': filters.priceRange.start,
        'priceEnd': filters.priceRange.end,
        'weightStart': filters.weightRange.start,
        'weightEnd': filters.weightRange.end,
        'kcalStart': filters.kcalRange.start,
        'kcalEnd': filters.kcalRange.end,
        'tags': filters.selectedTags.toList(),
      },
    };
  }

  static CatalogFilterPreset fromJson(Map<String, dynamic> json) {
    final filtersJson = json['filters'] as Map<String, dynamic>? ?? <String, dynamic>{};
    return CatalogFilterPreset(
      id: json['id'] as String? ?? UniqueKey().toString(),
      name: json['name'] as String? ?? 'Preset',
      usageCount: json['usageCount'] as int? ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      lastUsedAt: DateTime.tryParse(json['lastUsedAt'] as String? ?? '') ?? DateTime.now(),
      filters: CatalogFilters(
        priceRange: RangeValues(
          (filtersJson['priceStart'] as num?)?.toDouble() ?? 0,
          (filtersJson['priceEnd'] as num?)?.toDouble() ?? 0,
        ),
        weightRange: RangeValues(
          (filtersJson['weightStart'] as num?)?.toDouble() ?? 0,
          (filtersJson['weightEnd'] as num?)?.toDouble() ?? 0,
        ),
        kcalRange: RangeValues(
          (filtersJson['kcalStart'] as num?)?.toDouble() ?? 0,
          (filtersJson['kcalEnd'] as num?)?.toDouble() ?? 0,
        ),
        selectedTags: <String>{
          for (final dynamic tag in filtersJson['tags'] as List<dynamic>? ?? <dynamic>[])
            if (tag is String) tag,
        },
      ),
    );
  }
}
