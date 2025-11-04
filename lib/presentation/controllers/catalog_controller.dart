import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../data/local/catalog_presets_local_data_source.dart';
import '../../data/local/food_local_data_source.dart';
import '../../domain/models/catalog_filter_preset.dart';
import '../../domain/models/food_item.dart';
import 'app_controller.dart';
import 'content_status.dart';

enum PresetSaveResult { created, updated }

class CatalogController extends ChangeNotifier {
  CatalogController({
    required FoodLocalDataSource dataSource,
    ValueListenable<ConnectionOverride>? connectionOverride,
    ValueNotifier<bool>? layoutMode,
    Future<void> Function(bool)? onLayoutModeChanged,
    ValueNotifier<CatalogSortOption>? sortOption,
    Future<void> Function(CatalogSortOption)? onSortOptionChanged,
    CatalogPresetsLocalDataSource? presetsDataSource,
  })
      : _dataSource = dataSource,
        _connectionOverride = connectionOverride,
        _layoutModePersister = onLayoutModeChanged,
        _sortPersister = onSortOptionChanged,
        _presetsDataSource = presetsDataSource ?? CatalogPresetsLocalDataSource(),
        isGridMode = layoutMode ?? ValueNotifier<bool>(true),
        _ownsLayoutMode = layoutMode == null,
        sortOption = sortOption ?? ValueNotifier<CatalogSortOption>(CatalogSortOption.newest),
        _ownsSortOption = sortOption == null,
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
        availableTags = ValueNotifier<List<String>>(<String>[]),
        isPaginating = ValueNotifier<bool>(false),
        status = ValueNotifier<ContentStatus>(ContentStatus.idle),
        errorKey = ValueNotifier<String?>(null),
        presets = ValueNotifier<List<CatalogFilterPreset>>(<CatalogFilterPreset>[]),
        pinnedPresets = ValueNotifier<List<CatalogFilterPreset>>(<CatalogFilterPreset>[]),
        _presetsLoaded = false {
    _connectionOverride?.addListener(_handleConnectionChange);
    this.sortOption.addListener(_handleSortOptionChanged);
  }

  final FoodLocalDataSource _dataSource;
  final ValueListenable<ConnectionOverride>? _connectionOverride;
  final Future<void> Function(bool)? _layoutModePersister;
  final Future<void> Function(CatalogSortOption)? _sortPersister;
  final CatalogPresetsLocalDataSource _presetsDataSource;

  final ValueNotifier<List<FoodItem>> items;
  final ValueNotifier<bool> isLoading;
  final ValueNotifier<bool> isRefreshing;
  final ValueNotifier<bool> hasMore;
  final ValueNotifier<CatalogFilters> filters;
  final ValueNotifier<bool> isGridMode;
  final bool _ownsLayoutMode;
  final ValueNotifier<CatalogSortOption> sortOption;
  final bool _ownsSortOption;
  final ValueNotifier<List<String>> availableTags;
  final ValueNotifier<bool> isPaginating;
  final ValueNotifier<ContentStatus> status;
  final ValueNotifier<String?> errorKey;
  final ValueNotifier<List<CatalogFilterPreset>> presets;
  final ValueNotifier<List<CatalogFilterPreset>> pinnedPresets;

  final int _pageSize = 10;
  List<FoodItem> _allItems = <FoodItem>[];
  List<FoodItem> _filteredItems = <FoodItem>[];
  int _pageIndex = 0;
  RangeValues _priceBounds = const RangeValues(0, 0);
  RangeValues _weightBounds = const RangeValues(0, 0);
  RangeValues _kcalBounds = const RangeValues(0, 0);
  bool _presetsLoaded;

  bool get isReady => _allItems.isNotEmpty;
  RangeValues get priceBounds => _priceBounds;
  RangeValues get weightBounds => _weightBounds;
  RangeValues get kcalBounds => _kcalBounds;

