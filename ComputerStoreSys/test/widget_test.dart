import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:computer_store_sys/main.dart';
import 'package:computer_store_sys/database/database_helper.dart';
import 'package:computer_store_sys/services/brand_repository.dart';
import 'package:computer_store_sys/services/category_repository.dart';
import 'package:computer_store_sys/services/computer_repository.dart';

void main() {
  late BrandRepository brandRepo;
  late CategoryRepository categoryRepo;
  late ComputerRepository computerRepo;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    final dbHelper = DatabaseHelper.instance;
    await dbHelper.database;

    brandRepo = BrandRepository(helper: dbHelper);
    categoryRepo = CategoryRepository(helper: dbHelper);
    computerRepo = ComputerRepository(helper: dbHelper);
  });

  testWidgets('App launches with 6 BottomNavigationBar tabs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ComputerStoreApp(
        brandRepository: brandRepo,
        categoryRepository: categoryRepo,
        computerRepository: computerRepo,
      ),
    );

    await tester.runAsync(() async {
      await Future.delayed(const Duration(milliseconds: 300));
    });

    await tester.pump();

    // Verify 6 navigation items exist
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('Store'), findsWidgets);
    expect(find.text('Add'), findsOneWidget);
    expect(find.text('Brands'), findsOneWidget);
    expect(find.text('Categories'), findsOneWidget);
    expect(find.text('Stats'), findsOneWidget);
    expect(find.text('Featured'), findsOneWidget);

    // Initial screen is Store
    expect(find.text('Tech Store'), findsOneWidget);

    // Drain sqflite's internal 10-second lock warning timer
    await tester.pump(const Duration(seconds: 11));
  });
}
