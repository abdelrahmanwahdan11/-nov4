import 'dart:async';

import '../dummy/dummy_cars.dart';
import '../../domain/models/car.dart';

class CarLocalDataSource {
  Future<List<Car>> fetchAll() async {
    await Future<void>.delayed(const Duration(milliseconds: 240));
    return List<Car>.from(dummyCars);
  }

  Future<List<Car>> search(String query) async {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return fetchAll();
    }
    await Future<void>.delayed(const Duration(milliseconds: 160));
    return dummyCars.where((car) {
      final name = '${car.brand} ${car.model}'.toLowerCase();
      final specsText = car.specs.values.join(' ').toLowerCase();
      return name.contains(normalized) || specsText.contains(normalized);
    }).toList();
  }
}
