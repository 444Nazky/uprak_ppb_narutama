import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  AppPreferences._();

  static final AppPreferences instance = AppPreferences._();

  static const _sessionKey = 'session_username';
  static const _darkModeKey = 'pref_dark_mode';
  static const _notificationsKey = 'pref_notifications';

  SharedPreferences? _preferences;

  Future<SharedPreferences> get _prefs async {
    return _preferences ??= await SharedPreferences.getInstance();
  }

  Future<String?> getSessionUsername() async {
    final prefs = await _prefs;
    final value = prefs.getString(_sessionKey);
    return value == null || value.isEmpty ? null : value;
  }

  Future<void> setSessionUsername(String? username) async {
    final prefs = await _prefs;
    if (username == null || username.isEmpty) {
      await prefs.remove(_sessionKey);
    } else {
      await prefs.setString(_sessionKey, username);
    }
  }

  Future<bool> isDarkMode() async {
    final prefs = await _prefs;
    return prefs.getBool(_darkModeKey) ?? false;
  }

  Future<void> setDarkMode(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_darkModeKey, value);
  }

  Future<bool> notificationsEnabled() async {
    final prefs = await _prefs;
    return prefs.getBool(_notificationsKey) ?? true;
  }

  Future<void> setNotificationsEnabled(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_notificationsKey, value);
  }
}
