import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/locale/localization_extension.dart';
import '../../../domain/models/food_item.dart';
import '../../controllers/catalog_controller.dart';
import '../../widgets/food_card.dart';
import '../item/item_details_page.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key, required this.controller});

  static const routeName = '/catalog';

  final CatalogController controller;

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  late final ScrollController _scrollController;

  CatalogController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_handleScroll);
    _controller.loadInitial();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_controller.hasMore.value) {
      return;
    }
    if (_scrollController.position.pixels >
        _scrollController.position.maxScrollExtent - 200) {
      _controller.loadMore();
    }
  }

  Future<void> _onRefresh() async {
    await _controller.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('catalog_title')),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: _controller.isGridMode,
            builder: (context, isGrid, _) {
              return IconButton(
                onPressed: _controller.toggleGridMode,
                icon: Icon(isGrid ? Icons.view_agenda_outlined : Icons.grid_view_rounded),
                tooltip: isGrid ? context.tr('list_view') : context.tr('grid_view'),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: ValueListenableBuilder<bool>(
          valueListenable: _controller.isLoading,
          builder: (context, isLoading, _) {
            return NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is OverscrollNotification &&
                    notification.overscroll > 0 &&
                    _controller.hasMore.value) {
                  _controller.loadMore();
                }
                return false;
              },
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                controller: _scrollController,
                slivers: [
                  SliverToBoxAdapter(child: _FiltersPanel(controller: _controller)),
                  if (isLoading)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => const FoodCardSkeleton(),
                          childCount: 8,
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      sliver: ValueListenableBuilder<List<FoodItem>>(
                        valueListenable: _controller.items,
                        builder: (context, items, _) {
                          if (items.isEmpty) {
                            return SliverFillRemaining(
                              hasScrollBody: false,
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.search_off, size: 40),
                                    const SizedBox(height: 12),
                                    Text(
                                      context.tr('catalog_empty'),
                                      style: theme.textTheme.titleMedium,
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          return ValueListenableBuilder<bool>(
                            valueListenable: _controller.isGridMode,
                            builder: (context, isGrid, _) {
                              if (isGrid) {
                                return SliverGrid(
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 0.75,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                  ),
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      final item = items[index];
                                      return FoodCard(
                                        item: item,
                                        onTap: () => Navigator.of(context)
                                            .pushNamed(ItemDetailsPage.routeName, arguments: item),
                                        onAdd: () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('${context.tr('added_to_cart')} ${item.name}'),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    childCount: items.length,
                                  ),
                                );
                              }
                              return SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                  final item = items[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: FoodCard(
                                      item: item,
                                      onTap: () => Navigator.of(context)
                                          .pushNamed(ItemDetailsPage.routeName, arguments: item),
                                      onAdd: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('${context.tr('added_to_cart')} ${item.name}'),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                  },
                                  childCount: items.length,
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: ValueListenableBuilder<bool>(
                      valueListenable: _controller.hasMore,
                      builder: (context, hasMore, _) {
                        if (!hasMore) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: Text(
                                context.tr('catalog_end'),
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                          );
                        }
                        return ValueListenableBuilder<bool>(
                          valueListenable: _controller.isPaginating,
                          builder: (context, paginating, __) {
                            if (paginating) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 24),
                                child: Center(
                                  child: const CircularProgressIndicator()
                                      .animate(onPlay: (controller) => controller.repeat()),
                                ),
                              );
                            }
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: TextButton.icon(
                                  onPressed: _controller.loadMore,
                                  icon: const Icon(Icons.expand_more),
                                  label: Text(context.tr('load_more')),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FiltersPanel extends StatelessWidget {
  const _FiltersPanel({required this.controller});

  final CatalogController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ValueListenableBuilder<CatalogFilters>(
      valueListenable: controller.filters,
      builder: (context, filters, _) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.tr('filters_title'), style: theme.textTheme.titleMedium),
              const SizedBox(height: 16),
              _RangeTile(
                title: context.tr('filters_price'),
                range: filters.priceRange,
                min: controller.priceBounds.start,
                max: controller.priceBounds.end,
                labels: RangeLabels(
                  '\\$${filters.priceRange.start.toStringAsFixed(0)}',
                  '\\$${filters.priceRange.end.toStringAsFixed(0)}',
                ),
                onChanged: controller.updatePrice,
              ),
              const SizedBox(height: 12),
              _RangeTile(
                title: context.tr('filters_weight'),
                range: filters.weightRange,
                min: controller.weightBounds.start,
                max: controller.weightBounds.end,
                labels: RangeLabels(
                  '${filters.weightRange.start.toStringAsFixed(0)} g',
                  '${filters.weightRange.end.toStringAsFixed(0)} g',
                ),
                onChanged: controller.updateWeight,
              ),
              const SizedBox(height: 12),
              _RangeTile(
                title: context.tr('filters_kcal'),
                range: filters.kcalRange,
                min: controller.kcalBounds.start,
                max: controller.kcalBounds.end,
                labels: RangeLabels(
                  '${filters.kcalRange.start.toStringAsFixed(0)} kcal',
                  '${filters.kcalRange.end.toStringAsFixed(0)} kcal',
                ),
                onChanged: controller.updateKcal,
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<List<String>>(
                valueListenable: controller.availableTags,
                builder: (context, tags, _) {
                  if (tags.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: tags
                        .map(
                          (tag) => FilterChip(
                            label: Text(tag),
                            selected: filters.selectedTags.contains(tag),
                            onSelected: (_) => controller.toggleTag(tag),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RangeTile extends StatelessWidget {
  const _RangeTile({
    required this.title,
    required this.range,
    required this.min,
    required this.max,
    required this.labels,
    required this.onChanged,
  });

  final String title;
  final RangeValues range;
  final double min;
  final double max;
  final RangeLabels labels;
  final ValueChanged<RangeValues> onChanged;

  @override
  Widget build(BuildContext context) {
    final effectiveMin = min.floorToDouble();
    final effectiveMax = max.ceilToDouble();
    final rawSpan = effectiveMax - effectiveMin;
    final divisions = rawSpan <= 1 ? null : rawSpan.round();
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            RangeSlider(
              values: range,
              min: effectiveMin,
              max: effectiveMax == effectiveMin ? effectiveMin + 1 : effectiveMax,
              divisions: divisions,
              labels: labels,
              onChanged: (value) {
                if (value.start <= value.end) {
                  onChanged(value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
