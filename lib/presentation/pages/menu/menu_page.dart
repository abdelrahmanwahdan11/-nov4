import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/locale/localization_extension.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/local/food_local_data_source.dart';
import '../../../domain/models/food_item.dart';
import '../../../domain/models/meal_plan.dart';
import '../../../domain/models/in_app_message.dart';
import '../../controllers/app_controller.dart';
import '../../controllers/catalog_controller.dart';
import '../../controllers/content_status.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/favorites_controller.dart';
import '../../controllers/home_collections_controller.dart';
import '../../controllers/recently_viewed_controller.dart';
import '../../controllers/tutorial_controller.dart';
import '../../controllers/meal_planner_controller.dart';
import '../../controllers/in_app_messaging_controller.dart';
import '../../widgets/content_state_view.dart';
import '../../widgets/food_card.dart';
import '../../widgets/quick_action_card.dart';
import '../../widgets/in_app_banner_strip.dart';
import '../../widgets/contextual_nudge_overlay.dart';
import '../catalog/catalog_page.dart';
import '../item/item_details_page.dart';
import '../compare/compare_meal_tables_page.dart';
import '../meal_planner/meal_planner_page.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _CompareMealTablesHighlight extends StatelessWidget {
  const _CompareMealTablesHighlight({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withOpacity(0.16),
            colorScheme.primary.withOpacity(0.06),
          ],
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('compare_tables_cta_title'),
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            context.tr('compare_tables_cta_desc'),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(context.tr('compare_tables_cta_button')),
          ),
        ],
      ).animate().fadeIn(duration: const Duration(milliseconds: 360)),
    );
  }
}

class _MealPlannerHighlight extends StatelessWidget {
  const _MealPlannerHighlight({required this.onPressed, this.controller});

  final VoidCallback onPressed;
  final MealPlannerController? controller;

  @override
  Widget build(BuildContext context) {
    Widget buildCard(int plannedMeals) {
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;
      final subtitle = plannedMeals > 0
          ? context.tr('meal_planner_cta_summary', params: <String, dynamic>{'count': plannedMeals})
          : context.tr('meal_planner_cta_desc');
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [
              colorScheme.primary.withOpacity(0.18),
              colorScheme.primary.withOpacity(0.08),
            ],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('meal_planner_cta_title'),
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text(context.tr('meal_planner_cta_button')),
            ),
          ],
        ),
      ).animate().fadeIn(duration: const Duration(milliseconds: 360));
    }

    final controller = this.controller;
    if (controller == null) {
      return buildCard(0);
    }

    return ValueListenableBuilder<Map<MealDay, List<MealPlanEntry>>>(
      valueListenable: controller.days,
      builder: (context, plan, _) {
        final plannedMeals = plan.values.fold<int>(0, (acc, items) => acc + items.length);
        return buildCard(plannedMeals);
      },
    );
  }
}

class _MenuPageState extends State<MenuPage> {
  CatalogController? _controller;
  final ValueNotifier<String?> _selectedTag = ValueNotifier<String?>(null);
  CartController? _cartController;
  FavoritesController? _favoritesController;
  RecentlyViewedController? _recentlyViewedController;
  HomeCollectionsController? _collectionsController;
  MealPlannerController? _mealPlannerController;
  InAppMessagingController? _messagingController;
  StreamSubscription<SnackMessage>? _messagingSubscription;
  late final FoodLocalDataSource _foodDataSource = FoodLocalDataSource();

  CatalogController get _catalogController => _controller!;

  @override
  void dispose() {
    _selectedTag.dispose();
    _controller?.dispose();
    _collectionsController?.dispose();
    _messagingSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cartController = CartScope.of(context);
    _favoritesController = FavoritesScope.maybeOf(context);
    _recentlyViewedController = RecentlyViewedScope.maybeOf(context);
    final appController = AppScope.of(context);
    _controller ??= CatalogController(
      dataSource: _foodDataSource,
      connectionOverride: appController.connectionOverride,
      sortOption: appController.catalogSortOption,
      onSortOptionChanged: appController.setCatalogSortOption,
    )
      ..loadInitial();
    _collectionsController ??= HomeCollectionsController(
      dataSource: _foodDataSource,
      connectionOverride: appController.connectionOverride,
    );
    _mealPlannerController ??= MealPlannerScope.maybeOf(context);
    final messaging = InAppMessagingScope.maybeOf(context);
    if (!identical(_messagingController, messaging)) {
      _messagingSubscription?.cancel();
      _messagingController = messaging;
      if (messaging != null) {
        messaging.activateSurface(MessageSurface.menu);
        _messagingSubscription = messaging.snackMessages.listen((event) {
          if (!mounted) {
            return;
          }
          final messenger = ScaffoldMessenger.of(context);
          messenger.hideCurrentSnackBar();
          messenger.showSnackBar(
            SnackBar(content: Text(context.tr(event.key, params: event.params))),
          );
        });
      }
    }
  }

