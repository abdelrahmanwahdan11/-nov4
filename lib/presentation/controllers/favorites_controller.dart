import 'package:flutter/material.dart';

import '../../data/local/favorites_local_data_source.dart';
import '../../data/local/food_local_data_source.dart';
import '../../domain/models/food_item.dart';

class FavoritesController extends ChangeNotifier {
  FavoritesController({
    required FoodLocalDataSource dataSource,
    required FavoritesLocalDataSource localDataSource,
  })  : _dataSource = dataSource,
        _localDataSource = localDataSource,
        favoriteIds = ValueNotifier<List<String>>(<String>[]),
        favoriteItems = ValueNotifier<List<FoodItem>>(<FoodItem>[]);

  final FoodLocalDataSource _dataSource;
  final FavoritesLocalDataSource _localDataSource;

  final ValueNotifier<List<String>> favoriteIds;
  final ValueNotifier<List<FoodItem>> favoriteItems;

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    final ids = await _localDataSource.read();
    favoriteIds.value = List<String>.from(ids);
    await _hydrateItems();
    _initialized = true;
  }

  bool isFavorite(String id) {
    return favoriteIds.value.contains(id);
  }

  Future<void> toggleFavorite(FoodItem item) async {
    final ids = List<String>.from(favoriteIds.value);
    final existingIndex = ids.indexOf(item.id);
    if (existingIndex >= 0) {
      ids.removeAt(existingIndex);
    } else {
      ids.insert(0, item.id);
    }
    favoriteIds.value = ids;
    await _localDataSource.save(ids);
    await _hydrateItems();
    notifyListeners();
  }

  Future<void> removeFavorite(String id) async {
    final ids = List<String>.from(favoriteIds.value)..removeWhere((item) => item == id);
    favoriteIds.value = ids;
    await _localDataSource.save(ids);
    await _hydrateItems();
    notifyListeners();
  }

  Future<void> _hydrateItems() async {
    final allItems = await _dataSource.fetchAll();
    final lookup = {for (final item in allItems) item.id: item};
    final items = <FoodItem>[];
    for (final id in favoriteIds.value) {
      final match = lookup[id];
      if (match != null) {
        items.add(match);
      }
    }
    favoriteItems.value = items;
  }

  @override
  void dispose() {
    favoriteIds.dispose();
    favoriteItems.dispose();
    super.dispose();
  }
}

class FavoritesScope extends InheritedNotifier<FavoritesController> {
  const FavoritesScope({
    required FavoritesController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static FavoritesController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<FavoritesScope>();
    assert(scope != null, 'FavoritesScope not found in context');
    return scope!.notifier!;
  }

  static FavoritesController? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<FavoritesScope>()?.notifier;
  }
}
