import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('ComputerStoreDB.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    // Enable FFI when running on desktop or unit test environments
    if (!kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    String path;
    if (filePath == inMemoryDatabasePath) {
      path = inMemoryDatabasePath;
    } else {
      final dbPath = await getDatabasesPath();
      path = join(dbPath, filePath);
    }

    return await openDatabase(
      path,
      version: 1,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
    );
  }

  Future<void> _onConfigure(Database db) async {
    // Enable SQLite foreign key enforcement
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    // Table 1: brands
    await db.execute('''
      CREATE TABLE brands (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        brand_name TEXT UNIQUE NOT NULL,
        country TEXT NOT NULL,
        founded_year INTEGER NOT NULL CHECK(founded_year > 1900)
      );
    ''');

    // Table 2: categories
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_name TEXT UNIQUE NOT NULL
      );
    ''');

    // Table 3: computers
    await db.execute('''
      CREATE TABLE computers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_name TEXT UNIQUE NOT NULL,
        brand_id INTEGER NOT NULL,
        category_id INTEGER NOT NULL,
        cpu TEXT NOT NULL,
        ram INTEGER NOT NULL CHECK(ram >= 4 AND ram <= 128),
        storage INTEGER NOT NULL CHECK(storage >= 128 AND storage <= 4096),
        price REAL NOT NULL CHECK(price > 0),
        stock INTEGER NOT NULL CHECK(stock >= 0),
        sold_quantity INTEGER NOT NULL CHECK(sold_quantity >= 0),
        is_featured INTEGER DEFAULT 0 CHECK(is_featured IN (0, 1)),
        FOREIGN KEY (brand_id) REFERENCES brands (id) ON DELETE RESTRICT,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE RESTRICT
      );
    ''');

    // Seed Initial Data
    await _seedDatabase(db);
  }

  Future<void> _seedDatabase(Database db) async {
    // 1. Seed Brands (at least 5 brands)
    final brands = [
      {'brand_name': 'ASUS', 'country': 'Taiwan', 'founded_year': 1989},
      {'brand_name': 'Acer', 'country': 'Taiwan', 'founded_year': 1976},
      {'brand_name': 'Dell', 'country': 'United States', 'founded_year': 1984},
      {'brand_name': 'HP', 'country': 'United States', 'founded_year': 1939},
      {'brand_name': 'Apple', 'country': 'United States', 'founded_year': 1976},
      {'brand_name': 'Lenovo', 'country': 'China', 'founded_year': 1984},
      {'brand_name': 'MSI', 'country': 'Taiwan', 'founded_year': 1986},
    ];

    for (final b in brands) {
      await db.insert('brands', b);
    }

    // 2. Seed Categories (exactly the 3 allowed categories)
    final categories = [
      {'category_name': 'Laptop'},
      {'category_name': 'Desktop'},
      {'category_name': 'Component'},
    ];

    for (final c in categories) {
      await db.insert('categories', c);
    }

    // 3. Seed Computers (at least 15 computers)
    // Brand IDs: 1: ASUS, 2: Acer, 3: Dell, 4: HP, 5: Apple, 6: Lenovo, 7: MSI
    // Category IDs: 1: Laptop, 2: Desktop, 3: Component
    final computers = [
      {
        'product_name': 'ROG Strix G16',
        'brand_id': 1,
        'category_id': 1,
        'cpu': 'Intel Core i7-13650HX',
        'ram': 16,
        'storage': 1000,
        'price': 1250.0,
        'stock': 15,
        'sold_quantity': 32,
        'is_featured': 1,
      },
      {
        'product_name': 'Vivobook S15',
        'brand_id': 1,
        'category_id': 1,
        'cpu': 'Intel Core i5-13500H',
        'ram': 16,
        'storage': 512,
        'price': 750.0,
        'stock': 20,
        'sold_quantity': 18,
        'is_featured': 0,
      },
      {
        'product_name': 'TUF Gaming A15',
        'brand_id': 1,
        'category_id': 1,
        'cpu': 'AMD Ryzen 7 7735HS',
        'ram': 16,
        'storage': 512,
        'price': 950.0,
        'stock': 12,
        'sold_quantity': 25,
        'is_featured': 1,
      },
      {
        'product_name': 'Predator Helios 16',
        'brand_id': 2,
        'category_id': 1,
        'cpu': 'Intel Core i9-13900HX',
        'ram': 32,
        'storage': 1024,
        'price': 1750.0,
        'stock': 8,
        'sold_quantity': 14,
        'is_featured': 1,
      },
      {
        'product_name': 'Nitro 5',
        'brand_id': 2,
        'category_id': 1,
        'cpu': 'Intel Core i5-12500H',
        'ram': 8,
        'storage': 512,
        'price': 680.0,
        'stock': 25,
        'sold_quantity': 40,
        'is_featured': 0,
      },
      {
        'product_name': 'Aspire 5',
        'brand_id': 2,
        'category_id': 1,
        'cpu': 'Intel Core i3-1215U',
        'ram': 8,
        'storage': 256,
        'price': 450.0,
        'stock': 18,
        'sold_quantity': 22,
        'is_featured': 0,
      },
      {
        'product_name': 'XPS 15',
        'brand_id': 3,
        'category_id': 1,
        'cpu': 'Intel Core i7-13700H',
        'ram': 32,
        'storage': 1024,
        'price': 1899.0,
        'stock': 6,
        'sold_quantity': 12,
        'is_featured': 1,
      },
      {
        'product_name': 'Alienware Aurora R16',
        'brand_id': 3,
        'category_id': 2,
        'cpu': 'Intel Core i9-14900KF',
        'ram': 64,
        'storage': 2048,
        'price': 2799.0,
        'stock': 4,
        'sold_quantity': 8,
        'is_featured': 1,
      },
      {
        'product_name': 'Inspiron 24 All-in-One',
        'brand_id': 3,
        'category_id': 2,
        'cpu': 'Intel Core i5-1335U',
        'ram': 16,
        'storage': 512,
        'price': 850.0,
        'stock': 10,
        'sold_quantity': 15,
        'is_featured': 0,
      },
      {
        'product_name': 'OMEN 45L Gaming Desktop',
        'brand_id': 4,
        'category_id': 2,
        'cpu': 'Intel Core i7-14700K',
        'ram': 32,
        'storage': 2048,
        'price': 2199.0,
        'stock': 5,
        'sold_quantity': 11,
        'is_featured': 1,
      },
      {
        'product_name': 'Victus 16',
        'brand_id': 4,
        'category_id': 1,
        'cpu': 'AMD Ryzen 5 7640HS',
        'ram': 16,
        'storage': 512,
        'price': 820.0,
        'stock': 14,
        'sold_quantity': 30,
        'is_featured': 0,
      },
      {
        'product_name': 'Pavilion Desktop TP01',
        'brand_id': 4,
        'category_id': 2,
        'cpu': 'Intel Core i5-12400',
        'ram': 8,
        'storage': 512,
        'price': 599.0,
        'stock': 9,
        'sold_quantity': 16,
        'is_featured': 0,
      },
      {
        'product_name': 'MacBook Pro 16 M3 Max',
        'brand_id': 5,
        'category_id': 1,
        'cpu': 'Apple M3 Max 16-Core',
        'ram': 36,
        'storage': 1024,
        'price': 3499.0,
        'stock': 3,
        'sold_quantity': 28,
        'is_featured': 1,
      },
      {
        'product_name': 'Mac Studio M2 Ultra',
        'brand_id': 5,
        'category_id': 2,
        'cpu': 'Apple M2 Ultra 24-Core',
        'ram': 64,
        'storage': 2048,
        'price': 3999.0,
        'stock': 2,
        'sold_quantity': 7,
        'is_featured': 1,
      },
      {
        'product_name': 'Legion Pro 7i',
        'brand_id': 6,
        'category_id': 1,
        'cpu': 'Intel Core i9-14900HX',
        'ram': 32,
        'storage': 1024,
        'price': 2399.0,
        'stock': 7,
        'sold_quantity': 19,
        'is_featured': 1,
      },
      {
        'product_name': 'ThinkPad X1 Carbon Gen 11',
        'brand_id': 6,
        'category_id': 1,
        'cpu': 'Intel Core i7-1365U',
        'ram': 16,
        'storage': 512,
        'price': 1450.0,
        'stock': 11,
        'sold_quantity': 21,
        'is_featured': 0,
      },
      {
        'product_name': 'ROG Strix GeForce RTX 4090 OC',
        'brand_id': 1,
        'category_id': 3,
        'cpu': 'NVIDIA AD102-300 GPU',
        'ram': 24,
        'storage': 256,
        'price': 1999.0,
        'stock': 5,
        'sold_quantity': 15,
        'is_featured': 1,
      },
      {
        'product_name': 'MSI Raider GE78 HX',
        'brand_id': 7,
        'category_id': 1,
        'cpu': 'Intel Core i9-13980HX',
        'ram': 32,
        'storage': 2048,
        'price': 2599.0,
        'stock': 3,
        'sold_quantity': 9,
        'is_featured': 1,
      },
    ];

    for (final comp in computers) {
      await db.insert('computers', comp);
    }
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