  void _openCatalog() {
    _handleActionCompletion(InAppActionIds.openCatalog);
    Navigator.of(context).pushNamed(CatalogPage.routeName);
  }

  void _openDetails(FoodItem item) {
    Navigator.of(context).pushNamed(ItemDetailsPage.routeName, arguments: item);
  }

  void _openMealPlanner() {
    _handleActionCompletion(InAppActionIds.openMealPlanner);
    Navigator.of(context).pushNamed(MealPlannerPage.routeName);
  }

  void _openCompareTables() {
    _handleActionCompletion(InAppActionIds.openCompareTables);
    Navigator.of(context).pushNamed(CompareMealTablesPage.routeName);
  }

  Future<void> _addToCart(FoodItem item) async {
    final controller = _cartController;
    if (controller != null) {
      await controller.addItem(item);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${context.tr('added_to_cart')} ${item.name}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleActionCompletion(String actionId) {
    final messaging = _messagingController;
    if (messaging != null) {
      messaging.markActionCompleted(actionId);
    }
  }

  void _performMessageAction(String? route, String? actionId) {
    if (actionId == InAppActionIds.openCatalog) {
      _openCatalog();
      return;
    }
    if (actionId == InAppActionIds.openMealPlanner) {
      _openMealPlanner();
      return;
    }
    if (actionId == InAppActionIds.openCompareTables) {
      _openCompareTables();
      return;
    }
    if (route != null) {
      Navigator.of(context).pushNamed(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chipsPadding = EdgeInsetsDirectional.only(
      start: Directionality.of(context) == TextDirection.rtl ? 0 : 16,
      end: Directionality.of(context) == TextDirection.rtl ? 16 : 0,
    );

    final controller = _controller;
    if (controller == null) {
      return const SizedBox.shrink();
    }
    final catalog = controller;

    return LayoutBuilder(
      builder: (context, constraints) {
        final padding = ResponsiveBreakpoints.pagePadding(constraints.maxWidth);

        final slivers = <Widget>[
          SliverAppBar(
            pinned: true,
            centerTitle: false,
            title: Text(context.tr('menu_title')),
            actions: [
              IconButton(
                onPressed: _openCatalog,
                icon: const Icon(Icons.grid_view_rounded),
                tooltip: context.tr('see_catalog'),
              ),
            ],
          ),
          if (_messagingController != null)
            SliverToBoxAdapter(
              child: InAppBannerStrip(
                controller: _messagingController!,
                surface: MessageSurface.menu,
                padding: padding.add(const EdgeInsets.only(top: 12, bottom: 4)),
                onAction: (banner, route) => _performMessageAction(route, banner.actionId),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: ValueListenableBuilder<List<String>>(
                valueListenable: catalog.availableTags,
                builder: (context, tags, _) {
                  if (tags.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return ValueListenableBuilder<String?>(
                    valueListenable: _selectedTag,
                    builder: (context, selected, __) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: chipsPadding,
                        child: Row(
                          children: [
                            const SizedBox(width: 16),
                            FilterChip(
                              label: Text(context.tr('chip_all')),
                              selected: selected == null,
                              onSelected: (_) => _selectedTag.value = null,
                            ),
                            const SizedBox(width: 12),
                            ...tags.map(
                              (tag) => Padding(
                                padding: const EdgeInsetsDirectional.only(end: 12),
                                child: FilterChip(
                                  label: Text(tag),
                                  selected: selected == tag,
                                  onSelected: (_) => _selectedTag.value = tag,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: padding.add(const EdgeInsets.symmetric(vertical: 8)),
              child: _MealPlannerHighlight(
                controller: _mealPlannerController,
                onPressed: _openMealPlanner,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: padding.add(const EdgeInsets.symmetric(vertical: 8)),
              child: _CompareMealTablesHighlight(onPressed: _openCompareTables),
            ),
          ),
          if (_collectionsController != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: padding.add(const EdgeInsets.only(top: 8, bottom: 4)),
                child: _CollectionsCarouselSection(
                  title: context.tr('section_deals'),
                  subtitle: context.tr('section_deals_subtitle'),
                  emptyMessage: context.tr('section_deals_empty'),
                  stateListenable: _collectionsController!.deals,
                  onRequestLoad: _collectionsController!.loadDeals,
                  cardBuilder: (item) => _buildCardWithActions(context, item),
                ),
              ),
            ),
          if (_collectionsController != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: padding.add(const EdgeInsets.symmetric(vertical: 4)),
                child: _CollectionsCarouselSection(
                  title: context.tr('section_healthiest'),
                  subtitle: context.tr('section_healthiest_subtitle'),
                  emptyMessage: context.tr('section_healthiest_empty'),
                  stateListenable: _collectionsController!.healthiest,
                  onRequestLoad: _collectionsController!.loadHealthiest,
                  cardBuilder: (item) => _buildCardWithActions(context, item),
                ),
              ),
            ),
          if (_collectionsController != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: padding.add(const EdgeInsets.symmetric(vertical: 4)),
                child: _CollectionsCarouselSection(
                  title: context.tr('section_plant_based'),
                  subtitle: context.tr('section_plant_based_subtitle'),
                  emptyMessage: context.tr('section_plant_based_empty'),
                  stateListenable: _collectionsController!.plantBased,
                  onRequestLoad: _collectionsController!.loadPlantBased,
                  cardBuilder: (item) => _buildCardWithActions(context, item),
                ),
              ),
            ),
          if (_favoritesController != null)
            SliverToBoxAdapter(
              child: ValueListenableBuilder<List<FoodItem>>(
                valueListenable: _favoritesController!.favoriteItems,
                builder: (context, favorites, _) {
                  if (favorites.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: padding.add(const EdgeInsets.only(top: 8, bottom: 4)),
                    child: _HorizontalSection(
                      title: context.tr('section_favorites'),
                      items: favorites,
                      onOpen: _openDetails,
                      onAdd: _addToCart,
                      onToggleFavorite: (item) {
                        _favoritesController!.toggleFavorite(item);
                      },
                      favoritesController: _favoritesController!,
                    ),
                  );
                },
              ),
            ),
          if (_recentlyViewedController != null)
            SliverToBoxAdapter(
              child: ValueListenableBuilder<List<FoodItem>>(
                valueListenable: _recentlyViewedController!.items,
                builder: (context, recent, _) {
                  if (recent.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: padding.add(const EdgeInsets.only(top: 4, bottom: 4)),
                    child: _HorizontalSection(
                      title: context.tr('section_recently_viewed'),
                      items: recent,
                      onOpen: _openDetails,
                      onAdd: _addToCart,
                      onToggleFavorite: (item) {
                        _favoritesController?.toggleFavorite(item);
                      },
                      favoritesController: _favoritesController,
                    ),
                  );
                },
              ),
            ),
          ValueListenableBuilder<ContentStatus>(
            valueListenable: catalog.status,
            builder: (context, state, _) {
              if (state == ContentStatus.loading && catalog.items.value.isEmpty) {
                return SliverPadding(
                  padding: padding.add(const EdgeInsets.symmetric(vertical: 16)),
                  sliver: SliverLayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = ResponsiveBreakpoints.columnsForWidth(
                        constraints.crossAxisExtent,
                        min: 1,
                        max: 4,
                      );
                      final aspectRatio =
                          ResponsiveBreakpoints.foodCardAspectRatio(constraints.crossAxisExtent);
                      return SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: aspectRatio,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => FoodCardSkeleton(),
                          childCount: crossAxisCount * 2,
                        ),
                      );
                    },
                  ),
                );
              }
              if (state == ContentStatus.offline || state == ContentStatus.error) {
                final messageKey = state == ContentStatus.offline
                    ? 'state_offline_message'
                    : catalog.errorKey.value ?? 'state_error_message';
                final titleKey = state == ContentStatus.offline
                    ? 'state_offline_title'
                    : 'state_error_title';
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: ContentStateView(
                    icon: state == ContentStatus.offline ? Icons.wifi_off : Icons.warning_rounded,
                    title: context.tr(titleKey),
                    message: context.tr(messageKey),
                    primaryAction: FilledButton(
                      onPressed: () => catalog.retry(),
                      child: Text(context.tr('state_try_again')),
                    ),
                  ),
                );
              }
              return ValueListenableBuilder<List<FoodItem>>(
                valueListenable: catalog.items,
                builder: (context, items, _) {
                  return ValueListenableBuilder<String?>(
                    valueListenable: _selectedTag,
                    builder: (context, selected, __) {
                      final filtered = selected == null
                          ? items
                          : items.where((item) => item.tags.contains(selected)).toList();
                      if (filtered.isEmpty) {
                        return SliverFillRemaining(
                          hasScrollBody: false,
                          child: ContentStateView(
                            icon: Icons.sentiment_dissatisfied_outlined,
                            title: context.tr('menu_empty'),
                            message: context.tr('state_empty_menu_message'),
                            primaryAction: TextButton(
                              onPressed: () => _selectedTag.value = null,
                              child: Text(context.tr('state_reset_filters')),
                            ),
                          ),
                        );
                      }
                      return SliverPadding(
                        padding: padding.add(const EdgeInsets.symmetric(vertical: 16)),
                        sliver: SliverLayoutBuilder(
                          builder: (context, constraints) {
                            final crossAxisCount = ResponsiveBreakpoints.columnsForWidth(
                              constraints.crossAxisExtent,
                              min: 1,
                              max: 4,
                            );
                            final aspectRatio =
                                ResponsiveBreakpoints.foodCardAspectRatio(constraints.crossAxisExtent);
                            return SliverGrid(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                childAspectRatio: aspectRatio,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final item = filtered[index];
                                  final tutorialTarget = index == 0 ? TutorialTarget.addToCart : null;
                                  return _buildCardWithActions(
                                    context,
                                    item,
                                    tutorialTarget: tutorialTarget,
                                  );
                                },
                                childCount: filtered.length,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
          SliverPadding(
            padding: padding.add(const EdgeInsets.symmetric(vertical: 16)),
            sliver: ValueListenableBuilder<bool>(
              valueListenable: catalog.hasMore,
              builder: (context, hasMore, _) {
                if (!hasMore) {
                  return SliverToBoxAdapter(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        context.tr('catalog_end'),
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  );
                }
                return SliverToBoxAdapter(
                  child: ValueListenableBuilder<bool>(
                    valueListenable: catalog.isPaginating,
                    builder: (context, paginating, __) {
                      if (paginating) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: const Center(child: CircularProgressIndicator()),
                        );
                      }
                      return Center(
                        child: ElevatedButton.icon(
                          onPressed: catalog.loadMore,
                          icon: const Icon(Icons.more_horiz),
                          label: Text(context.tr('load_more')),
                        )
                            .animate()
                            .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ];

        return Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await catalog.refresh();
                  },
                  child: CustomScrollView(
                    physics:
                        const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                    slivers: slivers,
                  ),
                ),
              ),
              if (_messagingController != null)
                Positioned.fill(
                  child: ContextualNudgeOverlay(
                    controller: _messagingController!,
                    surface: MessageSurface.menu,
                    isEnabled: true,
                    additionalBottomPadding: kBottomNavigationBarHeight + 12,
                    onAction: (nudge, route) =>
                        _performMessageAction(route, nudge.actionId),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCardWithActions(
    BuildContext context,
    FoodItem item, {
    TutorialTarget? tutorialTarget,
  }) {
    final favorites = _favoritesController;
    if (favorites == null) {
      return FoodCard(
        item: item,
        onTap: () => _openDetails(item),
        onAdd: () {
          _addToCart(item);
        },
        tutorialTarget: tutorialTarget,
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
          onTap: () => _openDetails(item),
          onAdd: () => _addToCart(item),
          tutorialTarget: tutorialTarget,
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
}

class _HorizontalSection extends StatelessWidget {
  const _HorizontalSection({
    required this.title,
    required this.items,
    required this.onOpen,
    required this.onAdd,
    required this.onToggleFavorite,
    required this.favoritesController,
  });

  final String title;
  final List<FoodItem> items;
  final void Function(FoodItem) onOpen;
  final Future<void> Function(FoodItem) onAdd;
  final void Function(FoodItem)? onToggleFavorite;
  final FavoritesController? favoritesController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        SizedBox(
          height: 280,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final item = items[index];
              final isFavorite = favoritesController?.isFavorite(item.id) ?? false;
              return SizedBox(
                width: 200,
                  child: FoodCard(
                    item: item,
                    onTap: () => onOpen(item),
                  onAdd: () {
                    onAdd(item);
                  },
                  sizeVariant: FoodCardSizeVariant.compact,
                  onToggleFavorite: onToggleFavorite != null
                      ? () {
                          onToggleFavorite!(item);
                        }
                      : null,
                  isFavorite: isFavorite,
                  favoriteTooltip: context.tr(
                    isFavorite ? 'action_unfavorite' : 'action_favorite',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CollectionsCarouselSection extends StatefulWidget {
  const _CollectionsCarouselSection({
    required this.title,
    required this.subtitle,
    required this.emptyMessage,
    required this.stateListenable,
    required this.onRequestLoad,
    required this.cardBuilder,
  });

  final String title;
  final String subtitle;
  final String emptyMessage;
  final ValueListenable<HomeCollectionState> stateListenable;
  final VoidCallback onRequestLoad;
  final Widget Function(FoodItem) cardBuilder;

  @override
  State<_CollectionsCarouselSection> createState() => _CollectionsCarouselSectionState();
}

class _CollectionsCarouselSectionState extends State<_CollectionsCarouselSection> {
  late final PageController _pageController;
  final ValueNotifier<int> _currentPage = ValueNotifier<int>(0);
  int _lastItemCount = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.86);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _currentPage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ValueListenableBuilder<HomeCollectionState>(
      valueListenable: widget.stateListenable,
      builder: (context, state, _) {
        if (state.status == ContentStatus.idle) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) {
              return;
            }
            widget.onRequestLoad();
          });
        }

        Widget body;
        Key bodyKey = ValueKey<String>('state_${state.status.name}');
        switch (state.status) {
          case ContentStatus.loading:
          case ContentStatus.idle:
            body = const _CollectionsCarouselSkeleton();
            bodyKey = const ValueKey<String>('state_loading');
            break;
          case ContentStatus.success:
            final items = state.items;
            final itemCount = items.length;
            if (_lastItemCount != itemCount) {
              _lastItemCount = itemCount;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) {
                  return;
                }
                _currentPage.value = 0;
                if (_pageController.hasClients) {
                  _pageController.jumpToPage(0);
                }
              });
            } else if (_currentPage.value >= itemCount) {
              _currentPage.value = itemCount - 1;
            }
            bodyKey = ValueKey<String>('state_success_$itemCount');
            body = Column(
              children: [
                SizedBox(
                  height: 300,
                  child: PageView.builder(
                    controller: _pageController,
                    physics: itemCount <= 1
                        ? const NeverScrollableScrollPhysics()
                        : const BouncingScrollPhysics(),
                    itemCount: itemCount,
                    onPageChanged: (index) => _currentPage.value = index,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: widget.cardBuilder(items[index]),
                      );
                    },
                  ),
                ),
                if (itemCount > 1)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: ValueListenableBuilder<int>(
                      valueListenable: _currentPage,
                      builder: (context, current, __) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List<Widget>.generate(itemCount, (index) {
                            final isActive = index == current;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 240),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              height: 6,
                              width: isActive ? 18 : 6,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary
                                    .withOpacity(isActive ? 1 : 0.25),
                                borderRadius: BorderRadius.circular(999),
                              ),
                            );
                          }),
                        );
                      },
                    ),
                  ),
              ],
            );
            break;
          case ContentStatus.empty:
            bodyKey = const ValueKey<String>('state_empty');
            body = ContentStateView(
              icon: Icons.inbox_outlined,
              title: widget.title,
              message: widget.emptyMessage,
              primaryAction: TextButton(
                onPressed: widget.onRequestLoad,
                child: Text(context.tr('state_refresh_section')),
              ),
            );
            break;
          case ContentStatus.error:
            bodyKey = const ValueKey<String>('state_error');
            body = ContentStateView(
              icon: Icons.warning_rounded,
              title: context.tr('state_error_title'),
              message: context.tr(state.errorKey ?? 'state_error_message'),
              primaryAction: FilledButton(
                onPressed: widget.onRequestLoad,
                child: Text(context.tr('state_try_again')),
              ),
            );
            break;
          case ContentStatus.offline:
            bodyKey = const ValueKey<String>('state_offline');
            body = ContentStateView(
              icon: Icons.wifi_off,
              title: context.tr('state_offline_title'),
              message: context.tr('state_offline_message'),
              primaryAction: FilledButton(
                onPressed: widget.onRequestLoad,
                child: Text(context.tr('state_try_again')),
              ),
            );
            break;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.subtitle,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 360),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: KeyedSubtree(key: bodyKey, child: body),
            ),
          ],
        );
      },
    );
  }
}

class _CollectionsCarouselSkeleton extends StatefulWidget {
  const _CollectionsCarouselSkeleton();

  @override
  State<_CollectionsCarouselSkeleton> createState() => _CollectionsCarouselSkeletonState();
}

class _CollectionsCarouselSkeletonState extends State<_CollectionsCarouselSkeleton> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.86);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: PageView.builder(
        controller: _controller,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        itemBuilder: (context, index) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: FoodCardSkeleton(),
          );
        },
      ),
    );
  }
}
