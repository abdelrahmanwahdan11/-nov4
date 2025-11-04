import 'package:shared_preferences/shared_preferences.dart';

class RecentlyViewedLocalDataSource {
  RecentlyViewedLocalDataSource({SharedPreferences? sharedPreferences})
      : _prefsFuture = sharedPreferences != null
            ? Future<SharedPreferences>.value(sharedPreferences)
            : SharedPreferences.getInstance();

  static const String _recentKey = 'recently_viewed_food_ids';

  final Future<SharedPreferences> _prefsFuture;

  Future<List<String>> read() async {
    final prefs = await _prefsFuture;
    return prefs.getStringList(_recentKey) ?? <String>[];
  }

  Future<void> save(List<String> ids) async {
    final prefs = await _prefsFuture;
    await prefs.setStringList(_recentKey, ids);
  }
}
