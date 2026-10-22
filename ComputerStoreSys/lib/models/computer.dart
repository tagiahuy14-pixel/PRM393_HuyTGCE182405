class Computer {
  final int? id;
  final String productName;
  final int brandId;
  final int categoryId;
  final String cpu;
  final int ram; // GB (4 - 128)
  final int storage; // GB (128 - 4096)
  final double price; // > 0
  final int stock; // >= 0
  final int soldQuantity; // >= 0
  final int isFeatured; // 0 or 1

  // Joined fields from brands and categories tables
  final String? brandName;
  final String? categoryName;

  Computer({
    this.id,
    required this.productName,
    required this.brandId,
    required this.categoryId,
    required this.cpu,
    required this.ram,
    required this.storage,
    required this.price,
    required this.stock,
    required this.soldQuantity,
    this.isFeatured = 0,
    this.brandName,
    this.categoryName,
  });

  // Business calculations (calculated in Flutter, not stored in DB)
  double get revenue => price * soldQuantity;
  double get inventoryValue => price * stock;
  int get totalUnits => stock + soldQuantity;
  bool get isFeaturedBool => isFeatured == 1;

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'product_name': productName,
      'brand_id': brandId,
      'category_id': categoryId,
      'cpu': cpu,
      'ram': ram,
      'storage': storage,
      'price': price,
      'stock': stock,
      'sold_quantity': soldQuantity,
      'is_featured': isFeatured,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory Computer.fromMap(Map<String, dynamic> map) {
    return Computer(
      id: map['id'] as int?,
      productName: map['product_name'] as String? ?? '',
      brandId: (map['brand_id'] as num?)?.toInt() ?? 0,
      categoryId: (map['category_id'] as num?)?.toInt() ?? 0,
      cpu: map['cpu'] as String? ?? '',
      ram: (map['ram'] as num?)?.toInt() ?? 0,
      storage: (map['storage'] as num?)?.toInt() ?? 0,
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      stock: (map['stock'] as num?)?.toInt() ?? 0,
      soldQuantity: (map['sold_quantity'] as num?)?.toInt() ?? 0,
      isFeatured: (map['is_featured'] as num?)?.toInt() ?? 0,
      brandName: map['brand_name'] as String?,
      categoryName: map['category_name'] as String?,
    );
  }

  Computer copyWith({
    int? id,
    String? productName,
    int? brandId,
    int? categoryId,
    String? cpu,
    int? ram,
    int? storage,
    double? price,
    int? stock,
    int? soldQuantity,
    int? isFeatured,
    String? brandName,
    String? categoryName,
  }) {
    return Computer(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      brandId: brandId ?? this.brandId,
      categoryId: categoryId ?? this.categoryId,
      cpu: cpu ?? this.cpu,
      ram: ram ?? this.ram,
      storage: storage ?? this.storage,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      soldQuantity: soldQuantity ?? this.soldQuantity,
      isFeatured: isFeatured ?? this.isFeatured,
      brandName: brandName ?? this.brandName,
      categoryName: categoryName ?? this.categoryName,
    );
  }

  @override
  String toString() {
    return 'Computer(id: $id, productName: $productName, brand: $brandName ($brandId), category: $categoryName ($categoryId), cpu: $cpu, ram: $ram, storage: $storage, price: $price, stock: $stock, soldQuantity: $soldQuantity, isFeatured: $isFeatured)';
  }
}
