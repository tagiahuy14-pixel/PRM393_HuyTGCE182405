import '../database/database_helper.dart';
import '../models/statistics_models.dart';

class StatisticsRepository {
  final DatabaseHelper dbHelper;

  StatisticsRepository({DatabaseHelper? helper})
    : dbHelper = helper ?? DatabaseHelper.instance;

  // 6.1 General Statistics
  Future<GeneralStatistics> getStatistics() async {
    final db = await dbHelper.database;

    final prodCountResult = await db.rawQuery(
      'SELECT COUNT(*) as total FROM computers;',
    );
    final totalProducts =
        (prodCountResult.first['total'] as num?)?.toInt() ?? 0;

    final revenueResult = await db.rawQuery(
      'SELECT COALESCE(SUM(price * sold_quantity), 0) as total FROM computers;',
    );
    final totalRevenue =
        (revenueResult.first['total'] as num?)?.toDouble() ?? 0.0;

    final soldResult = await db.rawQuery(
      'SELECT COALESCE(SUM(sold_quantity), 0) as total FROM computers;',
    );
    final totalSoldQuantity = (soldResult.first['total'] as num?)?.toInt() ?? 0;

    final avgPriceResult = await db.rawQuery(
      'SELECT COALESCE(AVG(price), 0) as avg FROM computers;',
    );
    final averagePrice =
        (avgPriceResult.first['avg'] as num?)?.toDouble() ?? 0.0;

    final invResult = await db.rawQuery(
      'SELECT COALESCE(SUM(price * stock), 0) as total FROM computers;',
    );
    final totalInventoryValue =
        (invResult.first['total'] as num?)?.toDouble() ?? 0.0;

    return GeneralStatistics(
      totalProducts: totalProducts,
      totalRevenue: totalRevenue,
      totalSoldQuantity: totalSoldQuantity,
      averagePrice: averagePrice,
      totalInventoryValue: totalInventoryValue,
    );
  }

  // 6.2 Statistics by Brand
  Future<List<BrandStatistic>> getBrandStatistics() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('''
      SELECT
        b.brand_name,
        COUNT(c.id) AS TotalProducts,
        COALESCE(SUM(c.sold_quantity), 0) AS TotalSold,
        COALESCE(SUM(c.price * c.sold_quantity), 0) AS Revenue,
        COALESCE(SUM(c.price * c.stock), 0) AS InventoryValue
      FROM brands b
      LEFT JOIN computers c ON b.id = c.brand_id
      GROUP BY b.id
      ORDER BY Revenue DESC;
    ''');

    return result.map((m) => BrandStatistic.fromMap(m)).toList();
  }

  // 6.3 Statistics by Category
  Future<List<CategoryStatistic>> getCategoryStatistics() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('''
      SELECT
        ca.category_name,
        COUNT(c.id) AS TotalProducts,
        COALESCE(SUM(c.price * c.sold_quantity), 0) AS TotalRevenue,
        COALESCE(SUM(c.sold_quantity), 0) AS TotalSold
      FROM categories ca
      LEFT JOIN computers c ON ca.id = c.category_id
      GROUP BY ca.id;
    ''');

    return result.map((m) => CategoryStatistic.fromMap(m)).toList();
  }

  // 6.4 Best Selling Product
  Future<BestSellingProduct?> getBestSellingProduct() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('''
      SELECT product_name, sold_quantity
      FROM computers
      ORDER BY sold_quantity DESC
      LIMIT 1;
    ''');

    if (result.isNotEmpty) {
      return BestSellingProduct(
        productName: result.first['product_name'] as String? ?? 'N/A',
        soldQuantity: (result.first['sold_quantity'] as num?)?.toInt() ?? 0,
      );
    }
    return null;
  }

  // 6.5 Most Expensive Product
  Future<MostExpensiveProduct?> getMostExpensiveProduct() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('''
      SELECT product_name, price
      FROM computers
      ORDER BY price DESC
      LIMIT 1;
    ''');

    if (result.isNotEmpty) {
      return MostExpensiveProduct(
        productName: result.first['product_name'] as String? ?? 'N/A',
        price: (result.first['price'] as num?)?.toDouble() ?? 0.0,
      );
    }
    return null;
  }

  // 6.6 Low Stock Products (stock < 5)
  Future<List<LowStockProduct>> getLowStockProducts() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('''
      SELECT
        c.product_name,
        b.brand_name,
        c.stock
      FROM computers c
      INNER JOIN brands b ON c.brand_id = b.id
      WHERE c.stock < 5;
    ''');

    return result.map((m) => LowStockProduct.fromMap(m)).toList();
  }

  // 6.7 Top Brand
  Future<TopBrand?> getTopBrand() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('''
      SELECT
        b.brand_name,
        COALESCE(SUM(c.sold_quantity), 0) AS TotalSold
      FROM brands b
      INNER JOIN computers c ON b.id = c.brand_id
      GROUP BY b.id
      ORDER BY TotalSold DESC
      LIMIT 1;
    ''');

    if (result.isNotEmpty) {
      return TopBrand(
        brandName: result.first['brand_name'] as String? ?? 'N/A',
        totalSold: (result.first['TotalSold'] as num?)?.toInt() ?? 0,
      );
    }
    return null;
  }

  // 6.8 Featured Statistics
  Future<FeaturedStatistics> getFeaturedStatistics() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('''
      SELECT
        COUNT(*) AS total_featured,
        COALESCE(SUM(price * sold_quantity), 0) AS featured_revenue,
        COALESCE(SUM(sold_quantity), 0) AS featured_sold
      FROM computers
      WHERE is_featured = 1;
    ''');

    if (result.isNotEmpty) {
      final row = result.first;
      return FeaturedStatistics(
        totalFeaturedProducts: (row['total_featured'] as num?)?.toInt() ?? 0,
        totalFeaturedRevenue:
            (row['featured_revenue'] as num?)?.toDouble() ?? 0.0,
        totalFeaturedSoldQuantity: (row['featured_sold'] as num?)?.toInt() ?? 0,
      );
    }
    return FeaturedStatistics.empty();
  }
}
