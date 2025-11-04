import 'dart:async';

import '../dummy/dummy_meal_tables.dart';
import '../../domain/models/meal_table.dart';

class MealTableLocalDataSource {
  Future<List<MealTable>> fetchAll() async {
    await Future<void>.delayed(const Duration(milliseconds: 240));
    return List<MealTable>.from(dummyMealTables);
  }

  Future<List<MealTable>> search(String query) async {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return fetchAll();
    }
    await Future<void>.delayed(const Duration(milliseconds: 160));
    return dummyMealTables.where((table) {
      final haystack = <String>[
        table.country,
        table.mealType,
        table.region,
        table.description,
        ...table.highlights,
        ...table.stats.values,
      ].join(' ').toLowerCase();
      return haystack.contains(normalized);
    }).toList();
  }
}
