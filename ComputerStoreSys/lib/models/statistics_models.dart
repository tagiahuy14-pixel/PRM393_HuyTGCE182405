class GeneralStatistics {
  final int totalProducts;
  final double totalRevenue;
  final int totalSoldQuantity;
  final double averagePrice;
  final double totalInventoryValue;

  GeneralStatistics({
    required this.totalProducts,
    required this.totalRevenue,
    required this.totalSoldQuantity,
    required this.averagePrice,
    required this.totalInventoryValue,
  });

  factory GeneralStatistics.empty() {
    return GeneralStatistics(
      totalProducts: 0,
      totalRevenue: 0.0,
      totalSoldQuantity: 0,
      averagePrice: 0.0,
      totalInventoryValue: 0.0,
    );
  }
}

class BrandStatistic {
  final String brandName;
  final int totalProducts;
  final int totalSold;
  final double revenue;
  final double inventoryValue;

  BrandStatistic({
    required this.brandName,
    required this.totalProducts,
    required this.totalSold,
    required this.revenue,
    required this.inventoryValue,
  });

  factory BrandStatistic.fromMap(Map<String, dynamic> map) {
    return BrandStatistic(
      brandName: map['brand_name'] as String? ?? 'Unknown',
      totalProducts: (map['TotalProducts'] as num?)?.toInt() ?? 0,
      totalSold: (map['TotalSold'] as num?)?.toInt() ?? 0,
      revenue: (map['Revenue'] as num?)?.toDouble() ?? 0.0,
      inventoryValue: (map['InventoryValue'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class CategoryStatistic {
  final String categoryName;
  final int totalProducts;
  final double totalRevenue;
  final int totalSold;

  CategoryStatistic({
    required this.categoryName,
    required this.totalProducts,
    required this.totalRevenue,
    required this.totalSold,
  });

  factory CategoryStatistic.fromMap(Map<String, dynamic> map) {
    return CategoryStatistic(
      categoryName: map['category_name'] as String? ?? 'Unknown',
      totalProducts:
          (map['TotalProducts'] as num?)?.toInt() ??
          (map['total_products'] as num?)?.toInt() ??
          0,
      totalRevenue:
          (map['TotalRevenue'] as num?)?.toDouble() ??
          (map['total_revenue'] as num?)?.toDouble() ??
          0.0,
      totalSold:
          (map['TotalSold'] as num?)?.toInt() ??
          (map['total_sold'] as num?)?.toInt() ??
          0,
    );
  }
}

class FeaturedStatistics {
  final int totalFeaturedProducts;
  final double totalFeaturedRevenue;
  final int totalFeaturedSoldQuantity;

  FeaturedStatistics({
    required this.totalFeaturedProducts,
    required this.totalFeaturedRevenue,
    required this.totalFeaturedSoldQuantity,
  });

  factory FeaturedStatistics.empty() {
    return FeaturedStatistics(
      totalFeaturedProducts: 0,
      totalFeaturedRevenue: 0.0,
      totalFeaturedSoldQuantity: 0,
    );
  }
}

class TopBrand {
  final String brandName;
  final int totalSold;

  TopBrand({required this.brandName, required this.totalSold});
}

class BestSellingProduct {
  final String productName;
  final int soldQuantity;

  BestSellingProduct({required this.productName, required this.soldQuantity});
}

class MostExpensiveProduct {
  final String productName;
  final double price;

  MostExpensiveProduct({required this.productName, required this.price});
}

class LowStockProduct {
  final String productName;
  final String brandName;
  final int stock;

  LowStockProduct({
    required this.productName,
    required this.brandName,
    required this.stock,
  });

  factory LowStockProduct.fromMap(Map<String, dynamic> map) {
    return LowStockProduct(
      productName: map['product_name'] as String? ?? '',
      brandName: map['brand_name'] as String? ?? '',
      stock: (map['stock'] as num?)?.toInt() ?? 0,
    );
  }
}
