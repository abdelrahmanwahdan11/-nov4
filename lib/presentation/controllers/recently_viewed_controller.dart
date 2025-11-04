import 'package:flutter/material.dart';

import '../../data/local/food_local_data_source.dart';
import '../../data/local/recently_viewed_local_data_source.dart';
import '../../domain/models/food_item.dart';

class RecentlyViewedController extends ChangeNotifier {
  RecentlyViewedController({
    required FoodLocalDataSource dataSource,
    required RecentlyViewedLocalDataSource localDataSource,
    this.limit = 20,
  })  : _dataSource = dataSource,
        _localDataSource = localDataSource,
        items = ValueNotifier<List<FoodItem>>(<FoodItem>[]);

  final FoodLocalDataSource _dataSource;
  final RecentlyViewedLocalDataSource _localDataSource;
  final ValueNotifier<List<FoodItem>> items;
  final int limit;

  List<String> _ids = <String>[];
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    _ids = await _localDataSource.read();
    await _hydrateItems();
    _initialized = true;
  }

  Future<void> record(FoodItem item) async {
    final ids = List<String>.from(_ids);
    ids.remove(item.id);
    ids.insert(0, item.id);
    if (ids.length > limit) {
      ids.removeRange(limit, ids.length);
    }
    _ids = ids;
    await _localDataSource.save(ids);
    await _hydrateItems();
    notifyListeners();
  }

  Future<void> remove(String id) async {
    _ids.removeWhere((element) => element == id);
    await _localDataSource.save(_ids);
    await _hydrateItems();
    notifyListeners();
  }

  Future<void> clear() async {
    _ids = <String>[];
    await _localDataSource.save(_ids);
    items.value = <FoodItem>[];
    notifyListeners();
  }

  Future<void> _hydrateItems() async {
    if (_ids.isEmpty) {
      items.value = <FoodItem>[];
      return;
    }
    final allItems = await _dataSource.fetchAll();
    final lookup = {for (final item in allItems) item.id: item};
    final hydrated = <FoodItem>[];
    for (final id in _ids) {
      final match = lookup[id];
      if (match != null) {
        hydrated.add(match);
      }
    }
    items.value = hydrated;
  }

  @override
  void dispose() {
    items.dispose();
    super.dispose();
  }
}

class RecentlyViewedScope extends InheritedNotifier<RecentlyViewedController> {
  const RecentlyViewedScope({
    required RecentlyViewedController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static RecentlyViewedController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<RecentlyViewedScope>();
    assert(scope != null, 'RecentlyViewedScope not found in context');
    return scope!.notifier!;
  }

  static RecentlyViewedController? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<RecentlyViewedScope>()?.notifier;
  }
}
