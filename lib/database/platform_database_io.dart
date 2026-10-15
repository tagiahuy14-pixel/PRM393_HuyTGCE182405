import 'dart:io';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Initializes SQLite FFI for Windows, Linux, and macOS.
Future<void> initializeDatabase() async {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
}
