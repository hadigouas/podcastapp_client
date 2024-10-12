import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static SharedPreferences? _prefs;

  // Initialize SharedPreferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<bool> setString(String key, String value) async {
    if (_prefs == null) await init();
    return await _prefs!.setString(key, value);
  }

  static String getString(String key, {String defaultValue = ''}) {
    if (_prefs == null) {
      return defaultValue;
    }
    return _prefs!.getString(key) ?? defaultValue;
  }

  // Remove a value
  static Future<bool> remove(String key) async {
    if (_prefs == null) await init();
    return await _prefs!.remove(key);
  }

  // Clear all preferences
  static Future<bool> clear() async {
    if (_prefs == null) await init();
    return await _prefs!.clear();
  }
}
