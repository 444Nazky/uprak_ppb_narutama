import 'app_preferences.dart';

class AuthService {
  AuthService({AppPreferences? preferences})
    : _preferences = preferences ?? AppPreferences.instance;

  final AppPreferences _preferences;

  static const demoUsername = 'admin';
  static const demoPassword = 'admin123';
  static const displayName = 'Administrator Sekolah';
  static const role = 'Administrator';
  static const usernameLabel = 'admin';

  Future<String?> restoreSession() {
    return _preferences.getSessionUsername();
  }

  Future<bool> signIn(String username, String password) async {
    final normalized = username.trim().toLowerCase();
    final valid = normalized == demoUsername && password == demoPassword;
    if (!valid) return false;
    await _preferences.setSessionUsername(normalized);
    return true;
  }

  Future<void> signOut() {
    return _preferences.setSessionUsername(null);
  }
}
