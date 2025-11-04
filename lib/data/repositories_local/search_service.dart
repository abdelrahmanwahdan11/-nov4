import '../models/car_item.dart';
import '../models/food_item.dart';

class SearchHit<T> {
  SearchHit({required this.item, required this.matchText});

  final T item;
  final String matchText;
}

class SearchService {
  SearchService({required List<FoodItem> foods, required List<CarItem> cars})
      : _foodsIndex = foods,
        _carsIndex = cars;

  final List<FoodItem> _foodsIndex;
  final List<CarItem> _carsIndex;

  List<SearchHit<dynamic>> query(String text) {
    final normalized = text.trim().toLowerCase();
    if (normalized.isEmpty) return [];

    final results = <SearchHit<dynamic>>[];
    for (final food in _foodsIndex) {
      if (_matches(food.titleEn, normalized) || _matches(food.titleAr, normalized)) {
        results.add(SearchHit(item: food, matchText: food.titleEn));
      }
    }
    for (final car in _carsIndex) {
      if (_matches(car.nameEn, normalized) || _matches(car.nameAr, normalized)) {
        results.add(SearchHit(item: car, matchText: car.nameEn));
      }
    }
    return results.take(20).toList(growable: false);
  }

  bool _matches(String text, String query) {
    return removeDiacritics(text.toLowerCase()).contains(removeDiacritics(query));
  }

  String removeDiacritics(String input) {
    const arabicDiacritics = ['\u0610', '\u0611', '\u0612', '\u0613', '\u0614', '\u0615', '\u0616', '\u0617', '\u0618', '\u0619', '\u061A', '\u064B', '\u064C', '\u064D', '\u064E', '\u064F', '\u0650', '\u0651', '\u0652', '\u0653', '\u0654', '\u0655'];
    var result = input;
    for (final mark in arabicDiacritics) {
      result = result.replaceAll(RegExp(mark), '');
    }
    return result;
  }
}
