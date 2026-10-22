class Category {
  final int? id;
  final String categoryName;
  final int productCount;

  Category({this.id, required this.categoryName, this.productCount = 0});

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{'category_name': categoryName};
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      categoryName: map['category_name'] as String? ?? '',
      productCount:
          (map['totalProducts'] as num?)?.toInt() ??
          (map['product_count'] as num?)?.toInt() ??
          0,
    );
  }

  Category copyWith({int? id, String? categoryName, int? productCount}) {
    return Category(
      id: id ?? this.id,
      categoryName: categoryName ?? this.categoryName,
      productCount: productCount ?? this.productCount,
    );
  }

  @override
  String toString() {
    return 'Category(id: $id, categoryName: $categoryName, productCount: $productCount)';
  }
}
