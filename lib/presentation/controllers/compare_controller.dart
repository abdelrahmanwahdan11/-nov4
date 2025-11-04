import 'package:flutter/material.dart';

import '../../data/local/car_local_data_source.dart';
import '../../domain/models/car.dart';

class CompareController extends ChangeNotifier {
  CompareController({required CarLocalDataSource dataSource})
      : _dataSource = dataSource,
        cars = ValueNotifier<List<Car>>(<Car>[]),
        filteredCars = ValueNotifier<List<Car>>(<Car>[]),
        selectedCars = ValueNotifier<List<Car>>(<Car>[]),
        availableBrands = ValueNotifier<List<String>>(<String>[]),
        activeBrands = ValueNotifier<Set<String>>(<String>{}),
        searchQuery = ValueNotifier<String>(''),
        focusCar = ValueNotifier<Car?>(null),
        isLoading = ValueNotifier<bool>(false);

  final CarLocalDataSource _dataSource;

  final ValueNotifier<List<Car>> cars;
  final ValueNotifier<List<Car>> filteredCars;
  final ValueNotifier<List<Car>> selectedCars;
  final ValueNotifier<List<String>> availableBrands;
  final ValueNotifier<Set<String>> activeBrands;
  final ValueNotifier<String> searchQuery;
  final ValueNotifier<Car?> focusCar;
  final ValueNotifier<bool> isLoading;

  bool _initialized = false;

  Future<void> load() async {
    if (_initialized) {
      return;
    }
    isLoading.value = true;
    final fetched = await _dataSource.fetchAll();
    cars.value = fetched;
    filteredCars.value = fetched;
    final brands = fetched.map((car) => car.brand).toSet().toList()..sort();
    availableBrands.value = brands;
    focusCar.value = fetched.isNotEmpty ? fetched.first : null;
    isLoading.value = false;
    _initialized = true;
  }

  void updateSearch(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void toggleBrand(String brand) {
    final current = Set<String>.from(activeBrands.value);
    if (current.contains(brand)) {
      current.remove(brand);
    } else {
      current.add(brand);
    }
    activeBrands.value = current;
    _applyFilters();
  }

  void _applyFilters() {
    final query = searchQuery.value.trim().toLowerCase();
    final brands = activeBrands.value;
    final source = cars.value;
    final filtered = source.where((car) {
      final matchesBrand = brands.isEmpty || brands.contains(car.brand);
      if (!matchesBrand) {
        return false;
      }
      if (query.isEmpty) {
        return true;
      }
      final haystack = '${car.brand} ${car.model} ${car.year} ${car.specs.values.join(' ')}'.toLowerCase();
      return haystack.contains(query);
    }).toList();
    filteredCars.value = filtered;
  }

  void toggleSelection(Car car) {
    final current = List<Car>.from(selectedCars.value);
    final existingIndex = current.indexWhere((element) => element.id == car.id);
    if (existingIndex >= 0) {
      current.removeAt(existingIndex);
      selectedCars.value = current;
      if (focusCar.value?.id == car.id) {
        focusCar.value = current.isNotEmpty ? current.first : null;
      }
      notifyListeners();
      return;
    }
    if (current.length >= 3) {
      current.removeAt(0);
    }
    current.add(car);
    selectedCars.value = current;
    focusCar.value = car;
    notifyListeners();
  }

  void setFocus(Car car) {
    focusCar.value = car;
  }

  List<String> buildSpecKeys() {
    final keys = <String>{};
    for (final car in selectedCars.value) {
      keys.addAll(car.specs.keys);
    }
    final sorted = keys.toList()..sort();
    return sorted;
  }

  bool hasDifference(String specKey) {
    final values = selectedCars.value.map((car) => car.specs[specKey]).toSet();
    return values.length > 1;
  }

  @override
  void dispose() {
    cars.dispose();
    filteredCars.dispose();
    selectedCars.dispose();
    availableBrands.dispose();
    activeBrands.dispose();
    searchQuery.dispose();
    focusCar.dispose();
    isLoading.dispose();
    super.dispose();
  }
}

class CompareScope extends InheritedNotifier<CompareController> {
  const CompareScope({
    required super.child,
    required CompareController controller,
    super.key,
  }) : super(notifier: controller);

  static CompareController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<CompareScope>();
    assert(scope != null, 'CompareScope not found in context');
    return scope!.notifier!;
  }
}
