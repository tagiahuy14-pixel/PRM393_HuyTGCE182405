import 'package:shared_preferences/shared_preferences.dart';

abstract class SessionStorage {
  Future<bool> restore();
  Future<void> save();
  Future<void> clear();
}

class SessionService implements SessionStorage {
  static const sessionKey = 'isLogin';

  @override
  Future<bool> restore() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.reload();
    return preferences.getBool(sessionKey) ?? false;
  }

  @override
  Future<void> save() async {
    final preferences = await SharedPreferences.getInstance();
    if (!await preferences.setBool(sessionKey, true)) {
      throw StateError('Could not save the session');
    }
  }

  @override
  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    if (!await preferences.remove(sessionKey)) {
      throw StateError('Could not clear the session');
    }
  }
}
