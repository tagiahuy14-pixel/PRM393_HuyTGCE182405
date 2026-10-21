import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/artwork.dart';
import '../models/favorite.dart';
import '../models/gallery_stats.dart';
import '../models/user.dart';
import 'password_helper.dart';

class DatabaseHelper {
  static const String _dbName = 'art_gallery.db';
  static const int _dbVersion = 1;

  static const String tableUsers = 'users';
  static const String tableArtworks = 'artworks';
  static const String tableFavorites = 'favorites';

  static DatabaseHelper? _instance;
  static Database? _database;

  DatabaseHelper._();

  static DatabaseHelper get instance {
    _instance ??= DatabaseHelper._();
    return _instance!;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Enable FFI for desktop and test environments
    if (!kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 1. Users Table
    await db.execute('''
      CREATE TABLE $tableUsers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        email TEXT NOT NULL,
        password TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    // 2. Artworks Table
    await db.execute('''
      CREATE TABLE $tableArtworks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        artist TEXT NOT NULL,
        year TEXT NOT NULL,
        category TEXT NOT NULL,
        description TEXT NOT NULL,
        createdBy INTEGER NOT NULL,
        FOREIGN KEY (createdBy) REFERENCES $tableUsers (id) ON DELETE CASCADE
      )
    ''');

    // 3. Favorites Table
    await db.execute('''
      CREATE TABLE $tableFavorites (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        artworkId INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        UNIQUE(userId, artworkId),
        FOREIGN KEY (userId) REFERENCES $tableUsers (id) ON DELETE CASCADE,
        FOREIGN KEY (artworkId) REFERENCES $tableArtworks (id) ON DELETE CASCADE
      )
    ''');
  }

  // ---------------------------------------------------------------------------
  // USER METHODS
  // ---------------------------------------------------------------------------

  Future<bool> isUsernameTaken(String username) async {
    final db = await database;
    final result = await db.query(
      tableUsers,
      where: 'LOWER(username) = ?',
      whereArgs: [username.trim().toLowerCase()],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  Future<int> registerUser(User user) async {
    final db = await database;
    // Check if username already exists
    if (await isUsernameTaken(user.username)) {
      throw Exception('Username already exists');
    }

    final userMap = user.toMap();
    // Ensure password is stored hashed
    userMap['password'] = PasswordHelper.hashPassword(user.password);
    return await db.insert(tableUsers, userMap);
  }

  Future<User?> login(String username, String rawPassword) async {
    final db = await database;
    final hashedPassword = PasswordHelper.hashPassword(rawPassword);

    final result = await db.query(
      tableUsers,
      where: 'LOWER(username) = ? AND password = ?',
      whereArgs: [username.trim().toLowerCase(), hashedPassword],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  Future<User?> getUserById(int id) async {
    final db = await database;
    final result = await db.query(
      tableUsers,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // ARTWORK METHODS
  // ---------------------------------------------------------------------------

  Future<int> insertArtwork(Artwork artwork) async {
    final db = await database;
    return await db.insert(tableArtworks, artwork.toMap());
  }

  Future<int> updateArtwork(Artwork artwork) async {
    final db = await database;
    return await db.update(
      tableArtworks,
      artwork.toMap(),
      where: 'id = ?',
      whereArgs: [artwork.id],
    );
  }

  Future<int> deleteArtwork(int id) async {
    final db = await database;
    // Also remove any favorites pointing to this artwork
    await db.delete(tableFavorites, where: 'artworkId = ?', whereArgs: [id]);
    return await db.delete(tableArtworks, where: 'id = ?', whereArgs: [id]);
  }

  Future<Artwork?> getArtworkById(int id) async {
    final db = await database;
    final result = await db.query(
      tableArtworks,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return Artwork.fromMap(result.first);
    }
    return null;
  }

  Future<List<Artwork>> getAllArtworks() async {
    final db = await database;
    final result = await db.query(tableArtworks, orderBy: 'id DESC');
    return result.map((e) => Artwork.fromMap(e)).toList();
  }

  /// Searches and filters artworks dynamically.
  /// - [query]: search by title (case-insensitive substring)
  /// - [yearFilter]: 'All years', 'Current year', or 'Last 5 years'
  /// - [categoryFilter]: 'All categories' or specific category
  Future<List<Artwork>> searchAndFilterArtworks({
    String? query,
    String? yearFilter,
    String? categoryFilter,
  }) async {
    final db = await database;
    final List<String> whereClauses = [];
    final List<dynamic> whereArgs = [];

    // 1. Search by title
    if (query != null && query.trim().isNotEmpty) {
      whereClauses.add('LOWER(title) LIKE ?');
      whereArgs.add('%${query.trim().toLowerCase()}%');
    }

    // 2. Category filter
    if (categoryFilter != null &&
        categoryFilter.isNotEmpty &&
        categoryFilter != 'All categories' &&
        categoryFilter != 'All') {
      whereClauses.add('category = ?');
      whereArgs.add(categoryFilter);
    }

    // 3. Year filter
    final currentYear = DateTime.now().year;
    if (yearFilter != null &&
        yearFilter.isNotEmpty &&
        yearFilter != 'All years' &&
        yearFilter != 'All') {
      if (yearFilter == 'Current year') {
        whereClauses.add('year = ?');
        whereArgs.add(currentYear.toString());
      } else if (yearFilter == 'Last 5 years') {
        // e.g. 2026, 2025, 2024, 2023, 2022
        final startYear = currentYear - 4;
        whereClauses.add('CAST(year AS INTEGER) BETWEEN ? AND ?');
        whereArgs.add(startYear);
        whereArgs.add(currentYear);
      }
    }

    final whereString = whereClauses.isNotEmpty
        ? whereClauses.join(' AND ')
        : null;

    final result = await db.query(
      tableArtworks,
      where: whereString,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'id DESC',
    );

    return result.map((e) => Artwork.fromMap(e)).toList();
  }

  // ---------------------------------------------------------------------------
  // FAVORITE METHODS
  // ---------------------------------------------------------------------------

  Future<bool> isFavorite(int userId, int artworkId) async {
    final db = await database;
    final result = await db.query(
      tableFavorites,
      where: 'userId = ? AND artworkId = ?',
      whereArgs: [userId, artworkId],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  Future<bool> addFavorite(int userId, int artworkId) async {
    final db = await database;
    if (await isFavorite(userId, artworkId)) {
      return false; // Already favorited, prevent duplicate
    }

    final favorite = Favorite(
      userId: userId,
      artworkId: artworkId,
      createdAt: DateTime.now().toIso8601String(),
    );

    await db.insert(tableFavorites, favorite.toMap());
    return true;
  }

  Future<int> removeFavorite(int userId, int artworkId) async {
    final db = await database;
    return await db.delete(
      tableFavorites,
      where: 'userId = ? AND artworkId = ?',
      whereArgs: [userId, artworkId],
    );
  }

  Future<List<Artwork>> getFavoriteArtworks(int userId) async {
    final db = await database;
    final sql =
        '''
      SELECT a.* FROM $tableArtworks a
      INNER JOIN $tableFavorites f ON a.id = f.artworkId
      WHERE f.userId = ?
      ORDER BY f.id DESC
    ''';
    final result = await db.rawQuery(sql, [userId]);
    return result.map((e) => Artwork.fromMap(e)).toList();
  }

  // ---------------------------------------------------------------------------
  // STATISTICS METHOD
  // ---------------------------------------------------------------------------

  Future<GalleryStats> getGalleryStats(int userId) async {
    final db = await database;

    // Total artworks
    final totalArtworksResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tableArtworks',
    );
    final totalArtworks = Sqflite.firstIntValue(totalArtworksResult) ?? 0;

    // Favorite artworks for current user
    final favoriteResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tableFavorites WHERE userId = ?',
      [userId],
    );
    final favoriteArtworks = Sqflite.firstIntValue(favoriteResult) ?? 0;

    // Categories: distinct count of categories currently present in artworks
    final categoriesResult = await db.rawQuery(
      'SELECT COUNT(DISTINCT category) as count FROM $tableArtworks',
    );
    final totalCategories = Sqflite.firstIntValue(categoriesResult) ?? 0;

    return GalleryStats(
      totalArtworks: totalArtworks,
      favoriteArtworks: favoriteArtworks,
      totalCategories: totalCategories,
    );
  }

  /// Close database (useful for testing or app teardown)
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
