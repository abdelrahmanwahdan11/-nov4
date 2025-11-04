import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/meal_plan.dart';

class MealPlanLocalDataSource {
  MealPlanLocalDataSource({SharedPreferences? sharedPreferences})
      : _prefsFuture = sharedPreferences != null
            ? Future<SharedPreferences>.value(sharedPreferences)
            : SharedPreferences.getInstance();

  static const String _key = 'meal_plan_v1';

  final Future<SharedPreferences> _prefsFuture;

  Future<MealPlan?> read() async {
    final prefs = await _prefsFuture;
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return MealPlan.fromJson(decoded);
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  Future<void> save(MealPlan plan) async {
    final prefs = await _prefsFuture;
    await prefs.setString(_key, jsonEncode(plan.toJson()));
  }

  Future<void> clear() async {
    final prefs = await _prefsFuture;
    await prefs.remove(_key);
  }
}
