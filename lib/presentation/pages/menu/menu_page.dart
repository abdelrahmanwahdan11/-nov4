import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/locale/localization_extension.dart';
import '../../../data/local/food_local_data_source.dart';
import '../../../domain/models/food_item.dart';
import '../../controllers/catalog_controller.dart';
import '../../widgets/food_card.dart';
import '../catalog/catalog_page.dart';
import '../item/item_details_page.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  late final CatalogController _controller;
  final ValueNotifier<String?> _selectedTag = ValueNotifier<String?>(null);

  @override
  void initState() {
    super.initState();
    _controller = CatalogController(dataSource: FoodLocalDataSource());
    _controller.loadInitial();
  }

  @override
  void dispose() {
    _selectedTag.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _openCatalog() {
    Navigator.of(context).pushNamed(CatalogPage.routeName);
  }

  void _openDetails(FoodItem item) {
    Navigator.of(context).pushNamed(ItemDetailsPage.routeName, arguments: item);
  }

  void _addToCart(FoodItem item) {
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

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await _controller.refresh();
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
                  valueListenable: _controller.availableTags,
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
            ValueListenableBuilder<bool>(
              valueListenable: _controller.isLoading,
              builder: (context, isLoading, _) {
                if (isLoading) {
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.72,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => const FoodCardSkeleton(),
                        childCount: 6,
                      ),
                    ),
                  );
                }
                return ValueListenableBuilder<List<FoodItem>>(
                  valueListenable: _controller.items,
                  builder: (context, items, _) {
                    if (items.isEmpty) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Text(
                            context.tr('menu_empty'),
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                      );
                    }
                    return ValueListenableBuilder<String?>(
                      valueListenable: _selectedTag,
                      builder: (context, selected, __) {
                        final filtered = selected == null
                            ? items
                            : items.where((item) => item.tags.contains(selected)).toList();
                        return SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          sliver: SliverGrid(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.72,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final item = filtered[index];
                                return FoodCard(
                                  item: item,
                                  onTap: () => _openDetails(item),
                                  onAdd: () => _addToCart(item),
                                  sizeVariant: FoodCardSizeVariant.compact,
                                );
                              },
                              childCount: filtered.length,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              sliver: ValueListenableBuilder<bool>(
                valueListenable: _controller.hasMore,
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
                      valueListenable: _controller.isPaginating,
                      builder: (context, paginating, __) {
                        if (paginating) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: const Center(child: CircularProgressIndicator()),
                          );
                        }
                        return Center(
                          child: ElevatedButton.icon(
                            onPressed: _controller.loadMore,
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
      ),
    );
  }
}
