import 'dart:async';

import '../../domain/models/food_item.dart';
import '../dummy/dummy_food_items.dart';

class FoodLocalDataSource {
  FoodLocalDataSource({this.simulatedDelay = const Duration(milliseconds: 350)});

  final Duration simulatedDelay;
  List<FoodItem>? _cache;

  Future<List<FoodItem>> fetchAll() async {
    if (_cache != null) {
      return _cache!;
    }
    await Future<void>.delayed(simulatedDelay);
    _cache = List<FoodItem>.from(dummyFoodItems);
    return _cache!;
  }

  Future<List<FoodItem>> refresh() async {
    await Future<void>.delayed(simulatedDelay + const Duration(milliseconds: 200));
    _cache = List<FoodItem>.from(dummyFoodItems);
    return _cache!;
  }
}
