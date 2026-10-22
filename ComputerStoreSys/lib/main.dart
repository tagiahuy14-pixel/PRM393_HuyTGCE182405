import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'database/database_helper.dart';
import 'screens/main_navigation_screen.dart';
import 'services/brand_repository.dart';
import 'services/category_repository.dart';
import 'services/computer_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SQLite FFI for Desktop/Testing environments
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Pre-initialize database singleton
  final dbHelper = DatabaseHelper.instance;
  await dbHelper.database;

  final brandRepository = BrandRepository(helper: dbHelper);
  final categoryRepository = CategoryRepository(helper: dbHelper);
  final computerRepository = ComputerRepository(helper: dbHelper);

  runApp(
    ComputerStoreApp(
      brandRepository: brandRepository,
      categoryRepository: categoryRepository,
      computerRepository: computerRepository,
    ),
  );
}

class ComputerStoreApp extends StatelessWidget {
  final BrandRepository brandRepository;
  final CategoryRepository categoryRepository;
  final ComputerRepository computerRepository;

  const ComputerStoreApp({
    super.key,
    required this.brandRepository,
    required this.categoryRepository,
    required this.computerRepository,
  });

  @override
  Widget build(BuildContext context) {
    const primarySeed = Color(0xFF1565C0); // Premium deep tech blue

    return MaterialApp(
      title: 'Computer Store Management System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primarySeed,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: MainNavigationScreen(
        computerRepository: computerRepository,
        brandRepository: brandRepository,
        categoryRepository: categoryRepository,
      ),
    );
  }
}
