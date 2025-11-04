import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../data/models/food_item.dart';
import '../../../data/repositories_local/food_repository_local.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/refresh_wrapper.dart';
import '../../widgets/scroll_paginator.dart';
import '../../widgets/skeleton_grid.dart';
import '../../widgets/skeleton_base.dart';

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
  String _query = '';

  final TextEditingController _searchController = TextEditingController();

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
      _items.clear();
      _page = 0;
      _hasMore = true;
    }
    setState(() => _isLoading = _items.isEmpty);
    final filters = {
      if (_veganOnly) 'vegan': true,
      if (_newOnly) 'isNew': true,
    };
    final page = await _repository.fetchPage(
      page: _page,
      pageSize: 20,
      filters: filters,
      query: _query.isEmpty ? null : _query,
      sort: _sort,
    );
    _items.addAll(page.items);
    _hasMore = page.hasMore;
    setState(() => _isLoading = false);
  }

  Future<void> _loadMore() async {
    if (!_hasMore || _isLoadingMore) return;
    setState(() => _isLoadingMore = true);
    _page++;
    final filters = {
      if (_veganOnly) 'vegan': true,
      if (_newOnly) 'isNew': true,
    };
    final page = await _repository.fetchPage(
      page: _page,
      pageSize: 20,
      filters: filters,
      query: _query.isEmpty ? null : _query,
      sort: _sort,
    );
    _items.addAll(page.items);
    _hasMore = page.hasMore;
    setState(() => _isLoadingMore = false);
  }

  void _applySearch(String text) {
    _query = text;
    _items.clear();
    _page = 0;
    _load();
  }

  void _toggleFilter(bool vegan) {
    setState(() {
      if (vegan) {
        _veganOnly = !_veganOnly;
      } else {
        _newOnly = !_newOnly;
      }
      _items.clear();
      _page = 0;
    });
    _load();
  }

  void _chooseSort(String? value) {
    setState(() {
      _sort = value;
      _items.clear();
      _page = 0;
    });
    _load();
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
                          _searchController.clear();
                          _applySearch('');
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
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
                      DropdownButton<String?>(
                        value: _sort,
                        hint: const Text('Sort'),
                        items: const [
                          DropdownMenuItem(value: 'price_asc', child: Text('Price ascending')),
                          DropdownMenuItem(value: 'price_desc', child: Text('Price descending')),
                          DropdownMenuItem(value: 'kcal_asc', child: Text('Calories ascending')),
                          DropdownMenuItem(value: 'kcal_desc', child: Text('Calories descending')),
                        ],
                        onChanged: _chooseSort,
                      ),
                      IconButton(
                        icon: Icon(_gridMode ? Icons.view_list : Icons.grid_view),
                        onPressed: () => setState(() => _gridMode = !_gridMode),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
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
                        child: _gridMode ? _buildGrid() : _buildList(),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      itemCount: _items.length + 1,
      itemBuilder: (context, index) {
        if (index == _items.length) {
          if (_isLoadingMore) {
            return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()));
          }
          if (!_hasMore) {
            return const Padding(padding: EdgeInsets.all(16), child: Center(child: Text('No more items')));
          }
          return const SizedBox.shrink();
        }
        final item = _items[index];
        return ListTile(
          leading: CircleAvatar(backgroundImage: NetworkImage(item.imageUrl)),
          title: Text(item.titleEn),
          subtitle: Text('${item.grams} g'),
          trailing: Text(item.price.toStringAsFixed(2)),
        );
      },
    );
  }

  Widget _buildGrid() {
    final crossAxisCount = MediaQuery.of(context).size.width > 900
        ? 4
        : MediaQuery.of(context).size.width > 600
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
      itemCount: _items.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _items.length) {
          return const Center(child: CircularProgressIndicator());
        }
        final item = _items[index];
        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    item.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const SkeletonBase();
                    },
                    errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.titleEn, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text('${item.price.toStringAsFixed(2)}'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
