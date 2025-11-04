import 'package:flutter/foundation.dart';

import '../../data/local/food_local_data_source.dart';
import '../../domain/models/food_item.dart';
import 'app_controller.dart';
import 'content_status.dart';

class HomeCollectionState {
  const HomeCollectionState({
    required this.status,
    required this.items,
    this.errorKey,
  });

  final ContentStatus status;
  final List<FoodItem> items;
  final String? errorKey;

  factory HomeCollectionState.idle() {
    return const HomeCollectionState(
      status: ContentStatus.idle,
      items: <FoodItem>[],
    );
  }

  factory HomeCollectionState.loading() {
    return const HomeCollectionState(
      status: ContentStatus.loading,
      items: <FoodItem>[],
    );
  }

  factory HomeCollectionState.success(List<FoodItem> items) {
    return HomeCollectionState(
      status: ContentStatus.success,
      items: List<FoodItem>.unmodifiable(items),
    );
  }

  factory HomeCollectionState.empty() {
    return const HomeCollectionState(
      status: ContentStatus.empty,
      items: <FoodItem>[],
    );
  }

  factory HomeCollectionState.offline() {
    return const HomeCollectionState(
      status: ContentStatus.offline,
      items: <FoodItem>[],
    );
  }

  factory HomeCollectionState.error([String? key]) {
    return HomeCollectionState(
      status: ContentStatus.error,
      items: const <FoodItem>[],
      errorKey: key,
    );
  }
}

class HomeCollectionsController {
  HomeCollectionsController({
    required FoodLocalDataSource dataSource,
    ValueListenable<ConnectionOverride>? connectionOverride,
    this.maxItemsPerSection = 9,
  })  : _dataSource = dataSource,
        _connectionOverride = connectionOverride {
    final override = _connectionOverride?.value ?? ConnectionOverride.normal;
    _handleConnectionChange(override, initial: true);
    if (_connectionOverride != null) {
      _connectionListener = () {
        _handleConnectionChange(_connectionOverride!.value);
      };
      _connectionOverride!.addListener(_connectionListener!);
    }
  }

  final FoodLocalDataSource _dataSource;
  final ValueListenable<ConnectionOverride>? _connectionOverride;
  final int maxItemsPerSection;

  final ValueNotifier<HomeCollectionState> deals =
      ValueNotifier<HomeCollectionState>(HomeCollectionState.idle());
  final ValueNotifier<HomeCollectionState> healthiest =
      ValueNotifier<HomeCollectionState>(HomeCollectionState.idle());
  final ValueNotifier<HomeCollectionState> plantBased =
      ValueNotifier<HomeCollectionState>(HomeCollectionState.idle());

  VoidCallback? _connectionListener;
  bool _disposed = false;

  Future<void> loadDeals() async {
    await _loadCollection(deals, _buildDeals);
  }

  Future<void> loadHealthiest() async {
    await _loadCollection(healthiest, _buildHealthiest);
  }

  Future<void> loadPlantBased() async {
    await _loadCollection(plantBased, _buildPlantBased);
  }

  Future<void> _loadCollection(
    ValueNotifier<HomeCollectionState> notifier,
    List<FoodItem> Function(List<FoodItem>) selector,
  ) async {
    if (_disposed) {
      return;
    }
    final current = notifier.value.status;
    if (current == ContentStatus.loading || current == ContentStatus.success) {
      return;
    }
    final connection = _connectionOverride?.value ?? ConnectionOverride.normal;
    if (connection != ConnectionOverride.normal) {
      _handleConnectionChange(connection);
      return;
    }
    notifier.value = HomeCollectionState.loading();
    try {
      final all = await _dataSource.fetchAll();
      if (_disposed) {
        return;
      }
      final selected = selector(all);
      if (selected.isEmpty) {
        notifier.value = HomeCollectionState.empty();
      } else {
        notifier.value = HomeCollectionState.success(
          selected.take(maxItemsPerSection).toList(growable: false),
        );
      }
    } catch (_) {
      if (_disposed) {
        return;
      }
      notifier.value = HomeCollectionState.error('state_error_message');
    }
  }

