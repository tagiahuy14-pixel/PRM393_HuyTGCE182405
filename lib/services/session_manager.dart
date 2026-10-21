import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _keyUserId = 'user_id';
  static const String _keyUsername = 'username';
  static const String _keyEmail = 'email';
  static const String _keyIsLoggedIn = 'is_logged_in';

  static SessionManager? _instance;
  static SharedPreferences? _prefs;

  SessionManager._();

  static Future<SessionManager> getInstance() async {
    _instance ??= SessionManager._();
    _prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  Future<void> saveUserSession({
    required int userId,
    required String username,
    required String email,
  }) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setInt(_keyUserId, userId);
    await prefs.setString(_keyUsername, username);
    await prefs.setString(_keyEmail, email);
    await prefs.setBool(_keyIsLoggedIn, true);
  }

  Future<bool> isLoggedIn() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  Future<int?> getUserId() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    return prefs.getInt(_keyUserId);
  }

  Future<String?> getUsername() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    return prefs.getString(_keyUsername);
  }

  Future<String?> getUserEmail() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail);
  }

  Future<void> clearSession() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUsername);
    await prefs.remove(_keyEmail);
    await prefs.setBool(_keyIsLoggedIn, false);
  }
}
