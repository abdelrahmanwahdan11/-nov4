import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

import '../models/car_item.dart';

class CarPage {
  CarPage({required this.items, required this.hasMore});

  final List<CarItem> items;
  final bool hasMore;
}

class CarRepositoryLocal {
  CarRepositoryLocal({this.randomDelay = true});

  final bool randomDelay;
  final List<CarItem> _cache = [];
  bool _initialized = false;

  Future<void> _ensureLoaded() async {
    if (_initialized) return;
    final jsonStr = await rootBundle.loadString('lib/data/mock/cars.json');
    final List<dynamic> data = json.decode(jsonStr) as List<dynamic>;
    _cache
      ..clear()
      ..addAll(data.map((e) => CarItem.fromJson(e as Map<String, dynamic>)));
    _initialized = true;
  }

  Future<CarPage> fetchPage({required int page, required int pageSize, Map<String, dynamic>? filters, String? query, String? sort}) async {
    await _ensureLoaded();
    await Future<void>.delayed(Duration(milliseconds: randomDelay ? Random().nextInt(300) + 600 : 100));

    Iterable<CarItem> items = _cache;
    if (query != null && query.isNotEmpty) {
      final lower = query.toLowerCase();
      items = items.where((item) => item.nameEn.toLowerCase().contains(lower) || item.nameAr.contains(query));
    }

    if (filters != null) {
      if (filters['tag'] != null) {
        final tag = filters['tag'] as String;
        items = items.where((element) => element.tags.contains(tag));
      }
      if (filters['minPrice'] != null) {
        final min = filters['minPrice'] as num;
        items = items.where((element) => element.price >= min);
      }
      if (filters['maxPrice'] != null) {
        final max = filters['maxPrice'] as num;
        items = items.where((element) => element.price <= max);
      }
    }

    switch (sort) {
      case 'price_asc':
        items = items.toList()..sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_desc':
        items = items.toList()..sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'power_desc':
        items = items.toList()..sort((a, b) => b.powerHp.compareTo(a.powerHp));
        break;
    }

    final start = page * pageSize;
    final end = start + pageSize;
    final pageItems = items.skip(start).take(pageSize).toList();
    final hasMore = end < items.length;
    return CarPage(items: pageItems, hasMore: hasMore);
  }

  Future<void> refresh() async {
    _initialized = false;
    await _ensureLoaded();
  }

  Future<CarItem?> getById(String id) async {
    await _ensureLoaded();
    try {
      return _cache.firstWhere((element) => element.id == id);
    } catch (_) {
      return null;
    }
  }
}
