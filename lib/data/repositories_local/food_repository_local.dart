import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

import '../models/food_item.dart';

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

  Future<FoodPage> fetchPage({required int page, required int pageSize, Map<String, dynamic>? filters, String? query, String? sort}) async {
    await _ensureLoaded();
    await Future<void>.delayed(Duration(milliseconds: randomDelay ? Random().nextInt(300) + 600 : 100));

    Iterable<FoodItem> items = _cache;
    if (query != null && query.isNotEmpty) {
      final lower = query.toLowerCase();
      items = items.where((item) => item.titleEn.toLowerCase().contains(lower) || item.titleAr.contains(query));
    }

    if (filters != null) {
      if (filters['vegan'] == true) {
        items = items.where((item) => item.isVegan);
      }
      if (filters['isNew'] == true) {
        items = items.where((item) => item.isNew);
      }
      final minPrice = filters['minPrice'] as double?;
      final maxPrice = filters['maxPrice'] as double?;
      if (minPrice != null) {
        items = items.where((item) => item.price >= minPrice);
      }
      if (maxPrice != null) {
        items = items.where((item) => item.price <= maxPrice);
      }
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
    }

    final start = page * pageSize;
    final end = start + pageSize;
    final pageItems = items.skip(start).take(pageSize).toList();
    final hasMore = end < items.length;
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
}
