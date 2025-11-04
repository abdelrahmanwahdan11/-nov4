import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/local/food_local_data_source.dart';
import '../../domain/models/food_item.dart';

class SearchResult {
  const SearchResult({
    required this.item,
    required this.matchedTags,
    required this.matchedFields,
  });

  final FoodItem item;
  final List<String> matchedTags;
  final List<String> matchedFields;
}

class SearchController {
  SearchController({required FoodLocalDataSource dataSource})
      : _dataSource = dataSource,
        query = ValueNotifier<String>(''),
        isLoading = ValueNotifier<bool>(false);

  final FoodLocalDataSource _dataSource;
  final ValueNotifier<String> query;
  final ValueNotifier<bool> isLoading;
  final StreamController<List<SearchResult>> _resultsController =
      StreamController<List<SearchResult>>.broadcast();

  Stream<List<SearchResult>> get resultsStream => _resultsController.stream;

  List<FoodItem> _items = <FoodItem>[];
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    isLoading.value = true;
    _items = await _dataSource.fetchAll();
    isLoading.value = false;
    _initialized = true;
    final currentQuery = query.value.trim();
    if (currentQuery.isNotEmpty) {
      search(currentQuery);
    } else {
      _resultsController.add(<SearchResult>[]);
    }
  }

  void search(String rawQuery) {
    final trimmed = rawQuery.trim();
    query.value = rawQuery;
    if (trimmed.isEmpty) {
      _resultsController.add(<SearchResult>[]);
      return;
    }
    final lower = trimmed.toLowerCase();
    final results = _items.map((item) {
      final fields = <String>[];
      final tags = <String>[];
      final nameMatch = item.name.toLowerCase().contains(lower);
      final descMatch = item.description.toLowerCase().contains(lower);
      final tagMatches = item.tags.where((tag) => tag.toLowerCase().contains(lower)).toList();
      final kcalMatch = item.kcal.toString().contains(lower);
      final priceMatch = item.price.toStringAsFixed(2).contains(lower);
      if (nameMatch) {
        fields.add('name');
      }
      if (descMatch) {
        fields.add('description');
      }
      if (tagMatches.isNotEmpty) {
        fields.add('tags');
        tags.addAll(tagMatches);
      }
      if (kcalMatch) {
        fields.add('kcal');
      }
      if (priceMatch) {
        fields.add('price');
      }
      return SearchResult(
        item: item,
        matchedTags: tags,
        matchedFields: fields,
      );
    }).where((result) => result.matchedFields.isNotEmpty).toList();

    results.sort((a, b) {
      final scoreA = a.matchedFields.length;
      final scoreB = b.matchedFields.length;
      if (scoreA == scoreB) {
        return a.item.name.compareTo(b.item.name);
      }
      return scoreB.compareTo(scoreA);
    });
    _resultsController.add(results);
  }

  Future<void> disposeAsync() async {
    await _resultsController.close();
  }

  void dispose() {
    query.dispose();
    isLoading.dispose();
  }
}
