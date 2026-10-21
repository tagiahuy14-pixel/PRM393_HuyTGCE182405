import 'package:flutter/foundation.dart';

import '../services/session_service.dart';

class AuthController extends ChangeNotifier {
  AuthController(this.session);
  final SessionStorage session;
  bool initializing = true;
  bool authenticated = false;
  bool busy = false;
  String? startupError;
  bool _disposed = false;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> restore() async {
    initializing = true;
    startupError = null;
    _notify();
    try {
      authenticated = await session.restore();
    } catch (error) {
      debugPrint('Session restore failed: $error');
      authenticated = false;
      startupError = 'Could not restore your session. Please try again.';
    } finally {
      initializing = false;
      _notify();
    }
  }

  Future<bool> login(String username, String password) async {
    if (busy || initializing) return false;
    // The only account check: no user table, password storage or encryption.
    if (username.trim() != 'admin' || password != '123456') return false;
    busy = true;
    _notify();
    try {
      await session.save();
      authenticated = true;
      return true;
    } finally {
      busy = false;
      _notify();
    }
  }

  Future<void> logout() async {
    if (busy) return;
    busy = true;
    _notify();
    try {
      await session.clear();
      authenticated = false;
    } finally {
      busy = false;
      _notify();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
