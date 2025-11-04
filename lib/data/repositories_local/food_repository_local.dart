import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import '../../core/constants/app_constants.dart';
import '../../core/storage/app_preferences.dart';
import '../models/food_item.dart';
import 'search_service.dart';

class FoodPage {
  FoodPage({required this.items, required this.hasMore});

  final List<FoodItem> items;
  final bool hasMore;
}

class FoodRepositoryLocal {
  FoodRepositoryLocal({this.randomDelay = true});

  final bool randomDelay;
  final List<FoodItem> _cache = [];
  bool _initialized = false;

  Future<void> _ensureLoaded() async {
    if (_initialized) return;
    final jsonStr = await rootBundle.loadString('lib/data/mock/foods.json');
    final List<dynamic> data = json.decode(jsonStr) as List<dynamic>;
    _cache
      ..clear()
      ..addAll(data.map((e) => FoodItem.fromJson(e as Map<String, dynamic>)));
    _initialized = true;
  }

  Future<void> _simulateDelay() async {
    if (!randomDelay) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      return;
    }
    final prefs = await AppPreferences.getInstance();
    final isSlow = prefs.getBool(AppConstants.sharedPrefsSlowNetworkKey) ?? false;
    final base = isSlow ? 900 : 450;
    final jitter = isSlow ? 400 : 250;
    final duration = Duration(milliseconds: base + Random().nextInt(jitter));
    await Future<void>.delayed(duration);
  }

  Future<FoodPage> fetchPage({
    required int page,
    required int pageSize,
    Map<String, dynamic>? filters,
    String? query,
    String? sort,
  }) async {
    await _ensureLoaded();
    await _simulateDelay();

    Iterable<FoodItem> items = _cache;

    if (query != null && query.isNotEmpty) {
      final tokens = SearchService.tokenize(query);
      items = items.where(
        (item) => SearchService.containsAllTokens(
          [
            item.titleEn,
            item.titleAr,
            item.descEn,
            item.descAr,
            item.tags.join(' '),
          ],
          tokens,
        ),
      );
    }

    if (filters != null && filters.isNotEmpty) {
      final combinedFilters = Map<String, dynamic>.from(filters);
      items = items.where((item) {
        if (combinedFilters.containsKey('vegan')) {
          final value = combinedFilters['vegan'];
          if (value is bool && item.isVegan != value) {
            return false;
          }
        }
        if (combinedFilters.containsKey('isNew')) {
          final value = combinedFilters['isNew'];
          if (value is bool && item.isNew != value) {
            return false;
          }
        }
        final double? minPrice = _asDouble(combinedFilters['minPrice']);
        final double? maxPrice = _asDouble(combinedFilters['maxPrice']);
        if (minPrice != null && item.price < minPrice) {
          return false;
        }
        if (maxPrice != null && item.price > maxPrice) {
          return false;
        }
        final double? minKcal = _asDouble(combinedFilters['minKcal']);
        final double? maxKcal = _asDouble(combinedFilters['maxKcal']);
        if (minKcal != null && item.kcal < minKcal) {
          return false;
        }
        if (maxKcal != null && item.kcal > maxKcal) {
          return false;
        }
        final double? minGrams = _asDouble(combinedFilters['minGrams']);
        final double? maxGrams = _asDouble(combinedFilters['maxGrams']);
        if (minGrams != null && item.grams < minGrams) {
          return false;
        }
        if (maxGrams != null && item.grams > maxGrams) {
          return false;
        }
        final Iterable<dynamic>? tagsFilter = combinedFilters['tags'] as Iterable<dynamic>?;
        if (tagsFilter != null && tagsFilter.isNotEmpty) {
          final normalizedTags = tagsFilter.map((tag) => tag.toString().toLowerCase()).toSet();
          final itemTags = item.tags.map((tag) => tag.toLowerCase()).toSet();
          if (!itemTags.any(normalizedTags.contains)) {
            return false;
          }
        }
        return true;
      });
    }

    switch (sort) {
      case 'price_asc':
        items = items.toList()..sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_desc':
        items = items.toList()..sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'kcal_asc':
        items = items.toList()..sort((a, b) => a.kcal.compareTo(b.kcal));
        break;
      case 'kcal_desc':
        items = items.toList()..sort((a, b) => b.kcal.compareTo(a.kcal));
        break;
      case 'newest':
        items = items.toList()
          ..sort(
            (a, b) => b.isNew.compareTo(a.isNew),
          );
        break;
    }

    final start = page * pageSize;
    final end = start + pageSize;
    final fullList = items.toList();
    final pageItems = start >= fullList.length
        ? <FoodItem>[]
        : fullList.sublist(start, end.clamp(0, fullList.length));
    final hasMore = end < fullList.length;
    return FoodPage(items: pageItems, hasMore: hasMore);
  }

  Future<void> refresh() async {
    _initialized = false;
    await _ensureLoaded();
  }

  Future<FoodItem?> getById(String id) async {
    await _ensureLoaded();
    try {
      return _cache.firstWhere((element) => element.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<String>> getAvailableTags() async {
    await _ensureLoaded();
    final tags = _cache.expand((item) => item.tags).map((e) => e.toLowerCase()).toSet().toList();
    tags.sort();
    return tags;
  }

  double? _asDouble(Object? value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
