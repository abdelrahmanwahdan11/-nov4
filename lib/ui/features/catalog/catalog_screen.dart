import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../data/models/food_item.dart';
import '../../../data/repositories_local/food_repository_local.dart';
import '../../../data/repositories_local/search_service.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/refresh_wrapper.dart';
import '../../widgets/scroll_paginator.dart';
import '../../widgets/skeleton_base.dart';
import '../../widgets/skeleton_grid.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final FoodRepositoryLocal _repository = FoodRepositoryLocal();
  final List<FoodItem> _items = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  bool _gridMode = true;
  bool _veganOnly = false;
  bool _newOnly = false;
  String? _sort;
  int _page = 0;
  String _searchText = '';
  Map<String, dynamic> _queryFilters = {};
  final Set<String> _selectedTags = <String>{};
  double? _minPrice;
  double? _maxPrice;
  double? _minKcal;
  double? _maxKcal;
  final TextEditingController _searchController = TextEditingController();
  List<String> _highlightTerms = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load({bool refresh = false}) async {
    if (refresh) {
      await _repository.refresh();
      _page = 0;
      _hasMore = true;
      _items.clear();
    }
    if (_items.isEmpty) {
      setState(() => _isLoading = true);
    }
    final filters = _buildRequestFilters();
    final pageResult = await _repository.fetchPage(
      page: _page,
      pageSize: AppConstants.pageSizeFoods,
      filters: filters.isEmpty ? null : filters,
      query: _searchText.isEmpty ? null : _searchText,
      sort: _sort,
    );
    if (_page == 0) {
      _items
        ..clear()
        ..addAll(pageResult.items);
    } else {
      _items.addAll(pageResult.items);
    }
    _hasMore = pageResult.hasMore;
    setState(() => _isLoading = false);
  }

  Future<void> _loadMore() async {
    if (!_hasMore || _isLoadingMore) return;
    setState(() => _isLoadingMore = true);
    _page++;
    final filters = _buildRequestFilters();
    final pageResult = await _repository.fetchPage(
      page: _page,
      pageSize: AppConstants.pageSizeFoods,
      filters: filters.isEmpty ? null : filters,
      query: _searchText.isEmpty ? null : _searchText,
      sort: _sort,
    );
    _items.addAll(pageResult.items);
    _hasMore = pageResult.hasMore;
    setState(() => _isLoadingMore = false);
  }

  void _applySearch(String raw) {
    final parsed = SearchService.parse(raw);
    setState(() {
      _searchText = parsed.text;
      _queryFilters = parsed.filters;
      _highlightTerms = parsed.highlightTerms;
      _searchController.text = raw;
      _page = 0;
      _hasMore = true;
      _items.clear();
    });
    _load();
  }

  void _toggleFilter(bool vegan) {
    setState(() {
      if (vegan) {
        _veganOnly = !_veganOnly;
      } else {
        _newOnly = !_newOnly;
      }
      _page = 0;
      _hasMore = true;
      _items.clear();
    });
    _load();
  }

  void _chooseSort(String? value) {
    setState(() {
      _sort = value;
      _page = 0;
      _hasMore = true;
      _items.clear();
    });
    _load();
  }

  Future<void> _openAdvancedFilters() async {
    final tags = await _repository.getAvailableTags();
    final result = await _showAdvancedFilters(tags);
    if (result == null) return;
    setState(() {
      _minPrice = result.minPrice;
      _maxPrice = result.maxPrice;
      _minKcal = result.minKcal;
      _maxKcal = result.maxKcal;
      _selectedTags
        ..clear()
        ..addAll(result.tags);
      _page = 0;
      _hasMore = true;
      _items.clear();
    });
    _load();
  }

  Map<String, dynamic> _buildRequestFilters() {
    final filters = <String, dynamic>{};
    final dynamic queryVegan = _queryFilters['vegan'];
    if (_veganOnly || queryVegan == true) {
      filters['vegan'] = true;
    } else if (queryVegan == false) {
      filters['vegan'] = false;
    }
    final dynamic queryNew = _queryFilters['isNew'];
    if (_newOnly || queryNew == true) {
      filters['isNew'] = true;
    } else if (queryNew == false) {
      filters['isNew'] = false;
    }

    final mergedMinPrice = _mergeMin('minPrice', _minPrice);
    final mergedMaxPrice = _mergeMax('maxPrice', _maxPrice);
    final mergedMinKcal = _mergeMin('minKcal', _minKcal);
    final mergedMaxKcal = _mergeMax('maxKcal', _maxKcal);

    if (mergedMinPrice != null) filters['minPrice'] = mergedMinPrice;
    if (mergedMaxPrice != null) filters['maxPrice'] = mergedMaxPrice;
    if (mergedMinKcal != null) filters['minKcal'] = mergedMinKcal;
    if (mergedMaxKcal != null) filters['maxKcal'] = mergedMaxKcal;

    final queryTags = _queryFilters['tags'];
    final combinedTags = <String>{
      ..._selectedTags.map((tag) => tag.toLowerCase()),
      if (queryTags is Iterable)
        ...queryTags.map((tag) => tag.toString().toLowerCase()),
    };
    if (combinedTags.isNotEmpty) {
      filters['tags'] = combinedTags;
    }

    filters.removeWhere((key, value) => value == null || (value is Iterable && value.isEmpty));
    return filters;
  }

  double? _mergeMin(String key, double? uiValue) {
    final double? queryValue = _asDouble(_queryFilters[key]);
    if (queryValue == null) return uiValue;
    if (uiValue == null) return queryValue;
    return queryValue > uiValue ? queryValue : uiValue;
  }

  double? _mergeMax(String key, double? uiValue) {
    final double? queryValue = _asDouble(_queryFilters[key]);
    if (queryValue == null) return uiValue;
    if (uiValue == null) return queryValue;
    return queryValue < uiValue ? queryValue : uiValue;
  }

  double? _asDouble(Object? value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Future<_AdvancedFiltersResult?> _showAdvancedFilters(List<String> tags) {
    final loc = AppLocalizations.of(context);
    final minPriceController = TextEditingController(text: _minPrice?.toString() ?? '');
    final maxPriceController = TextEditingController(text: _maxPrice?.toString() ?? '');
    final minKcalController = TextEditingController(text: _minKcal?.toString() ?? '');
    final maxKcalController = TextEditingController(text: _maxKcal?.toString() ?? '');
    final tempTags = <String>{..._selectedTags};
    return showModalBottomSheet<_AdvancedFiltersResult>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: StatefulBuilder(
            builder: (context, modalSetState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(loc.translate('filtersAdvanced'), style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  Text(loc.translate('filtersPriceRange'), style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: minPriceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(labelText: loc.translate('filtersMin')),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: maxPriceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(labelText: loc.translate('filtersMax')),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(loc.translate('filtersCaloriesRange'), style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: minKcalController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(labelText: loc.translate('filtersMin')),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: maxKcalController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(labelText: loc.translate('filtersMax')),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(loc.translate('filtersTags'), style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: tags
                        .map(
                          (tag) => FilterChip(
                            label: Text(tag),
                            selected: tempTags.contains(tag),
                            onSelected: (selected) {
                              modalSetState(() {
                                if (selected) {
                                  tempTags.add(tag);
                                } else {
                                  tempTags.remove(tag);
                                }
                              });
                            },
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          modalSetState(() {
                            minPriceController.clear();
                            maxPriceController.clear();
                            minKcalController.clear();
                            maxKcalController.clear();
                            tempTags.clear();
                          });
                        },
                        child: Text(loc.translate('reset')),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(
                            _AdvancedFiltersResult(
                              minPrice: _asDouble(minPriceController.text),
                              maxPrice: _asDouble(maxPriceController.text),
                              minKcal: _asDouble(minKcalController.text),
                              maxKcal: _asDouble(maxKcalController.text),
                              tags: tempTags,
                            ),
                          );
                        },
                        child: Text(loc.translate('apply')),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return AppScaffold(
      currentIndex: 1,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(loc.translate('catalogTitle'), style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: _applySearch,
                    decoration: InputDecoration(
                      hintText: loc.translate('searchHint'),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          if (_searchController.text.isEmpty) return;
                          _searchController.clear();
                          _applySearch('');
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilterChip(
                        label: Text(loc.translate('vegan')),
                        selected: _veganOnly,
                        onSelected: (_) => _toggleFilter(true),
                      ),
                      FilterChip(
                        label: Text(loc.translate('newItem')),
                        selected: _newOnly,
                        onSelected: (_) => _toggleFilter(false),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.tune, size: 18),
                        label: Text(loc.translate('filtersAdvanced')),
                        onPressed: _openAdvancedFilters,
                      ),
                      DropdownButton<String>(
                        value: _sort,
                        hint: Text(loc.translate('sortLabel')),
                        items: [
                          DropdownMenuItem(value: 'price_asc', child: Text(loc.translate('sortPriceLowHigh'))),
                          DropdownMenuItem(value: 'price_desc', child: Text(loc.translate('sortPriceHighLow'))),
                          DropdownMenuItem(value: 'kcal_asc', child: Text(loc.translate('sortCaloriesLowHigh'))),
                          DropdownMenuItem(value: 'kcal_desc', child: Text(loc.translate('sortCaloriesHighLow'))),
                          DropdownMenuItem(value: 'newest', child: Text(loc.translate('sortNewest'))),
                        ],
                        onChanged: _chooseSort,
                      ),
                      IconButton(
                        tooltip: _gridMode ? loc.translate('viewAsList') : loc.translate('viewAsGrid'),
                        icon: Icon(_gridMode ? Icons.view_list : Icons.grid_view),
                        onPressed: () => setState(() => _gridMode = !_gridMode),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _isLoading
                    ? const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: SkeletonGrid(),
                      )
                    : _items.isEmpty
                        ? _buildEmptyState(loc)
                        : RefreshWrapper(
                            onRefresh: () async {
                              _page = 0;
                              _hasMore = true;
                              _items.clear();
                              await _load(refresh: true);
                            },
                            child: ScrollPaginator(
                              onFetchMore: _loadMore,
                              hasMore: _hasMore,
                              isLoadingMore: _isLoadingMore,
                              child: _gridMode ? _buildGrid(loc) : _buildList(loc),
                            ),
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations loc) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 48, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 12),
          Text(
            loc.translate('noResultsFound'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildList(AppLocalizations loc) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      itemCount: _items.length + 1,
      itemBuilder: (context, index) {
        if (index == _items.length) {
          if (_isLoadingMore) {
            return _buildLoadingMore(loc);
          }
          if (!_hasMore) {
            return _buildEndOfList(loc);
          }
          return const SizedBox.shrink();
        }
        final item = _items[index];
        final title = loc.locale.languageCode == 'ar' ? item.titleAr : item.titleEn;
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Image.network(
                item.imageUrl,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const SizedBox(width: 56, height: 56, child: SkeletonBase());
                },
                errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
              ),
            ),
            title: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.titleMedium,
                children: _highlightTextSpans(context, title),
              ),
            ),
            subtitle: Text('${item.grams.toStringAsFixed(0)} g • ${item.kcal.toStringAsFixed(0)} kcal'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${item.price.toStringAsFixed(2)}'),
                if (item.isNew)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      loc.translate('newItem'),
                      style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGrid(AppLocalizations loc) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 900
        ? 4
        : width > 600
            ? 3
            : 2;
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: _items.length + 1,
      itemBuilder: (context, index) {
        if (index == _items.length) {
          if (_isLoadingMore) {
            return _buildLoadingMore(loc);
          }
          if (!_hasMore) {
            return _buildEndOfList(loc);
          }
          return const SizedBox.shrink();
        }
        final item = _items[index];
        final title = loc.locale.languageCode == 'ar' ? item.titleAr : item.titleEn;
        return Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Image.network(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const SkeletonBase();
                  },
                  errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.image_not_supported)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.titleMedium,
                        children: _highlightTextSpans(context, title),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('${item.grams.toStringAsFixed(0)} g • ${item.kcal.toStringAsFixed(0)} kcal',
                        style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 4),
                    Text('${item.price.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleSmall),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingMore(AppLocalizations loc) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
          const SizedBox(width: 12),
          Text(loc.translate('loadingMore')),
        ],
      ),
    );
  }

  Widget _buildEndOfList(AppLocalizations loc) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text(
          loc.translate('noMoreItems'),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }

  List<TextSpan> _highlightTextSpans(BuildContext context, String source) {
    if (_highlightTerms.isEmpty || source.isEmpty) {
      return [TextSpan(text: source)];
    }
    final matches = <_HighlightMatch>[];
    final lowercaseSource = source.toLowerCase();
    for (final term in _highlightTerms) {
      final normalized = term.toLowerCase();
      if (normalized.isEmpty) continue;
      for (final match in RegExp(RegExp.escape(normalized), caseSensitive: false).allMatches(lowercaseSource)) {
        matches.add(_HighlightMatch(start: match.start, end: match.end));
      }
    }
    if (matches.isEmpty) {
      return [TextSpan(text: source)];
    }
    matches.sort((a, b) => a.start.compareTo(b.start));
    final merged = <_HighlightMatch>[];
    for (final match in matches) {
      if (merged.isEmpty) {
        merged.add(match);
        continue;
      }
      final last = merged.last;
      if (match.start <= last.end) {
        if (match.end > last.end) {
          merged[merged.length - 1] = _HighlightMatch(start: last.start, end: match.end);
        }
      } else {
        merged.add(match);
      }
    }
    final spans = <TextSpan>[];
    int currentIndex = 0;
    final highlightStyle = TextStyle(
      color: Theme.of(context).colorScheme.primary,
      fontWeight: FontWeight.w600,
    );
    for (final match in merged) {
      if (match.start > currentIndex) {
        spans.add(TextSpan(text: source.substring(currentIndex, match.start)));
      }
      spans.add(TextSpan(text: source.substring(match.start, match.end), style: highlightStyle));
      currentIndex = match.end;
    }
    if (currentIndex < source.length) {
      spans.add(TextSpan(text: source.substring(currentIndex)));
    }
    return spans;
  }
}

class _AdvancedFiltersResult {
  _AdvancedFiltersResult({
    required this.minPrice,
    required this.maxPrice,
    required this.minKcal,
    required this.maxKcal,
    required this.tags,
  });

  final double? minPrice;
  final double? maxPrice;
  final double? minKcal;
  final double? maxKcal;
  final Set<String> tags;
}

class _HighlightMatch {
  const _HighlightMatch({required this.start, required this.end});

  final int start;
  final int end;
}
