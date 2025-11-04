import 'dart:math';

import 'package:flutter/material.dart';
import '../../widgets/simple_flip_card.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/routing/app_router.dart';
import '../../../data/models/car_item.dart';
import '../../../data/repositories_local/car_repository_local.dart';
import '../../../data/repositories_local/search_service.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/refresh_wrapper.dart';
import '../../widgets/scroll_paginator.dart';
import '../../widgets/skeleton_base.dart';
import '../../widgets/skeleton_grid.dart';

class CompareCarsScreen extends StatefulWidget {
  const CompareCarsScreen({super.key});

  @override
  State<CompareCarsScreen> createState() => _CompareCarsScreenState();
}

class _CompareCarsScreenState extends State<CompareCarsScreen> {
  final CarRepositoryLocal _repository = CarRepositoryLocal();
  final List<CarItem> _items = [];
  final List<CarItem> _selected = [];

  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _page = 0;

  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  Map<String, dynamic> _queryFilters = {};
  List<String> _highlightTerms = [];

  double? _minPrice;
  double? _maxPrice;
  double? _minPower;
  double? _maxPower;
  double? _minTorque;
  double? _maxTorque;
  double? _minRange;
  double? _maxRange;
  final Set<String> _selectedTags = <String>{};
  List<String> _availableTags = const [];

