import 'package:flutter/material.dart';

import '../../data/local/meal_table_local_data_source.dart';
import '../../domain/models/meal_table.dart';

class MealTableCompareController extends ChangeNotifier {
  MealTableCompareController({required MealTableLocalDataSource dataSource})
      : _dataSource = dataSource,
        tables = ValueNotifier<List<MealTable>>(<MealTable>[]),
        filteredTables = ValueNotifier<List<MealTable>>(<MealTable>[]),
        selectedTables = ValueNotifier<List<MealTable>>(<MealTable>[]),
        availableMealTypes = ValueNotifier<List<String>>(<String>[]),
        availableRegions = ValueNotifier<List<String>>(<String>[]),
        activeMealTypes = ValueNotifier<Set<String>>(<String>{}),
        activeRegions = ValueNotifier<Set<String>>(<String>{}),
        searchQuery = ValueNotifier<String>(''),
        focusTable = ValueNotifier<MealTable?>(null),
        isLoading = ValueNotifier<bool>(false);

  final MealTableLocalDataSource _dataSource;

  final ValueNotifier<List<MealTable>> tables;
  final ValueNotifier<List<MealTable>> filteredTables;
  final ValueNotifier<List<MealTable>> selectedTables;
  final ValueNotifier<List<String>> availableMealTypes;
  final ValueNotifier<List<String>> availableRegions;
  final ValueNotifier<Set<String>> activeMealTypes;
  final ValueNotifier<Set<String>> activeRegions;
  final ValueNotifier<String> searchQuery;
  final ValueNotifier<MealTable?> focusTable;
  final ValueNotifier<bool> isLoading;

  bool _initialized = false;

  Future<void> load() async {
    if (_initialized) {
      return;
    }
    isLoading.value = true;
    final fetched = await _dataSource.fetchAll();
    tables.value = fetched;
    filteredTables.value = fetched;
    availableMealTypes.value =
        fetched.map((table) => table.mealType).toSet().toList()..sort();
    availableRegions.value =
        fetched.map((table) => table.region).toSet().toList()..sort();
    focusTable.value = fetched.isNotEmpty ? fetched.first : null;
    isLoading.value = false;
    _initialized = true;
  }

  void updateSearch(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void toggleMealType(String mealType) {
    final current = Set<String>.from(activeMealTypes.value);
    if (current.contains(mealType)) {
      current.remove(mealType);
    } else {
      current.add(mealType);
    }
    activeMealTypes.value = current;
    _applyFilters();
  }

  void toggleRegion(String region) {
    final current = Set<String>.from(activeRegions.value);
    if (current.contains(region)) {
      current.remove(region);
    } else {
      current.add(region);
    }
    activeRegions.value = current;
    _applyFilters();
  }

  void _applyFilters() {
    final query = searchQuery.value.trim().toLowerCase();
    final mealTypes = activeMealTypes.value;
    final regions = activeRegions.value;
    final source = tables.value;
    final filtered = source.where((table) {
      final matchesMealType = mealTypes.isEmpty || mealTypes.contains(table.mealType);
      if (!matchesMealType) {
        return false;
      }
      final matchesRegion = regions.isEmpty || regions.contains(table.region);
      if (!matchesRegion) {
        return false;
      }
      if (query.isEmpty) {
        return true;
      }
      final haystack = <String>[
        table.country,
        table.mealType,
        table.region,
        table.description,
        ...table.highlights,
        ...table.stats.values,
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList();
    filteredTables.value = filtered;
  }

  void toggleSelection(MealTable table) {
    final current = List<MealTable>.from(selectedTables.value);
    final existingIndex = current.indexWhere((element) => element.id == table.id);
    if (existingIndex >= 0) {
      current.removeAt(existingIndex);
      selectedTables.value = current;
      if (focusTable.value?.id == table.id) {
        focusTable.value = current.isNotEmpty ? current.first : null;
      }
      notifyListeners();
      return;
    }
    if (current.length >= 3) {
      current.removeAt(0);
    }
    current.add(table);
    selectedTables.value = current;
    focusTable.value = table;
    notifyListeners();
  }

  void setFocus(MealTable table) {
    focusTable.value = table;
  }

  List<String> buildStatKeys() {
    final keys = <String>{};
    for (final table in selectedTables.value) {
      keys.addAll(table.stats.keys);
    }
    final sorted = keys.toList()..sort();
    return sorted;
  }

  bool hasDifference(String statKey) {
    final values = selectedTables.value.map((table) => table.stats[statKey]).toSet();
    return values.length > 1;
  }

  @override
  void dispose() {
    tables.dispose();
    filteredTables.dispose();
    selectedTables.dispose();
    availableMealTypes.dispose();
    availableRegions.dispose();
    activeMealTypes.dispose();
    activeRegions.dispose();
    searchQuery.dispose();
    focusTable.dispose();
    isLoading.dispose();
    super.dispose();
  }
}

class MealTableCompareScope extends InheritedNotifier<MealTableCompareController> {
  const MealTableCompareScope({
    required super.child,
    required MealTableCompareController controller,
    super.key,
  }) : super(notifier: controller);

  static MealTableCompareController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<MealTableCompareScope>();
    assert(scope != null, 'MealTableCompareScope not found in context');
    return scope!.notifier!;
  }
}
