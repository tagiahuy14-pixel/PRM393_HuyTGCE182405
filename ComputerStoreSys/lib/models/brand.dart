class Brand {
  final int? id;
  final String brandName;
  final String country;
  final int foundedYear;
  final int productCount;

  Brand({
    this.id,
    required this.brandName,
    required this.country,
    required this.foundedYear,
    this.productCount = 0,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'brand_name': brandName,
      'country': country,
      'founded_year': foundedYear,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory Brand.fromMap(Map<String, dynamic> map) {
    return Brand(
      id: map['id'] as int?,
      brandName: map['brand_name'] as String? ?? '',
      country: map['country'] as String? ?? '',
      foundedYear: map['founded_year'] as int? ?? 0,
      productCount:
          (map['totalProducts'] as num?)?.toInt() ??
          (map['product_count'] as num?)?.toInt() ??
          0,
    );
  }

  Brand copyWith({
    int? id,
    String? brandName,
    String? country,
    int? foundedYear,
    int? productCount,
  }) {
    return Brand(
      id: id ?? this.id,
      brandName: brandName ?? this.brandName,
      country: country ?? this.country,
      foundedYear: foundedYear ?? this.foundedYear,
      productCount: productCount ?? this.productCount,
    );
  }

  @override
  String toString() {
    return 'Brand(id: $id, brandName: $brandName, country: $country, foundedYear: $foundedYear, productCount: $productCount)';
  }
}
