import 'dart:async';

class AppPreferences {
  AppPreferences._();

  static final AppPreferences _instance = AppPreferences._();

  static Future<AppPreferences> getInstance() async {
    return _instance;
  }

  final Map<String, Object> _storage = <String, Object>{};

  bool? getBool(String key) => _storage[key] as bool?;
  Future<bool> setBool(String key, bool value) async {
    _storage[key] = value;
    return true;
  }

  int? getInt(String key) => _storage[key] as int?;
  Future<bool> setInt(String key, int value) async {
    _storage[key] = value;
    return true;
  }

  double? getDouble(String key) => _storage[key] as double?;
  Future<bool> setDouble(String key, double value) async {
    _storage[key] = value;
    return true;
  }

  String? getString(String key) => _storage[key] as String?;
  Future<bool> setString(String key, String value) async {
    _storage[key] = value;
    return true;
  }

  List<String>? getStringList(String key) => (_storage[key] as List<String>?)?.toList();
  Future<bool> setStringList(String key, List<String> value) async {
    _storage[key] = List<String>.from(value);
    return true;
  }

  Future<bool> remove(String key) async {
    _storage.remove(key);
    return true;
  }

  Future<bool> clear() async {
    _storage.clear();
    return true;
  }
}
