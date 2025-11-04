import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/locale/localization_extension.dart';
import '../../../core/theme/theme_tokens.dart';
import '../../../core/utils/responsive.dart';
import '../../../domain/models/food_item.dart';
import '../../controllers/app_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/catalog_controller.dart';
import '../../controllers/content_status.dart';
import '../../controllers/favorites_controller.dart';
import '../../widgets/content_state_view.dart';
import '../../widgets/food_card.dart';
import '../../widgets/quick_action_card.dart';
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
  CartController? _cartController;
  FavoritesController? _favoritesController;

  CatalogController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_handleScroll);
    _controller.loadInitial();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cartController = CartScope.of(context);
    _favoritesController = FavoritesScope.maybeOf(context);
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

  Future<void> _addToCart(FoodItem item) async {
    final controller = _cartController;
    if (controller != null) {
      await controller.addItem(item);
    }
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${context.tr('added_to_cart')} ${item.name}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildCard(FoodItem item) {
    final favorites = _favoritesController;
    if (favorites == null) {
      return FoodCard(
        item: item,
        onTap: () => Navigator.of(context).pushNamed(
          ItemDetailsPage.routeName,
          arguments: item,
        ),
        onAdd: () {
          _addToCart(item);
        },
      );
    }
    return ValueListenableBuilder<List<String>>(
      valueListenable: favorites.favoriteIds,
      builder: (context, ids, _) {
        final isFavorite = ids.contains(item.id);
        final favoriteLabel = context.tr(isFavorite ? 'action_unfavorite' : 'action_favorite');
        final addLabel = context.tr('quick_add_to_cart');
        final card = FoodCard(
          item: item,
          onTap: () => Navigator.of(context).pushNamed(
            ItemDetailsPage.routeName,
            arguments: item,
          ),
          onAdd: () {
            _addToCart(item);
          },
          onToggleFavorite: () {
            favorites.toggleFavorite(item);
          },
          isFavorite: isFavorite,
          favoriteTooltip: favoriteLabel,
        );
        return QuickActionCard(
          id: item.id,
          child: card,
          onFavorite: () {
            favorites.toggleFavorite(item);
          },
          onAddToCart: () {
            _addToCart(item);
          },
          favoriteLabel: favoriteLabel,
          addLabel: addLabel,
          isFavorite: isFavorite,
        );
      },
    );
  }

  Future<void> _onRefresh() async {
    await _controller.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appController = AppScope.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final padding = ResponsiveBreakpoints.pagePadding(constraints.maxWidth);
        return ValueListenableBuilder<ContentDensity>(
          valueListenable: appController.contentDensity,
          builder: (context, density, _) {
            final verticalSpacing = ThemeTokens.listSpacingForDensity(density);
            final gridSpacing = ThemeTokens.gridSpacingForDensity(density);
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
                child: ValueListenableBuilder<ContentStatus>(
                  valueListenable: _controller.status,
                  builder: (context, state, _) {
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
                          if (state == ContentStatus.loading && _controller.items.value.isEmpty)
                            SliverPadding(
                              padding: padding.add(
                                EdgeInsets.symmetric(vertical: verticalSpacing),
                              ),
                              sliver: SliverLayoutBuilder(
                                builder: (context, constraints) {
                                  final crossAxisCount = ResponsiveBreakpoints.columnsForWidth(
                                    constraints.crossAxisExtent,
                                    min: 1,
                                    max: 5,
                                  );
                                  final aspectRatio = ResponsiveBreakpoints
                                      .foodCardAspectRatio(constraints.crossAxisExtent);
                                  return SliverGrid(
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: crossAxisCount,
                                      childAspectRatio: aspectRatio,
                                      crossAxisSpacing: gridSpacing,
                                      mainAxisSpacing: gridSpacing,
                                    ),
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) => FoodCardSkeleton(),
                                      childCount: crossAxisCount * 2,
                                    ),
                                  );
                                },
                              ),
                            )
                          else if (state == ContentStatus.offline || state == ContentStatus.error)
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: ContentStateView(
                                icon: state == ContentStatus.offline ? Icons.wifi_off : Icons.warning_rounded,
                                title: context.tr(
                                  state == ContentStatus.offline ? 'state_offline_title' : 'state_error_title',
                                ),
                                message: context.tr(
                                  state == ContentStatus.offline
                                      ? 'state_offline_message'
                                      : _controller.errorKey.value ?? 'state_error_message',
                                ),
                                primaryAction: FilledButton(
                                  onPressed: () => _controller.retry(),
                                  child: Text(context.tr('state_try_again')),
                                ),
                              ),
                            )
                          else
                            SliverPadding(
                              padding: padding.add(
                                EdgeInsets.symmetric(vertical: verticalSpacing),
                              ),
                              sliver: ValueListenableBuilder<List<FoodItem>>(
                                valueListenable: _controller.items,
                                builder: (context, items, _) {
                                  if (items.isEmpty) {
                                    return SliverFillRemaining(
                                      hasScrollBody: false,
                                      child: ContentStateView(
                                        icon: Icons.search_off,
                                        title: context.tr('catalog_empty'),
                                        message: context.tr('state_empty_menu_message'),
                                        primaryAction: TextButton(
                                          onPressed: () => _controller.refresh(),
                                          child: Text(context.tr('state_try_again')),
                                        ),
                                      ),
                                    );
                                  }
                                  return ValueListenableBuilder<bool>(
                                    valueListenable: _controller.isGridMode,
                                    builder: (context, isGrid, _) {
                                      if (isGrid) {
                                        return SliverLayoutBuilder(
                                          builder: (context, constraints) {
                                            final crossAxisCount = ResponsiveBreakpoints.columnsForWidth(
                                              constraints.crossAxisExtent,
                                              min: 1,
                                              max: 5,
                                            );
                                            final aspectRatio = ResponsiveBreakpoints
                                                .foodCardAspectRatio(constraints.crossAxisExtent);
                                            return SliverGrid(
                                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: crossAxisCount,
                                                childAspectRatio: aspectRatio,
                                                crossAxisSpacing: gridSpacing,
                                                mainAxisSpacing: gridSpacing,
                                              ),
                                              delegate: SliverChildBuilderDelegate(
                                                (context, index) {
                                                  final item = items[index];
                                                  return _buildCard(item);
                                                },
                                                childCount: items.length,
                                              ),
                                            );
                                          },
                                        );
                                      }
                                      return SliverList(
                                        delegate: SliverChildBuilderDelegate(
                                          (context, index) {
                                            final item = items[index];
                                            return Padding(
                                              padding: EdgeInsets.only(bottom: verticalSpacing),
                                              child: _buildCard(item),
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
          },
        );
      },
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
