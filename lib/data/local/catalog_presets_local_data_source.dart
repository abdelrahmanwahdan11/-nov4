import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/catalog_filter_preset.dart';

class CatalogPresetsLocalDataSource {
  CatalogPresetsLocalDataSource({SharedPreferences? sharedPreferences})
      : _prefsFuture = sharedPreferences != null
            ? Future<SharedPreferences>.value(sharedPreferences)
            : SharedPreferences.getInstance();

  static const String _storageKey = 'catalog_filter_presets';
  final Future<SharedPreferences> _prefsFuture;

  Future<List<CatalogFilterPreset>> loadPresets() async {
    final prefs = await _prefsFuture;
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return <CatalogFilterPreset>[];
    }
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(CatalogFilterPreset.fromJson)
          .toList();
    } catch (_) {
      return <CatalogFilterPreset>[];
    }
  }

  Future<void> savePresets(List<CatalogFilterPreset> presets) async {
    final prefs = await _prefsFuture;
    final payload = presets.map((preset) => preset.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(payload));
  }
}
