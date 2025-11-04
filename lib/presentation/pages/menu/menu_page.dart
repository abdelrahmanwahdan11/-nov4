import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/locale/localization_extension.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/local/food_local_data_source.dart';
import '../../../domain/models/food_item.dart';
import '../../controllers/app_controller.dart';
import '../../controllers/catalog_controller.dart';
import '../../controllers/content_status.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/tutorial_controller.dart';
import '../../widgets/content_state_view.dart';
import '../../widgets/food_card.dart';
import '../catalog/catalog_page.dart';
import '../item/item_details_page.dart';
import '../compare/compare_cars_page.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _CompareCarsHighlight extends StatelessWidget {
  const _CompareCarsHighlight({required this.onPressed});

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
            context.tr('compare_cta_title'),
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            context.tr('compare_cta_desc'),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(context.tr('compare_cta_button')),
          ),
        ],
      ).animate().fadeIn(duration: const Duration(milliseconds: 360)),
    );
  }
}

class _MenuPageState extends State<MenuPage> {
  CatalogController? _controller;
  final ValueNotifier<String?> _selectedTag = ValueNotifier<String?>(null);
  CartController? _cartController;

  CatalogController get _catalogController => _controller!;

  @override
  void dispose() {
    _selectedTag.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cartController = CartScope.of(context);
    _controller ??= CatalogController(
      dataSource: FoodLocalDataSource(),
      connectionOverride: AppScope.of(context).connectionOverride,
    )
      ..loadInitial();
  }

  void _openCatalog() {
    Navigator.of(context).pushNamed(CatalogPage.routeName);
  }

  void _openDetails(FoodItem item) {
    Navigator.of(context).pushNamed(ItemDetailsPage.routeName, arguments: item);
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
        return Scaffold(
          body: RefreshIndicator(
            onRefresh: () async {
              await catalog.refresh();
            },
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              slivers: [
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
                child: _CompareCarsHighlight(onPressed: () {
                  Navigator.of(context).pushNamed(CompareCarsPage.routeName);
                }),
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
                            (context, index) => const FoodCardSkeleton(),
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
                              final aspectRatio = ResponsiveBreakpoints
                                  .foodCardAspectRatio(constraints.crossAxisExtent);
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
                                    return FoodCard(
                                      item: item,
                                      onTap: () => _openDetails(item),
                                      onAdd: () => _addToCart(item),
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
          ],
        ),
      );
      },
    );
  }
}
