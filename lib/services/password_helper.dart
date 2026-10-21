import 'dart:convert';

import 'package:crypto/crypto.dart';

class PasswordHelper {
  /// Hashes a plaintext password using SHA-256 for secure local storage.
  static String hashPassword(String password) {
    final bytes = utf8.encode(password.trim());
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verifies if a raw password matches the stored SHA-256 hash.
  static bool verifyPassword(String rawPassword, String hashedPassword) {
    return hashPassword(rawPassword) == hashedPassword;
  }
}
