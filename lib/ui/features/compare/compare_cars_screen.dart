import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';

import '../../../data/models/car_item.dart';
import '../../../data/repositories_local/car_repository_local.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/refresh_wrapper.dart';
import '../../widgets/skeleton_grid.dart';
import '../../widgets/scroll_paginator.dart';
import '../../../core/routing/app_router.dart';

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
    final page = await _repository.fetchPage(
      page: _page,
      pageSize: 10,
      filters: null,
      query: _query.isEmpty ? null : _query,
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
      pageSize: 10,
      filters: null,
      query: _query.isEmpty ? null : _query,
      sort: null,
    );
    _items.addAll(page.items);
    _hasMore = page.hasMore;
    setState(() => _isLoadingMore = false);
  }

  void _toggle(CarItem item) {
    setState(() {
      if (_selected.contains(item)) {
        _selected.remove(item);
      } else if (_selected.length < 4) {
        _selected.add(item);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentIndex: 0,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Compare cars', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      _query = value;
                      _items.clear();
                      _page = 0;
                      _load();
                    },
                    decoration: InputDecoration(
                      hintText: 'Search cars',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.tune),
                        onPressed: () {},
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 160,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                scrollDirection: Axis.horizontal,
                itemCount: _selected.length,
                itemBuilder: (context, index) {
                  final car = _selected[index];
                  return FlipCard(
                    front: _CarCard(car: car, onCompare: () => Navigator.of(context).pushNamed(AppRoutes.carViewer, arguments: car.id)),
                    back: _CarDetailsBack(car: car),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(width: 12),
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
                        child: GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 1.1,
                          ),
                          itemCount: _items.length,
                          itemBuilder: (context, index) {
                            final car = _items[index];
                            final selected = _selected.contains(car);
                            return GestureDetector(
                              onTap: () => _toggle(car),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: selected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(backgroundImage: NetworkImage(car.imageUrl), radius: 40),
                                    const SizedBox(height: 8),
                                    Text(car.nameEn, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
                                    Text('${car.powerHp} hp'),
                                  ],
                                ),
                              ),
                            );
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

class _CarCard extends StatelessWidget {
  const _CarCard({required this.car, required this.onCompare});

  final CarItem car;
  final VoidCallback onCompare;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(car.nameEn, style: Theme.of(context).textTheme.titleMedium),
            Text('${car.price} USD'),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: IconButton(onPressed: onCompare, icon: const Icon(Icons.view_in_ar)),
            ),
          ],
        ),
      ),
    );
  }
}

class _CarDetailsBack extends StatelessWidget {
  const _CarDetailsBack({required this.car});

  final CarItem car;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Torque: ${car.torqueNm} Nm'),
            Text('0-100: ${car.zeroTo100}s'),
            Text('Range: ${car.rangeKmOrConsumption} km'),
            const Spacer(),
            const Icon(Icons.sync),
          ],
        ),
      ),
    );
  }
}
