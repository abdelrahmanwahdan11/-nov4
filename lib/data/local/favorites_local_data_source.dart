import 'package:shared_preferences/shared_preferences.dart';

class FavoritesLocalDataSource {
  FavoritesLocalDataSource({SharedPreferences? sharedPreferences})
      : _prefsFuture = sharedPreferences != null
            ? Future<SharedPreferences>.value(sharedPreferences)
            : SharedPreferences.getInstance();

  static const String _favoritesKey = 'favorite_food_ids';

  final Future<SharedPreferences> _prefsFuture;

  Future<List<String>> read() async {
    final prefs = await _prefsFuture;
    return prefs.getStringList(_favoritesKey) ?? <String>[];
  }

  Future<void> save(List<String> ids) async {
    final prefs = await _prefsFuture;
    await prefs.setStringList(_favoritesKey, ids);
  }
}
