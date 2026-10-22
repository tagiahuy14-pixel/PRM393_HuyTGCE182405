import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../models/brand.dart';

class BrandRepository {
  final DatabaseHelper dbHelper;

  BrandRepository({DatabaseHelper? helper})
    : dbHelper = helper ?? DatabaseHelper.instance;

  Future<int> insertBrand(Brand brand) async {
    final db = await dbHelper.database;
    // Check duplicate brand name (case-insensitive)
    final existing = await db.query(
      'brands',
      where: 'LOWER(brand_name) = ?',
      whereArgs: [brand.brandName.trim().toLowerCase()],
    );
    if (existing.isNotEmpty) {
      throw Exception('Duplicate Brand Name is not allowed.');
    }
    return await db.insert('brands', brand.toMap());
  }

  Future<int> updateBrand(Brand brand) async {
    final db = await dbHelper.database;
    if (brand.id == null) {
      throw Exception('Brand ID cannot be null for update.');
    }
    // Check duplicate brand name excluding current id
    final existing = await db.query(
      'brands',
      where: 'LOWER(brand_name) = ? AND id != ?',
      whereArgs: [brand.brandName.trim().toLowerCase(), brand.id],
    );
    if (existing.isNotEmpty) {
      throw Exception('Duplicate Brand Name is not allowed.');
    }
    return await db.update(
      'brands',
      brand.toMap(),
      where: 'id = ?',
      whereArgs: [brand.id],
    );
  }

  Future<int> getProductCountForBrand(int brandId) async {
    final db = await dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM computers WHERE brand_id = ?',
      [brandId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<bool> deleteBrand(int id) async {
    final db = await dbHelper.database;
    // Check whether the brand is being used by any Computer
    final count = await getProductCountForBrand(id);
    if (count > 0) {
      throw Exception(
        'This brand cannot be deleted because it is currently used by one or more products.',
      );
    }
    final rowsDeleted = await db.delete(
      'brands',
      where: 'id = ?',
      whereArgs: [id],
    );
    return rowsDeleted > 0;
  }

  Future<Brand?> getBrandById(int id) async {
    final db = await dbHelper.database;
    final result = await db.rawQuery(
      '''
      SELECT
        b.id,
        b.brand_name,
        b.country,
        b.founded_year,
        COUNT(c.id) AS totalProducts
      FROM brands b
      LEFT JOIN computers c ON b.id = c.brand_id
      WHERE b.id = ?
      GROUP BY b.id
    ''',
      [id],
    );

    if (result.isNotEmpty) {
      return Brand.fromMap(result.first);
    }
    return null;
  }

  Future<List<Brand>> getAllBrands() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('''
      SELECT
        b.id,
        b.brand_name,
        b.country,
        b.founded_year,
        COUNT(c.id) AS totalProducts
      FROM brands b
      LEFT JOIN computers c ON b.id = c.brand_id
      GROUP BY b.id
      ORDER BY b.brand_name ASC
    ''');
    return result.map((map) => Brand.fromMap(map)).toList();
  }

  Future<List<Brand>> searchBrands(String keyword) async {
    final db = await dbHelper.database;
    final trimmed = keyword.trim();
    if (trimmed.isEmpty) {
      return getAllBrands();
    }
    final pattern = '%$trimmed%';
    final result = await db.rawQuery(
      '''
      SELECT
        b.id,
        b.brand_name,
        b.country,
        b.founded_year,
        COUNT(c.id) AS totalProducts
      FROM brands b
      LEFT JOIN computers c ON b.id = c.brand_id
      WHERE LOWER(b.brand_name) LIKE LOWER(?)
         OR LOWER(b.country) LIKE LOWER(?)
      GROUP BY b.id
      ORDER BY b.brand_name ASC
    ''',
      [pattern, pattern],
    );
    return result.map((map) => Brand.fromMap(map)).toList();
  }
}
