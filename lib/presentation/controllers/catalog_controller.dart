import 'dart:math';

import 'package:flutter/material.dart';

import '../../data/local/food_local_data_source.dart';
import '../../domain/models/food_item.dart';

class CatalogController extends ChangeNotifier {
  CatalogController({required FoodLocalDataSource dataSource})
      : _dataSource = dataSource,
        items = ValueNotifier<List<FoodItem>>(<FoodItem>[]),
        isLoading = ValueNotifier<bool>(false),
        isRefreshing = ValueNotifier<bool>(false),
        hasMore = ValueNotifier<bool>(false),
        filters = ValueNotifier<CatalogFilters>(
          CatalogFilters(
            priceRange: const RangeValues(0, 0),
            weightRange: const RangeValues(0, 0),
            kcalRange: const RangeValues(0, 0),
            selectedTags: <String>{},
          ),
        ),
        isGridMode = ValueNotifier<bool>(true),
        availableTags = ValueNotifier<List<String>>(<String>[]),
        isPaginating = ValueNotifier<bool>(false);

  final FoodLocalDataSource _dataSource;

  final ValueNotifier<List<FoodItem>> items;
  final ValueNotifier<bool> isLoading;
  final ValueNotifier<bool> isRefreshing;
  final ValueNotifier<bool> hasMore;
  final ValueNotifier<CatalogFilters> filters;
  final ValueNotifier<bool> isGridMode;
  final ValueNotifier<List<String>> availableTags;
  final ValueNotifier<bool> isPaginating;

  final int _pageSize = 10;
  List<FoodItem> _allItems = <FoodItem>[];
  List<FoodItem> _filteredItems = <FoodItem>[];
  int _pageIndex = 0;
  RangeValues _priceBounds = const RangeValues(0, 0);
  RangeValues _weightBounds = const RangeValues(0, 0);
  RangeValues _kcalBounds = const RangeValues(0, 0);

  bool get isReady => _allItems.isNotEmpty;
  RangeValues get priceBounds => _priceBounds;
  RangeValues get weightBounds => _weightBounds;
  RangeValues get kcalBounds => _kcalBounds;

  Future<void> loadInitial() async {
    if (items.value.isNotEmpty) {
      return;
    }
    isLoading.value = true;
    final fetched = await _dataSource.fetchAll();
    _allItems = List<FoodItem>.from(fetched);
    _buildFilters();
    _applyFilters(resetPage: true);
    isLoading.value = false;
  }

  Future<void> refresh() async {
    isRefreshing.value = true;
    final refreshed = await _dataSource.refresh();
    _allItems = List<FoodItem>.from(refreshed);
    _buildFilters();
    _applyFilters(resetPage: true);
    isRefreshing.value = false;
  }

  void toggleGridMode() {
    isGridMode.value = !isGridMode.value;
  }

  void updatePrice(RangeValues range) {
    final current = filters.value;
    filters.value = current.copyWith(priceRange: range);
    _applyFilters(resetPage: true);
  }

  void updateWeight(RangeValues range) {
    final current = filters.value;
    filters.value = current.copyWith(weightRange: range);
    _applyFilters(resetPage: true);
  }

  void updateKcal(RangeValues range) {
    final current = filters.value;
    filters.value = current.copyWith(kcalRange: range);
    _applyFilters(resetPage: true);
  }

  void toggleTag(String tag) {
    final current = filters.value;
    final nextTags = Set<String>.from(current.selectedTags);
    if (nextTags.contains(tag)) {
      nextTags.remove(tag);
    } else {
      nextTags.add(tag);
    }
    filters.value = current.copyWith(selectedTags: nextTags);
    _applyFilters(resetPage: true);
  }

  Future<void> loadMore() async {
    if (!hasMore.value || isPaginating.value) {
      return;
    }
    isPaginating.value = true;
    await Future<void>.delayed(const Duration(milliseconds: 260));
    _pageIndex += 1;
    _updatePage();
    isPaginating.value = false;
  }

  void _buildFilters() {
    if (_allItems.isEmpty) {
      return;
    }
    double minPrice = double.infinity;
    double maxPrice = 0;
    double minWeight = double.infinity;
    double maxWeight = 0;
    double minKcal = double.infinity;
    double maxKcal = 0;
    final tags = <String>{};
    for (final item in _allItems) {
      minPrice = min(minPrice, item.price);
      maxPrice = max(maxPrice, item.price);
      minWeight = min(minWeight, item.weight.toDouble());
      maxWeight = max(maxWeight, item.weight.toDouble());
      minKcal = min(minKcal, item.kcal.toDouble());
      maxKcal = max(maxKcal, item.kcal.toDouble());
      tags.addAll(item.tags);
    }
    _priceBounds = RangeValues(minPrice.floorToDouble(), maxPrice.ceilToDouble());
    _weightBounds = RangeValues(minWeight.floorToDouble(), maxWeight.ceilToDouble());
    _kcalBounds = RangeValues(minKcal.floorToDouble(), maxKcal.ceilToDouble());
    filters.value = CatalogFilters(
      priceRange: _priceBounds,
      weightRange: _weightBounds,
      kcalRange: _kcalBounds,
      selectedTags: <String>{},
    );
    final sortedTags = tags.toList()..sort();
    availableTags.value = sortedTags;
  }

  void _applyFilters({required bool resetPage}) {
    final current = filters.value;
    _filteredItems = _allItems.where((item) {
      final price = item.price;
      final weight = item.weight.toDouble();
      final kcal = item.kcal.toDouble();
      final priceMatch = price >= current.priceRange.start && price <= current.priceRange.end;
      final weightMatch = weight >= current.weightRange.start && weight <= current.weightRange.end;
      final kcalMatch = kcal >= current.kcalRange.start && kcal <= current.kcalRange.end;
      final tagsMatch = current.selectedTags.isEmpty ||
          current.selectedTags.every((tag) => item.tags.contains(tag));
      return priceMatch && weightMatch && kcalMatch && tagsMatch;
    }).toList();
    if (resetPage) {
      _pageIndex = 0;
    }
    _updatePage();
  }

  void _updatePage() {
    final endIndex = min(_filteredItems.length, (_pageIndex + 1) * _pageSize);
    items.value = _filteredItems.take(endIndex).toList();
    hasMore.value = endIndex < _filteredItems.length;
  }

  @override
  void dispose() {
    items.dispose();
    isLoading.dispose();
    isRefreshing.dispose();
    hasMore.dispose();
    filters.dispose();
    isGridMode.dispose();
    availableTags.dispose();
    isPaginating.dispose();
    super.dispose();
  }
}
