import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/local/food_local_data_source.dart';
import '../../domain/models/food_item.dart';
import '../../domain/models/food_search_index.dart';
import 'app_controller.dart';
import 'content_status.dart';

const Map<String, int> _fieldPriority = <String, int>{
  'name': 0,
  'description': 1,
  'tags': 2,
  'kcal': 3,
  'price': 4,
};

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
  final StreamController<List<String>> _suggestionsController =
      StreamController<List<String>>.broadcast();

  Stream<List<SearchResult>> get resultsStream => _resultsController.stream;
  Stream<List<String>> get suggestionsStream => _suggestionsController.stream;

  List<FoodItem> _items = <FoodItem>[];
  final Map<String, FoodItem> _itemLookup = <String, FoodItem>{};
  FoodSearchIndex? _index;
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
      _itemLookup
        ..clear()
        ..addEntries(_items.map((item) => MapEntry(item.id, item)));
      _index = FoodSearchIndex.build(_items);
      _initialized = true;
      final currentQuery = query.value.trim();
      _emitSuggestions(currentQuery);
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
    _emitSuggestions(trimmed);
    if (trimmed.isEmpty) {
      _resultsController.add(<SearchResult>[]);
      return;
    }
    final index = _index;
    if (index == null) {
      _resultsController.add(<SearchResult>[]);
      return;
    }
    final hits = index.search(trimmed);
    final results = hits.map((hit) {
      final item = _itemLookup[hit.itemId];
      if (item == null) {
        return null;
      }
      final fields = hit.matchedFields.toList()
        ..sort((a, b) => (_fieldPriority[a] ?? 99).compareTo(_fieldPriority[b] ?? 99));
      return SearchResult(
        item: item,
        matchedTags: hit.matchedTags.toList()..sort(),
        matchedFields: fields,
      );
    }).whereType<SearchResult>().toList();
    _resultsController.add(results);
  }

  Future<void> disposeAsync() async {
    await _resultsController.close();
    await _suggestionsController.close();
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
        _emitSuggestions(query.value.trim());
      }
      return;
    }
    isLoading.value = false;
    status.value = connection == ConnectionOverride.offline
        ? ContentStatus.offline
        : ContentStatus.error;
    errorKey.value =
        connection == ConnectionOverride.error ? 'state_error_message' : null;
    _suggestionsController.add(<String>[]);
  }

  Future<void> retry() => initialize(force: true);

  void _emitSuggestions(String query) {
    final index = _index;
    if (index == null) {
      return;
    }
    _suggestionsController.add(index.suggestions(query));
  }
}