  List<FoodItem> _buildDeals(List<FoodItem> items) {
    final promoCandidates = items.where((item) {
      for (final tag in item.tags) {
        final normalized = tag.toLowerCase();
        if (normalized.contains('deal') ||
            normalized.contains('combo') ||
            normalized.contains('bundle') ||
            normalized.contains('value')) {
          return true;
        }
      }
      return item.isNew;
    }).toList();
    final effective = promoCandidates.isNotEmpty ? promoCandidates : List<FoodItem>.from(items);
    effective.sort((a, b) {
      final priceCompare = a.price.compareTo(b.price);
      if (priceCompare != 0) {
        return priceCompare;
      }
      return b.popularityScore.compareTo(a.popularityScore);
    });
    return effective;
  }

  List<FoodItem> _buildHealthiest(List<FoodItem> items) {
    final healthiestItems = items.where((item) => item.isLowCalorie).toList();
    if (healthiestItems.isEmpty) {
      return List<FoodItem>.from(items)
        ..sort((a, b) => a.kcal.compareTo(b.kcal));
    }
    healthiestItems.sort((a, b) {
      final kcalCompare = a.kcal.compareTo(b.kcal);
      if (kcalCompare != 0) {
        return kcalCompare;
      }
      return b.popularityScore.compareTo(a.popularityScore);
    });
    return healthiestItems;
  }

  List<FoodItem> _buildPlantBased(List<FoodItem> items) {
    final veganItems = items.where((item) => item.isVegan).toList();
    if (veganItems.isEmpty) {
      return List<FoodItem>.from(items)
        ..sort((a, b) {
          if (a.isVegan == b.isVegan) {
            return b.popularityScore.compareTo(a.popularityScore);
          }
          return a.isVegan ? -1 : 1;
        });
    }
    veganItems.sort((a, b) {
      final popularityCompare = b.popularityScore.compareTo(a.popularityScore);
      if (popularityCompare != 0) {
        return popularityCompare;
      }
      return b.addedAt.compareTo(a.addedAt);
    });
    return veganItems;
  }

  void _handleConnectionChange(ConnectionOverride connection, {bool initial = false}) {
    if (_disposed) {
      return;
    }
    switch (connection) {
      case ConnectionOverride.normal:
        if (!initial) {
          if (deals.value.status == ContentStatus.offline ||
              deals.value.status == ContentStatus.error ||
              deals.value.status == ContentStatus.empty) {
            deals.value = HomeCollectionState.idle();
          }
          if (healthiest.value.status == ContentStatus.offline ||
              healthiest.value.status == ContentStatus.error ||
              healthiest.value.status == ContentStatus.empty) {
            healthiest.value = HomeCollectionState.idle();
          }
          if (plantBased.value.status == ContentStatus.offline ||
              plantBased.value.status == ContentStatus.error ||
              plantBased.value.status == ContentStatus.empty) {
            plantBased.value = HomeCollectionState.idle();
          }
        }
        break;
      case ConnectionOverride.offline:
        deals.value = HomeCollectionState.offline();
        healthiest.value = HomeCollectionState.offline();
        plantBased.value = HomeCollectionState.offline();
        break;
      case ConnectionOverride.error:
        deals.value = HomeCollectionState.error('state_error_message');
        healthiest.value = HomeCollectionState.error('state_error_message');
        plantBased.value = HomeCollectionState.error('state_error_message');
        break;
    }
  }

  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    deals.dispose();
    healthiest.dispose();
    plantBased.dispose();
    if (_connectionListener != null && _connectionOverride != null) {
      _connectionOverride!.removeListener(_connectionListener!);
    }
  }
}
