import 'package:flutter/material.dart';

import '../../data/local/food_local_data_source.dart';
import '../../data/local/meal_plan_local_data_source.dart';
import '../../domain/models/food_item.dart';
import '../../domain/models/meal_plan.dart';

class MealDragData {
  MealDragData.available({required this.item})
      : sourceDay = null,
        sourceIndex = null;

  MealDragData.fromPlan({required this.item, required this.sourceDay, required this.sourceIndex});

  final FoodItem item;
  final MealDay? sourceDay;
  final int? sourceIndex;

  bool get isFromPlan => sourceDay != null && sourceIndex != null;
}

class MealPlannerController extends ChangeNotifier {
  MealPlannerController({
    required FoodLocalDataSource dataSource,
    required MealPlanLocalDataSource localDataSource,
  })  : _dataSource = dataSource,
        _localDataSource = localDataSource,
        days = ValueNotifier<Map<MealDay, List<MealPlanEntry>>>(
          <MealDay, List<MealPlanEntry>>{for (final day in MealDay.values) day: <MealPlanEntry>[]},
        ),
        availableItems = ValueNotifier<List<FoodItem>>(<FoodItem>[]);

  final FoodLocalDataSource _dataSource;
  final MealPlanLocalDataSource _localDataSource;

  final ValueNotifier<Map<MealDay, List<MealPlanEntry>>> days;
  final ValueNotifier<List<FoodItem>> availableItems;

  MealPlan _plan = MealPlan.empty();
  Map<String, FoodItem> _catalog = <String, FoodItem>{};
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    final items = await _dataSource.fetchAll();
    _catalog = <String, FoodItem>{for (final item in items) item.id: item};
    items.sort((a, b) => b.popularityScore.compareTo(a.popularityScore));
    availableItems.value = items.take(24).toList();
    final saved = await _localDataSource.read();
    if (saved != null) {
      _plan = saved;
    }
    _publish();
    _initialized = true;
  }

  bool get isInitialized => _initialized;

  bool get isEmpty {
    for (final day in MealDay.values) {
      if ((days.value[day] ?? const <MealPlanEntry>[]).isNotEmpty) {
        return false;
      }
    }
    return true;
  }

  Future<void> addItem(MealDay day, FoodItem item) async {
    await initialize();
    final entries = _plan.entriesFor(day)
      ..add(
        MealPlanEntry(itemId: item.id),
      );
    _plan.setEntries(day, entries);
    await _persistAndNotify();
  }

  Future<void> moveItem({required MealDay fromDay, required int fromIndex, required MealDay toDay}) async {
    await initialize();
    final source = _plan.entriesFor(fromDay);
    if (fromIndex < 0 || fromIndex >= source.length) {
      return;
    }
    final entry = source.removeAt(fromIndex);
    _plan.setEntries(fromDay, source);
    final destination = _plan.entriesFor(toDay)..add(entry);
    _plan.setEntries(toDay, destination);
    await _persistAndNotify();
  }

  Future<void> removeItem(MealDay day, int index) async {
    await initialize();
    final entries = _plan.entriesFor(day);
    if (index < 0 || index >= entries.length) {
      return;
    }
    entries.removeAt(index);
    _plan.setEntries(day, entries);
    await _persistAndNotify();
  }

  Future<void> clear() async {
    await initialize();
    _plan = MealPlan.empty();
    await _localDataSource.clear();
    _publish();
  }

  FoodItem? itemById(String id) => _catalog[id];

  int caloriesFor(MealDay day) {
    final entries = days.value[day] ?? const <MealPlanEntry>[];
    var total = 0;
    for (final entry in entries) {
      final item = _catalog[entry.itemId];
      if (item != null) {
        total += item.kcal * entry.servings;
      }
    }
    return total;
  }

  List<MealPlanEntry> entriesFor(MealDay day) {
    return days.value[day] ?? const <MealPlanEntry>[];
  }

  Future<void> _persistAndNotify() async {
    _publish();
    await _localDataSource.save(_plan.clone());
  }

  void _publish() {
    days.value = <MealDay, List<MealPlanEntry>>{
      for (final day in MealDay.values) day: _plan.entriesFor(day),
    };
    notifyListeners();
  }

  @override
  void dispose() {
    days.dispose();
    availableItems.dispose();
    super.dispose();
  }
}

class MealPlannerScope extends InheritedNotifier<MealPlannerController> {
  const MealPlannerScope({
    required MealPlannerController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static MealPlannerController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<MealPlannerScope>();
    assert(scope != null, 'MealPlannerScope not found in context');
    return scope!.notifier!;
  }

  static MealPlannerController? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MealPlannerScope>()?.notifier;
  }
}