  String? _sort;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final tags = await _repository.getAvailableTags();
    if (!mounted) return;
    setState(() => _availableTags = tags);
    await _load();
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
      _items.clear();
      _hasMore = true;
    }

    if (_items.isEmpty) {
      setState(() => _isLoading = true);
    }

    final filters = _buildRequestFilters();
    final pageResult = await _repository.fetchPage(
      page: _page,
      pageSize: AppConstants.pageSizeCars,
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

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMore() async {
    if (!_hasMore || _isLoadingMore) return;
    setState(() => _isLoadingMore = true);
    _page++;
    final filters = _buildRequestFilters();
    final pageResult = await _repository.fetchPage(
      page: _page,
      pageSize: AppConstants.pageSizeCars,
      filters: filters.isEmpty ? null : filters,
      query: _searchText.isEmpty ? null : _searchText,
      sort: _sort,
    );
    _items.addAll(pageResult.items);
    _hasMore = pageResult.hasMore;
    if (mounted) {
      setState(() => _isLoadingMore = false);
    }
  }

  void _applySearch(String raw) {
    final parsed = SearchService.parse(raw);
    setState(() {
      _searchText = parsed.text;
      _queryFilters = parsed.filters;
      _highlightTerms = parsed.highlightTerms;
      _page = 0;
      _hasMore = true;
      _items.clear();
      _searchController.text = raw;
    });
    _load();
  }

  void _toggleSelection(CarItem item) {
    setState(() {
      if (_selected.contains(item)) {
        _selected.remove(item);
      } else if (_selected.length < 4) {
        _selected.add(item);
      }
    });
  }

  void _removeSelection(CarItem item) {
    setState(() => _selected.remove(item));
  }

  Future<void> _openAdvancedFilters(AppLocalizations loc) async {
    final result = await showModalBottomSheet<_CarFilterResult>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _CarFiltersSheet(
        loc: loc,
        initial: _CarFilterResult(
          minPrice: _minPrice,
          maxPrice: _maxPrice,
          minPower: _minPower,
          maxPower: _maxPower,
          minTorque: _minTorque,
          maxTorque: _maxTorque,
          minRange: _minRange,
          maxRange: _maxRange,
          tags: _selectedTags,
          availableTags: _availableTags,
          sort: _sort,
        ),
      ),
    );

    if (result == null) return;

    setState(() {
      _minPrice = result.minPrice;
      _maxPrice = result.maxPrice;
      _minPower = result.minPower;
      _maxPower = result.maxPower;
      _minTorque = result.minTorque;
      _maxTorque = result.maxTorque;
      _minRange = result.minRange;
      _maxRange = result.maxRange;
      _selectedTags
        ..clear()
        ..addAll(result.tags);
      _sort = result.sort;
      _page = 0;
      _hasMore = true;
      _items.clear();
    });
    _load();
  }

  Map<String, dynamic> _buildRequestFilters() {
    final filters = <String, dynamic>{};

    double? mergeMin(String key, double? uiValue) {
      final double? queryValue = _asDouble(_queryFilters['min${key[0].toUpperCase()}${key.substring(1)}']);
      if (queryValue == null) return uiValue;
      if (uiValue == null) return queryValue;
      return max(queryValue, uiValue);
    }

    double? mergeMax(String key, double? uiValue) {
      final double? queryValue = _asDouble(_queryFilters['max${key[0].toUpperCase()}${key.substring(1)}']);
      if (queryValue == null) return uiValue;
      if (uiValue == null) return queryValue;
      return min(queryValue, uiValue);
    }

    final minPrice = mergeMin('price', _minPrice);
    final maxPrice = mergeMax('price', _maxPrice);
    final minPower = mergeMin('power', _minPower);
    final maxPower = mergeMax('power', _maxPower);
    final minTorque = mergeMin('torque', _minTorque);
    final maxTorque = mergeMax('torque', _maxTorque);
    final minRange = mergeMin('range', _minRange);
    final maxRange = mergeMax('range', _maxRange);

    if (minPrice != null) filters['minPrice'] = minPrice;
    if (maxPrice != null) filters['maxPrice'] = maxPrice;
    if (minPower != null) filters['minPower'] = minPower;
    if (maxPower != null) filters['maxPower'] = maxPower;
    if (minTorque != null) filters['minTorque'] = minTorque;
    if (maxTorque != null) filters['maxTorque'] = maxTorque;
    if (minRange != null) filters['minRange'] = minRange;
    if (maxRange != null) filters['maxRange'] = maxRange;

    final combinedTags = <String>{
      ..._selectedTags,
      if (_queryFilters['tags'] is Iterable)
        ...(_queryFilters['tags'] as Iterable).map((tag) => tag.toString().toLowerCase()),
    };
    if (combinedTags.isNotEmpty) {
      filters['tags'] = combinedTags;
    }

    filters.removeWhere((key, value) => value == null);
    return filters;
  }

  double? _asDouble(Object? value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  void _clearAll(AppLocalizations loc) {
    FocusScope.of(context).unfocus();
    setState(() {
      _searchText = '';
      _queryFilters = {};
      _highlightTerms = [];
      _searchController.clear();
      _minPrice = null;
      _maxPrice = null;
      _minPower = null;
      _maxPower = null;
      _minTorque = null;
      _maxTorque = null;
      _minRange = null;
      _maxRange = null;
      _selectedTags.clear();
      _sort = null;
      _page = 0;
      _hasMore = true;
      _items.clear();
    });
    _load();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(loc.translate('reset'))),
    );
  }

  bool get _hasActiveFilters =>
      _searchText.isNotEmpty ||
      _selectedTags.isNotEmpty ||
      _minPrice != null ||
      _maxPrice != null ||
      _minPower != null ||
      _maxPower != null ||
      _minTorque != null ||
      _maxTorque != null ||
      _minRange != null ||
      _maxRange != null ||
      _sort != null ||
      _queryFilters.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return AppScaffold(
      initialIndex: 0,
      showNavigation: false,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(loc.translate('compareTitle'), style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: _applySearch,
                    decoration: InputDecoration(
                      hintText: loc.translate('compareSearchHint'),
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchText.isEmpty
                          ? IconButton(
                              icon: const Icon(Icons.tune),
                              onPressed: () => _openAdvancedFilters(loc),
                            )
                          : IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => _clearAll(loc),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ActionChip(
                        label: Text(loc.translate('filtersAdvanced')),
                        avatar: const Icon(Icons.filter_alt, size: 18),
                        onPressed: () => _openAdvancedFilters(loc),
                      ),
                      _SortChip(
                        currentSort: _sort,
                        onSelected: (value) {
                          setState(() {
                            _sort = value;
                            _page = 0;
                            _hasMore = true;
                            _items.clear();
                          });
                          _load();
                        },
                      ),
                      ..._selectedTags.map(
                        (tag) => InputChip(
                          label: Text(tag),
                          onDeleted: () {
                            setState(() {
                              _selectedTags.remove(tag);
                              _page = 0;
                              _hasMore = true;
                              _items.clear();
                            });
                            _load();
                          },
                        ),
                      ),
                      if (_hasActiveFilters)
                        TextButton.icon(
                          onPressed: () => _clearAll(loc),
                          icon: const Icon(Icons.refresh),
                          label: Text(loc.translate('reset')),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (_selected.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _ComparisonMatrix(
                  cars: _selected,
                  highlightTerms: _highlightTerms,
                  onRemove: _removeSelection,
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    loc.translate('compareSelectedEmpty'),
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _isLoading
                    ? const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: SkeletonGrid(),
                      )
                    : RefreshWrapper(
                        onRefresh: () => _load(refresh: true),
                        child: ScrollPaginator(
                          onFetchMore: _loadMore,
                          hasMore: _hasMore,
                          isLoadingMore: _isLoadingMore,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: _items.isEmpty
                              ? Center(
                                  child: Text(
                                    loc.translate('compareNoCars'),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              : LayoutBuilder(
                                  builder: (context, constraints) {
                                    final width = constraints.maxWidth;
                                    int crossAxisCount = 2;
                                    if (width >= AppConstants.desktopBreakpoint) {
                                      crossAxisCount = 4;
                                    } else if (width >= AppConstants.tabletBreakpoint) {
                                      crossAxisCount = 3;
                                    }
                                    return GridView.builder(
                                      itemCount: _items.length + (_hasMore ? 1 : 0),
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: crossAxisCount,
                                        mainAxisSpacing: 16,
                                        crossAxisSpacing: 16,
                                        childAspectRatio: 0.9,
                                      ),
                                      padding: const EdgeInsets.only(bottom: 24, top: 12),
                                      itemBuilder: (context, index) {
                                        if (index >= _items.length) {
                                          return const _LoadMoreTile();
                                        }
                                        final car = _items[index];
                                        final selected = _selected.contains(car);
                                        return _CarGridTile(
                                          car: car,
                                          selected: selected,
                                          highlightTerms: _highlightTerms,
                                          onToggle: () => _toggleSelection(car),
                                          onView3D: () => Navigator.of(context).pushNamed(AppRoutes.carViewer, arguments: car.id),
                                        );
                                      },
                                    );
                                  },
                                ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  const _SortChip({
    required this.currentSort,
    required this.onSelected,
  });

  final String? currentSort;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final label = () {
      switch (currentSort) {
        case 'price_asc':
          return loc.translate('compareSortPriceLowHigh');
        case 'price_desc':
          return loc.translate('compareSortPriceHighLow');
        case 'power_desc':
          return loc.translate('compareSortPowerHighLow');
        case 'range_desc':
          return loc.translate('compareSortRangeHighLow');
        default:
          return loc.translate('compareSortRecommended');
      }
    }();

    return PopupMenuButton<String?>(
      onSelected: onSelected,
      itemBuilder: (context) => [
        PopupMenuItem(value: null, child: Text(loc.translate('compareSortRecommended'))),
        PopupMenuItem(value: 'price_asc', child: Text(loc.translate('compareSortPriceLowHigh'))),
        PopupMenuItem(value: 'price_desc', child: Text(loc.translate('compareSortPriceHighLow'))),
        PopupMenuItem(value: 'power_desc', child: Text(loc.translate('compareSortPowerHighLow'))),
        PopupMenuItem(value: 'range_desc', child: Text(loc.translate('compareSortRangeHighLow'))),
      ],
      child: Chip(
        avatar: Icon(Icons.sort, color: theme.colorScheme.primary),
        label: Text(label),
      ),
    );
  }
}

class _CarGridTile extends StatelessWidget {
  const _CarGridTile({
    required this.car,
    required this.selected,
    required this.highlightTerms,
    required this.onToggle,
    required this.onView3D,
  });

  final CarItem car;
  final bool selected;
  final List<String> highlightTerms;
  final VoidCallback onToggle;
  final VoidCallback onView3D;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isArabic = Directionality.of(context) == TextDirection.rtl;
    final displayName = isArabic ? car.nameAr : car.nameEn;
    final foregroundColor = selected ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurface;
    return RepaintBoundary(
      child: Material(
        borderRadius: BorderRadius.circular(20),
        color: selected ? theme.colorScheme.primaryContainer : theme.colorScheme.surface,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      car.imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const SkeletonBase();
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: theme.colorScheme.surfaceVariant,
                        child: const Icon(Icons.directions_car),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _HighlightedText(
                  text: displayName,
                  highlightTerms: highlightTerms,
                  style: theme.textTheme.titleMedium?.copyWith(color: foregroundColor),
                ),
                Text(
                  '${car.price.toStringAsFixed(0)} USD',
                  style: theme.textTheme.labelLarge?.copyWith(color: foregroundColor.withOpacity(0.9)),
                ),
                const SizedBox(height: 4),
                Text(
                  '${car.powerHp} hp • ${car.rangeKmOrConsumption} km',
                  style: theme.textTheme.bodySmall?.copyWith(color: foregroundColor.withOpacity(0.8)),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Tooltip(
                      message: loc.translate('compareFlipHint'),
                      child: Icon(selected ? Icons.check_circle : Icons.compare_arrows, color: foregroundColor),
                    ),
                    Tooltip(
                      message: loc.translate('compareOpenViewer'),
                      child: IconButton(
                        icon: Icon(Icons.view_in_ar, color: foregroundColor),
                        onPressed: onView3D,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadMoreTile extends StatelessWidget {
  const _LoadMoreTile();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _ComparisonMatrix extends StatelessWidget {
  const _ComparisonMatrix({
    required this.cars,
    required this.highlightTerms,
    required this.onRemove,
  });

  final List<CarItem> cars;
  final List<String> highlightTerms;
  final ValueChanged<CarItem> onRemove;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isArabic = Directionality.of(context) == TextDirection.rtl;
    final listSeparator = isArabic ? '، ' : ', ';
    final specs = [
      _SpecRow(label: loc.translate('compareSpecPrice'), value: (car) => '${car.price.toStringAsFixed(0)} USD'),
      _SpecRow(label: loc.translate('compareSpecPower'), value: (car) => '${car.powerHp} hp'),
      _SpecRow(label: loc.translate('compareSpecTorque'), value: (car) => '${car.torqueNm} Nm'),
      _SpecRow(label: loc.translate('compareSpecAcceleration'), value: (car) => '${car.zeroTo100}s'),
      _SpecRow(label: loc.translate('compareSpecRange'), value: (car) => '${car.rangeKmOrConsumption} km'),
      _SpecRow(label: loc.translate('compareSpecTags'), value: (car) => car.tags.join(listSeparator)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(loc.translate('compareSelectedHeader'), style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        SizedBox(
          height: 230,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
              borderRadius: BorderRadius.circular(24),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: specs
                        .map((spec) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(spec.label, style: theme.textTheme.bodyMedium),
                            ))
                        .toList(),
                  ),
                  const SizedBox(width: 16),
                  ...cars.map(
                    (car) => Padding(
                      padding: const EdgeInsetsDirectional.only(end: 16),
                      child: SizedBox(
                        width: 220,
                        child: FlipCard(
                          front: _ComparisonFrontCard(car: car, highlightTerms: highlightTerms, isArabic: isArabic),
                          back: _ComparisonBackCard(car: car, specs: specs, onRemove: () => onRemove(car), isArabic: isArabic),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ComparisonFrontCard extends StatelessWidget {
  const _ComparisonFrontCard({required this.car, required this.highlightTerms, required this.isArabic});

  final CarItem car;
  final List<String> highlightTerms;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final displayName = isArabic ? car.nameAr : car.nameEn;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  car.imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const SkeletonBase();
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    child: const Icon(Icons.directions_car),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            _HighlightedText(text: displayName, highlightTerms: highlightTerms, style: theme.textTheme.titleSmall),
            Text('${car.price.toStringAsFixed(0)} USD', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text('${car.powerHp} hp • ${car.rangeKmOrConsumption} km', style: theme.textTheme.bodySmall),
            Align(
              alignment: AlignmentDirectional.bottomEnd,
              child: Tooltip(
                message: loc.translate('compareFlipHint'),
                child: const Icon(Icons.autorenew, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComparisonBackCard extends StatelessWidget {
  const _ComparisonBackCard({required this.car, required this.specs, required this.onRemove, required this.isArabic});

  final CarItem car;
  final List<_SpecRow> specs;
  final VoidCallback onRemove;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final displayName = isArabic ? car.nameAr : car.nameEn;
    return Card(
      color: Theme.of(context).colorScheme.surfaceVariant,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(displayName, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            ...specs.map(
              (spec) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text('${spec.label}: ${spec.value(car)}'),
              ),
            ),
            const Spacer(),
            Align(
              alignment: AlignmentDirectional.bottomEnd,
              child: Tooltip(
                message: loc.translate('compareRemove'),
                child: IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: onRemove,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpecRow {
  const _SpecRow({required this.label, required this.value});

  final String label;
  final String Function(CarItem car) value;
}

class _HighlightedText extends StatelessWidget {
  const _HighlightedText({
    required this.text,
    required this.highlightTerms,
    required this.style,
  });

  final String text;
  final List<String> highlightTerms;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    if (highlightTerms.isEmpty) {
      return Text(text, style: style, maxLines: 2, overflow: TextOverflow.ellipsis);
    }

    final lowerText = SearchService.normalize(text);
    final spans = <TextSpan>[];
    var cursor = 0;

    while (cursor < text.length) {
      int? matchStart;
      int? matchEnd;
      for (final term in highlightTerms) {
        final normalizedTerm = SearchService.normalize(term);
        if (normalizedTerm.isEmpty) continue;
        final index = lowerText.indexOf(normalizedTerm, cursor);
        if (index != -1 && (matchStart == null || index < matchStart)) {
          matchStart = index;
          matchEnd = index + normalizedTerm.length;
        }
      }

      if (matchStart == null || matchEnd == null) {
        spans.add(TextSpan(text: text.substring(cursor)));
        break;
      }

      if (matchStart > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, matchStart)));
      }

      final safeEnd = matchEnd > text.length ? text.length : matchEnd;
      spans.add(TextSpan(
        text: text.substring(matchStart, safeEnd),
        style: TextStyle(backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.3)),
      ));

      cursor = safeEnd;
    }

    return RichText(
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(style: style ?? Theme.of(context).textTheme.bodyMedium, children: spans),
    );
  }
}

class _CarFiltersSheet extends StatefulWidget {
  const _CarFiltersSheet({required this.loc, required this.initial});

  final AppLocalizations loc;
  final _CarFilterResult initial;

  @override
  State<_CarFiltersSheet> createState() => _CarFiltersSheetState();
}

class _CarFiltersSheetState extends State<_CarFiltersSheet> {
  late final TextEditingController _minPriceController;
  late final TextEditingController _maxPriceController;
  late final TextEditingController _minPowerController;
  late final TextEditingController _maxPowerController;
  late final TextEditingController _minTorqueController;
  late final TextEditingController _maxTorqueController;
  late final TextEditingController _minRangeController;
  late final TextEditingController _maxRangeController;
  late Set<String> _tags;
  String? _sort;

  @override
  void initState() {
    super.initState();
    _minPriceController = TextEditingController(text: widget.initial.minPrice?.toString() ?? '');
    _maxPriceController = TextEditingController(text: widget.initial.maxPrice?.toString() ?? '');
    _minPowerController = TextEditingController(text: widget.initial.minPower?.toString() ?? '');
    _maxPowerController = TextEditingController(text: widget.initial.maxPower?.toString() ?? '');
    _minTorqueController = TextEditingController(text: widget.initial.minTorque?.toString() ?? '');
    _maxTorqueController = TextEditingController(text: widget.initial.maxTorque?.toString() ?? '');
    _minRangeController = TextEditingController(text: widget.initial.minRange?.toString() ?? '');
    _maxRangeController = TextEditingController(text: widget.initial.maxRange?.toString() ?? '');
    _tags = Set<String>.from(widget.initial.tags);
    _sort = widget.initial.sort;
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _minPowerController.dispose();
    _maxPowerController.dispose();
    _minTorqueController.dispose();
    _maxTorqueController.dispose();
    _minRangeController.dispose();
    _maxRangeController.dispose();
    super.dispose();
  }

  double? _parse(TextEditingController controller) {
    return double.tryParse(controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final loc = widget.loc;
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets),
      child: DraggableScrollableSheet(
        expand: false,
        builder: (context, controller) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: ListView(
              controller: controller,
              children: [
                Text(loc.translate('compareFiltersTitle'), style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                _RangeRow(title: loc.translate('compareFiltersPrice'), minController: _minPriceController, maxController: _maxPriceController),
                const SizedBox(height: 12),
                _RangeRow(title: loc.translate('compareFiltersPower'), minController: _minPowerController, maxController: _maxPowerController),
                const SizedBox(height: 12),
                _RangeRow(title: loc.translate('compareFiltersTorque'), minController: _minTorqueController, maxController: _maxTorqueController),
                const SizedBox(height: 12),
                _RangeRow(title: loc.translate('compareFiltersRange'), minController: _minRangeController, maxController: _maxRangeController),
                const SizedBox(height: 24),
                Text(loc.translate('compareFiltersTags'), style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.initial.availableTags
                      .map(
                        (tag) => FilterChip(
                          label: Text(tag),
                          selected: _tags.contains(tag),
                          onSelected: (value) {
                            setState(() {
                              if (value) {
                                _tags.add(tag);
                              } else {
                                _tags.remove(tag);
                              }
                            });
                          },
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
                Text(loc.translate('compareFiltersSort'), style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                DropdownButton<String?>(
                  value: _sort,
                  isExpanded: true,
                  onChanged: (value) => setState(() => _sort = value),
                  items: [
                    DropdownMenuItem(value: null, child: Text(loc.translate('compareSortRecommended'))),
                    DropdownMenuItem(value: 'price_asc', child: Text(loc.translate('compareSortPriceLowHigh'))),
                    DropdownMenuItem(value: 'price_desc', child: Text(loc.translate('compareSortPriceHighLow'))),
                    DropdownMenuItem(value: 'power_desc', child: Text(loc.translate('compareSortPowerHighLow'))),
                    DropdownMenuItem(value: 'range_desc', child: Text(loc.translate('compareSortRangeHighLow'))),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _minPriceController.clear();
                            _maxPriceController.clear();
                            _minPowerController.clear();
                            _maxPowerController.clear();
                            _minTorqueController.clear();
                            _maxTorqueController.clear();
                            _minRangeController.clear();
                            _maxRangeController.clear();
                            _tags.clear();
                            _sort = null;
                          });
                        },
                        child: Text(loc.translate('reset')),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(
                            _CarFilterResult(
                              minPrice: _parse(_minPriceController),
                              maxPrice: _parse(_maxPriceController),
                              minPower: _parse(_minPowerController),
                              maxPower: _parse(_maxPowerController),
                              minTorque: _parse(_minTorqueController),
                              maxTorque: _parse(_maxTorqueController),
                              minRange: _parse(_minRangeController),
                              maxRange: _parse(_maxRangeController),
                              tags: _tags,
                              availableTags: widget.initial.availableTags,
                              sort: _sort,
                            ),
                          );
                        },
                        child: Text(loc.translate('apply')),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RangeRow extends StatelessWidget {
  const _RangeRow({
    required this.title,
    required this.minController,
    required this.maxController,
  });

  final String title;
  final TextEditingController minController;
  final TextEditingController maxController;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: minController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: loc.translate('filtersMin')),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: maxController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: loc.translate('filtersMax')),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CarFilterResult {
  _CarFilterResult({
    this.minPrice,
    this.maxPrice,
    this.minPower,
    this.maxPower,
    this.minTorque,
    this.maxTorque,
    this.minRange,
    this.maxRange,
    required this.tags,
    required this.availableTags,
    this.sort,
  });

  final double? minPrice;
  final double? maxPrice;
  final double? minPower;
  final double? maxPower;
  final double? minTorque;
  final double? maxTorque;
  final double? minRange;
  final double? maxRange;
  final Set<String> tags;
  final Iterable<String> availableTags;
  final String? sort;
}