  Future<void> loadInitial({bool force = false}) async {
    if (!force && (items.value.isNotEmpty || status.value == ContentStatus.loading)) {
      return;
    }
    if (force) {
      _allItems = <FoodItem>[];
      _filteredItems = <FoodItem>[];
      _pageIndex = 0;
      items.value = <FoodItem>[];
      hasMore.value = false;
    }
    final connection = _connectionOverride?.value ?? ConnectionOverride.normal;
    if (connection != ConnectionOverride.normal) {
      _handleConnectionChange();
      return;
    }
    await _ensurePresetsLoaded();
    isLoading.value = true;
    status.value = ContentStatus.loading;
    errorKey.value = null;
    try {
      final fetched = await _dataSource.fetchAll();
      _allItems = List<FoodItem>.from(fetched);
      _buildFilters();
      _applyFilters(resetPage: true);
    } catch (_) {
      status.value = ContentStatus.error;
      errorKey.value = 'state_error_message';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refresh() async {
    final connection = _connectionOverride?.value ?? ConnectionOverride.normal;
    if (connection != ConnectionOverride.normal) {
      _handleConnectionChange();
      return;
    }
    await _ensurePresetsLoaded();
    isRefreshing.value = true;
    try {
      final refreshed = await _dataSource.refresh();
      _allItems = List<FoodItem>.from(refreshed);
      _buildFilters();
      _applyFilters(resetPage: true);
    } catch (_) {
      status.value = ContentStatus.error;
      errorKey.value = 'state_error_message';
    } finally {
      isRefreshing.value = false;
    }
  }

  void toggleGridMode() {
    isGridMode.value = !isGridMode.value;
    final persist = _layoutModePersister;
    if (persist != null) {
      unawaited(persist(isGridMode.value));
    }
  }

  void updateSortOption(CatalogSortOption option) {
    if (sortOption.value == option) {
      return;
    }
    sortOption.value = option;
    final persist = _sortPersister;
    if (persist != null) {
      unawaited(persist(option));
    }
  }

  Future<PresetSaveResult> savePreset(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return PresetSaveResult.created;
    }
    await _ensurePresetsLoaded();
    final snapshot = CatalogFilters(
      priceRange: RangeValues(
        filters.value.priceRange.start,
        filters.value.priceRange.end,
      ),
      weightRange: RangeValues(
        filters.value.weightRange.start,
        filters.value.weightRange.end,
      ),
      kcalRange: RangeValues(
        filters.value.kcalRange.start,
        filters.value.kcalRange.end,
      ),
      selectedTags: Set<String>.from(filters.value.selectedTags),
    );
    final presetsList = List<CatalogFilterPreset>.from(presets.value);
    final lower = trimmed.toLowerCase();
    final existingIndex = presetsList.indexWhere(
      (preset) => preset.name.toLowerCase() == lower,
    );
    final now = DateTime.now();
    if (existingIndex >= 0) {
      final existing = presetsList[existingIndex];
      presetsList[existingIndex] = existing.copyWith(
        filters: snapshot,
        name: trimmed,
      );
      await _persistPresets(presetsList);
      return PresetSaveResult.updated;
    }
    final preset = CatalogFilterPreset(
      id: now.microsecondsSinceEpoch.toString(),
      name: trimmed,
      filters: snapshot,
      usageCount: 0,
      createdAt: now,
    );
    presetsList
      ..add(preset)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    await _persistPresets(presetsList);
    return PresetSaveResult.created;
  }

  Future<bool> applyPreset(String id) async {
    await _ensurePresetsLoaded();
    CatalogFilterPreset? preset;
    for (final candidate in presets.value) {
      if (candidate.id == id) {
        preset = candidate;
        break;
      }
    }
    if (preset == null) {
      return false;
    }
    final selected = preset;
    filters.value = CatalogFilters(
      priceRange: RangeValues(
        selected.filters.priceRange.start,
        selected.filters.priceRange.end,
      ),
      weightRange: RangeValues(
        selected.filters.weightRange.start,
        selected.filters.weightRange.end,
      ),
      kcalRange: RangeValues(
        selected.filters.kcalRange.start,
        selected.filters.kcalRange.end,
      ),
      selectedTags: Set<String>.from(selected.filters.selectedTags),
    );
    _applyFilters(resetPage: true);
    await _incrementPresetUsage(selected.id);
    return true;
  }

  Future<bool> deletePreset(String id) async {
    await _ensurePresetsLoaded();
    final presetsList = List<CatalogFilterPreset>.from(presets.value);
    final initialLength = presetsList.length;
    presetsList.removeWhere((preset) => preset.id == id);
    if (presetsList.length == initialLength) {
      return false;
    }
    await _persistPresets(presetsList);
    return true;
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
    final connection = _connectionOverride?.value ?? ConnectionOverride.normal;
    if (connection != ConnectionOverride.normal) {
      _handleConnectionChange();
      return;
    }
    isPaginating.value = true;
    await Future<void>.delayed(const Duration(milliseconds: 260));
    _pageIndex += 1;
    _updatePage();
    isPaginating.value = false;
  }

  void _handleConnectionChange() {
    final connection = _connectionOverride?.value ?? ConnectionOverride.normal;
    if (connection == ConnectionOverride.normal) {
      if (_allItems.isEmpty) {
        unawaited(loadInitial(force: true));
      } else {
        _applyFilters(resetPage: true);
      }
      return;
    }
    isLoading.value = false;
    isRefreshing.value = false;
    isPaginating.value = false;
    switch (connection) {
      case ConnectionOverride.offline:
        status.value = ContentStatus.offline;
        break;
      case ConnectionOverride.error:
        status.value = ContentStatus.error;
        errorKey.value = 'state_error_message';
        break;
      case ConnectionOverride.normal:
        break;
    }
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
    _sortFilteredItems();
    if (resetPage) {
      _pageIndex = 0;
    }
    _updatePage();
  }

  void _sortFilteredItems() {
    switch (sortOption.value) {
      case CatalogSortOption.priceLowToHigh:
        _filteredItems.sort((a, b) => a.price.compareTo(b.price));
        break;
      case CatalogSortOption.priceHighToLow:
        _filteredItems.sort((a, b) => b.price.compareTo(a.price));
        break;
      case CatalogSortOption.kcalLowToHigh:
        _filteredItems.sort((a, b) => a.kcal.compareTo(b.kcal));
        break;
      case CatalogSortOption.kcalHighToLow:
        _filteredItems.sort((a, b) => b.kcal.compareTo(a.kcal));
        break;
      case CatalogSortOption.bestSellers:
        _filteredItems.sort((a, b) => b.popularityScore.compareTo(a.popularityScore));
        break;
      case CatalogSortOption.newest:
        _filteredItems.sort((a, b) => b.addedAt.compareTo(a.addedAt));
        break;
    }
  }

  void _updatePage() {
    final endIndex = min(_filteredItems.length, (_pageIndex + 1) * _pageSize);
    items.value = _filteredItems.take(endIndex).toList();
    hasMore.value = endIndex < _filteredItems.length;
    if (status.value != ContentStatus.offline && status.value != ContentStatus.error) {
      status.value = _filteredItems.isEmpty ? ContentStatus.empty : ContentStatus.success;
    }
  }

  Future<void> retry() => loadInitial(force: true);

  Future<void> _ensurePresetsLoaded() async {
    if (_presetsLoaded) {
      return;
    }
    final stored = await _presetsDataSource.loadPresets();
    stored.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    presets.value = List<CatalogFilterPreset>.unmodifiable(stored);
    _updatePinnedPresets();
    _presetsLoaded = true;
  }

  Future<void> _persistPresets(List<CatalogFilterPreset> entries) async {
    presets.value = List<CatalogFilterPreset>.unmodifiable(entries);
    await _presetsDataSource.savePresets(entries);
    _updatePinnedPresets();
  }

  Future<void> _incrementPresetUsage(String id) async {
    final presetsList = List<CatalogFilterPreset>.from(presets.value);
    final index = presetsList.indexWhere((preset) => preset.id == id);
    if (index == -1) {
      return;
    }
    final now = DateTime.now();
    presetsList[index] = presetsList[index].copyWith(
      usageCount: presetsList[index].usageCount + 1,
      lastUsedAt: now,
    );
    await _persistPresets(presetsList);
  }

  void _updatePinnedPresets() {
    final sorted = List<CatalogFilterPreset>.from(presets.value)
      ..sort((a, b) {
        final usageCompare = b.usageCount.compareTo(a.usageCount);
        if (usageCompare != 0) {
          return usageCompare;
        }
        final lastUsedCompare = b.lastUsedAt.compareTo(a.lastUsedAt);
        if (lastUsedCompare != 0) {
          return lastUsedCompare;
        }
        return b.createdAt.compareTo(a.createdAt);
      });
    pinnedPresets.value = List<CatalogFilterPreset>.unmodifiable(
      sorted.take(3).toList(),
    );
  }

  void _handleSortOptionChanged() {
    _applyFilters(resetPage: true);
  }

  @override
  void dispose() {
    _connectionOverride?.removeListener(_handleConnectionChange);
    sortOption.removeListener(_handleSortOptionChanged);
    items.dispose();
    isLoading.dispose();
    isRefreshing.dispose();
    hasMore.dispose();
    filters.dispose();
    if (_ownsLayoutMode) {
      isGridMode.dispose();
    }
    if (_ownsSortOption) {
      sortOption.dispose();
    }
    availableTags.dispose();
    isPaginating.dispose();
    status.dispose();
    errorKey.dispose();
    presets.dispose();
    pinnedPresets.dispose();
    super.dispose();
  }
}
