import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../models/category.dart';

class CategoryRepository {
  final DatabaseHelper dbHelper;

  CategoryRepository({DatabaseHelper? helper})
    : dbHelper = helper ?? DatabaseHelper.instance;

  Future<int> insertCategory(Category category) async {
    final db = await dbHelper.database;
    final name = category.categoryName.trim();
    if (name.isEmpty) {
      throw Exception('Category Name is required.');
    }
    // Check duplicate category name (case-insensitive)
    final existing = await db.query(
      'categories',
      where: 'LOWER(category_name) = ?',
      whereArgs: [name.toLowerCase()],
    );
    if (existing.isNotEmpty) {
      throw Exception('Category Name must be unique.');
    }
    return await db.insert('categories', category.toMap());
  }

  Future<int> updateCategory(Category category) async {
    final db = await dbHelper.database;
    if (category.id == null) {
      throw Exception('Category ID cannot be null for update.');
    }
    final name = category.categoryName.trim();
    if (name.isEmpty) {
      throw Exception('Category Name is required.');
    }
    // Check duplicate category name excluding current id
    final existing = await db.query(
      'categories',
      where: 'LOWER(category_name) = ? AND id != ?',
      whereArgs: [name.toLowerCase(), category.id],
    );
    if (existing.isNotEmpty) {
      throw Exception('Category Name must be unique.');
    }
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> getProductCountForCategory(int categoryId) async {
    final db = await dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM computers WHERE category_id = ?',
      [categoryId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<bool> deleteCategory(int id) async {
    final db = await dbHelper.database;
    // Check whether the Category is currently used
    final count = await getProductCountForCategory(id);
    if (count > 0) {
      throw Exception(
        'This category cannot be deleted because one or more products belong to this category.',
      );
    }
    final rowsDeleted = await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
    return rowsDeleted > 0;
  }

  Future<Category?> getCategoryById(int id) async {
    final db = await dbHelper.database;
    final result = await db.rawQuery(
      '''
      SELECT
        ca.id,
        ca.category_name,
        COUNT(c.id) AS totalProducts
      FROM categories ca
      LEFT JOIN computers c ON ca.id = c.category_id
      WHERE ca.id = ?
      GROUP BY ca.id
    ''',
      [id],
    );

    if (result.isNotEmpty) {
      return Category.fromMap(result.first);
    }
    return null;
  }

  Future<List<Category>> getAllCategories() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('''
      SELECT
        ca.id,
        ca.category_name,
        COUNT(c.id) AS totalProducts
      FROM categories ca
      LEFT JOIN computers c ON ca.id = c.category_id
      GROUP BY ca.id
      ORDER BY ca.category_name ASC
    ''');
    return result.map((map) => Category.fromMap(map)).toList();
  }

  Future<List<Category>> searchCategories(String keyword) async {
    final db = await dbHelper.database;
    final trimmed = keyword.trim();
    if (trimmed.isEmpty) {
      return getAllCategories();
    }
    final pattern = '%$trimmed%';
    final result = await db.rawQuery(
      '''
      SELECT
        ca.id,
        ca.category_name,
        COUNT(c.id) AS totalProducts
      FROM categories ca
      LEFT JOIN computers c ON ca.id = c.category_id
      WHERE LOWER(ca.category_name) LIKE LOWER(?)
      GROUP BY ca.id
      ORDER BY ca.category_name ASC
    ''',
      [pattern],
    );
    return result.map((map) => Category.fromMap(map)).toList();
  }
}
