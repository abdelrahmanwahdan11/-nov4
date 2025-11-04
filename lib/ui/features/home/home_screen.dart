import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/routing/app_router.dart';
import '../../../data/models/food_item.dart';
import '../../../data/repositories_local/food_repository_local.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/refresh_wrapper.dart';
import '../../widgets/scroll_paginator.dart';
import '../../widgets/skeleton_base.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FoodRepositoryLocal _repository = FoodRepositoryLocal();
  final List<FoodItem> _items = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _page = 0;
  int _tabIndex = 0;

  final List<String> _tabs = const [
    'Salads & Bowls',
    'Pasta & Gnocchi',
    'Soups',
    'Desserts',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool refresh = false}) async {
    if (refresh) {
      await _repository.refresh();
      _items.clear();
      _page = 0;
      _hasMore = true;
    }
    setState(() => _isLoading = _items.isEmpty);
    final page = await _repository.fetchPage(
      page: _page,
      pageSize: 20,
      filters: {'tab': _tabs[_tabIndex]},
      query: null,
      sort: null,
    );
    _items.addAll(page.items);
    _hasMore = page.hasMore;
    setState(() => _isLoading = false);
  }

  Future<void> _loadMore() async {
    if (!_hasMore || _isLoadingMore) return;
    setState(() => _isLoadingMore = true);
    _page++;
    final page = await _repository.fetchPage(
      page: _page,
      pageSize: 20,
      filters: {'tab': _tabs[_tabIndex]},
      query: null,
      sort: null,
    );
    _items.addAll(page.items);
    _hasMore = page.hasMore;
    setState(() => _isLoadingMore = false);
  }

  void _changeTab(int index) {
    setState(() {
      _tabIndex = index;
      _page = 0;
      _items.clear();
    });
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return AppScaffold(
      initialIndex: 0,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(loc.translate('homeTitle'), style: Theme.of(context).textTheme.headlineMedium),
            ),
            SizedBox(
              height: 48,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                scrollDirection: Axis.horizontal,
                itemCount: _tabs.length,
                itemBuilder: (context, index) {
                  final selected = index == _tabIndex;
                  return GestureDetector(
                    onTap: () => _changeTab(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: selected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Theme.of(context).colorScheme.primary),
                      ),
                      child: Center(
                        child: Text(
                          _tabs[index],
                          style: TextStyle(
                            color: selected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(width: 12),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: _HomeSkeleton(),
                    )
                  : RefreshWrapper(
                      onRefresh: () => _load(refresh: true),
                      child: ScrollPaginator(
                        onFetchMore: _loadMore,
                        hasMore: _hasMore,
                        isLoadingMore: _isLoadingMore,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          itemCount: _items.length + 1,
                          itemBuilder: (context, index) {
                            if (index == _items.length) {
                              if (_isLoadingMore) {
                                return const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(child: CircularProgressIndicator()),
                                );
                              }
                              if (!_hasMore) {
                                return const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(child: Text('No more items')),
                                );
                              }
                              return const SizedBox.shrink();
                            }
                            final item = _items[index];
                            return _FoodCard(item: item);
                          },
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

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(4, (_) => const Padding(padding: EdgeInsets.only(bottom: 12), child: SkeletonBase(height: 96))),
    );
  }
}

class _FoodCard extends StatelessWidget {
  const _FoodCard({required this.item});

  final FoodItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Hero(
              tag: item.id,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.network(
                  item.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const SizedBox(width: 80, height: 80, child: SkeletonBase());
                  },
                  errorBuilder: (_, __, ___) => const SizedBox(
                    width: 80,
                    height: 80,
                    child: Icon(Icons.image_not_supported),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 6,
                    children: [
                      if (item.isNew)
                        Chip(
                          label: const Text('New'),
                          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                        ),
                      if (item.isVegan)
                        Chip(
                          label: const Text('Vegan'),
                          backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(item.titleEn, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text('${item.grams} g • ${item.kcal} kcal'),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(item.price.toStringAsFixed(2), style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pushNamed(AppRoutes.itemDetails, arguments: item.id),
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
