import 'dart:async';

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/local/food_local_data_source.dart';
import '../../domain/models/food_item.dart';
import 'app_controller.dart';
import 'content_status.dart';

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
  SearchController({
    required FoodLocalDataSource dataSource,
    ValueListenable<ConnectionOverride>? connectionOverride,
  })  : _dataSource = dataSource,
        _connectionOverride = connectionOverride,
        query = ValueNotifier<String>(''),
        isLoading = ValueNotifier<bool>(false),
        status = ValueNotifier<ContentStatus>(ContentStatus.idle),
        errorKey = ValueNotifier<String?>(null) {
    _connectionOverride?.addListener(_handleConnectionChange);
  }

  final FoodLocalDataSource _dataSource;
  final ValueListenable<ConnectionOverride>? _connectionOverride;
  final ValueNotifier<String> query;
  final ValueNotifier<bool> isLoading;
  final ValueNotifier<ContentStatus> status;
  final ValueNotifier<String?> errorKey;
  final StreamController<List<SearchResult>> _resultsController =
      StreamController<List<SearchResult>>.broadcast();

  Stream<List<SearchResult>> get resultsStream => _resultsController.stream;

  List<FoodItem> _items = <FoodItem>[];
  bool _initialized = false;

  Future<void> initialize({bool force = false}) async {
    if (_initialized && !force) {
      return;
    }
    final connection = _connectionOverride?.value ?? ConnectionOverride.normal;
    if (connection != ConnectionOverride.normal) {
      _handleConnectionChange();
      return;
    }
    isLoading.value = true;
    status.value = ContentStatus.loading;
    errorKey.value = null;
    try {
      _items = await _dataSource.fetchAll();
      _initialized = true;
      final currentQuery = query.value.trim();
      if (currentQuery.isNotEmpty) {
        search(currentQuery);
      } else {
        _resultsController.add(<SearchResult>[]);
      }
      status.value = ContentStatus.success;
    } catch (_) {
      status.value = ContentStatus.error;
      errorKey.value = 'state_error_message';
    } finally {
      isLoading.value = false;
    }
  }

  void search(String rawQuery) {
    final trimmed = rawQuery.trim();
    query.value = rawQuery;
    if (status.value == ContentStatus.offline || status.value == ContentStatus.error) {
      return;
    }
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
    status.dispose();
    errorKey.dispose();
    _connectionOverride?.removeListener(_handleConnectionChange);
  }

  void _handleConnectionChange() {
    final connection = _connectionOverride?.value ?? ConnectionOverride.normal;
    if (connection == ConnectionOverride.normal) {
      if (!_initialized) {
        unawaited(initialize(force: true));
      } else {
        status.value = ContentStatus.success;
      }
      return;
    }
    isLoading.value = false;
    status.value = connection == ConnectionOverride.offline
        ? ContentStatus.offline
        : ContentStatus.error;
    errorKey.value =
        connection == ConnectionOverride.error ? 'state_error_message' : null;
  }

  Future<void> retry() => initialize(force: true);
}
