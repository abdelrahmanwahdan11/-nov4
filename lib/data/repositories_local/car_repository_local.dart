import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../models/car_item.dart';
import 'search_service.dart';

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

  Future<void> _simulateDelay() async {
    if (!randomDelay) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final isSlow = prefs.getBool(AppConstants.sharedPrefsSlowNetworkKey) ?? false;
    final base = isSlow ? 900 : 450;
    final jitter = isSlow ? 400 : 250;
    final duration = Duration(milliseconds: base + Random().nextInt(jitter));
    await Future<void>.delayed(duration);
  }

  Future<CarPage> fetchPage({
    required int page,
    required int pageSize,
    Map<String, dynamic>? filters,
    String? query,
    String? sort,
  }) async {
    await _ensureLoaded();
    await _simulateDelay();

    Iterable<CarItem> items = _cache;

    if (query != null && query.isNotEmpty) {
      final tokens = SearchService.tokenize(query);
      items = items.where(
        (item) => SearchService.containsAllTokens(
          [
            item.nameEn,
            item.nameAr,
            item.tags.join(' '),
          ],
          tokens,
        ),
      );
    }

    if (filters != null && filters.isNotEmpty) {
      final combinedFilters = Map<String, dynamic>.from(filters);
      items = items.where((item) {
        final double? minPrice = _asDouble(combinedFilters['minPrice']);
        final double? maxPrice = _asDouble(combinedFilters['maxPrice']);
        if (minPrice != null && item.price < minPrice) {
          return false;
        }
        if (maxPrice != null && item.price > maxPrice) {
          return false;
        }
        final double? minPower = _asDouble(combinedFilters['minPower']);
        final double? maxPower = _asDouble(combinedFilters['maxPower']);
        if (minPower != null && item.powerHp < minPower) {
          return false;
        }
        if (maxPower != null && item.powerHp > maxPower) {
          return false;
        }
        final double? minRange = _asDouble(combinedFilters['minRange']);
        final double? maxRange = _asDouble(combinedFilters['maxRange']);
        if (minRange != null && item.rangeKmOrConsumption < minRange) {
          return false;
        }
        if (maxRange != null && item.rangeKmOrConsumption > maxRange) {
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
      case 'power_desc':
        items = items.toList()..sort((a, b) => b.powerHp.compareTo(a.powerHp));
        break;
      case 'range_desc':
        items = items.toList()..sort((a, b) => b.rangeKmOrConsumption.compareTo(a.rangeKmOrConsumption));
        break;
    }

    final start = page * pageSize;
    final end = start + pageSize;
    final fullList = items.toList();
    final pageItems = start >= fullList.length
        ? <CarItem>[]
        : fullList.sublist(start, end.clamp(0, fullList.length));
    final hasMore = end < fullList.length;
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

  double? _asDouble(Object? value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
