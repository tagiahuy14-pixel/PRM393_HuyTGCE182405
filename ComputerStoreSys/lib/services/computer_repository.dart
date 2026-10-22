import '../database/database_helper.dart';
import '../models/computer.dart';

enum StockFilter { all, inStock, lowStock, outOfStock }

enum RamFilter { all, ram8, ram16, ram32Plus }

enum StorageFilter { all, storage256, storage512, storage1TB, storage2TBPlus }

enum PriceFilter { all, under500, between500And1000, over1000 }

enum SortOption {
  nameAsc,
  nameDesc,
  priceAsc,
  priceDesc,
  soldAsc,
  soldDesc,
  brandAsc,
  brandDesc,
  stockAsc,
  stockDesc,
}

class ComputerFilterCriteria {
  final String? keyword;
  final int? brandId;
  final int? categoryId;
  final bool featuredOnly;
  final StockFilter stockFilter;
  final RamFilter ramFilter;
  final StorageFilter storageFilter;
  final PriceFilter priceFilter;
  final SortOption sortOption;

  const ComputerFilterCriteria({
    this.keyword,
    this.brandId,
    this.categoryId,
    this.featuredOnly = false,
    this.stockFilter = StockFilter.all,
    this.ramFilter = RamFilter.all,
    this.storageFilter = StorageFilter.all,
    this.priceFilter = PriceFilter.all,
    this.sortOption = SortOption.nameAsc,
  });

  ComputerFilterCriteria copyWith({
    String? keyword,
    int? brandId,
    int? categoryId,
    bool? featuredOnly,
    StockFilter? stockFilter,
    RamFilter? ramFilter,
    StorageFilter? storageFilter,
    PriceFilter? priceFilter,
    SortOption? sortOption,
    bool clearBrand = false,
    bool clearCategory = false,
  }) {
    return ComputerFilterCriteria(
      keyword: keyword ?? this.keyword,
      brandId: clearBrand ? null : (brandId ?? this.brandId),
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      featuredOnly: featuredOnly ?? this.featuredOnly,
      stockFilter: stockFilter ?? this.stockFilter,
      ramFilter: ramFilter ?? this.ramFilter,
      storageFilter: storageFilter ?? this.storageFilter,
      priceFilter: priceFilter ?? this.priceFilter,
      sortOption: sortOption ?? this.sortOption,
    );
  }

  static const defaultCriteria = ComputerFilterCriteria();
}

class ComputerRepository {
  final DatabaseHelper dbHelper;

  ComputerRepository({DatabaseHelper? helper})
    : dbHelper = helper ?? DatabaseHelper.instance;

  Future<int> insertComputer(Computer computer) async {
    final db = await dbHelper.database;

    // Validation
    final name = computer.productName.trim();
    if (name.isEmpty) throw Exception('Product Name is required.');
    if (computer.cpu.trim().isEmpty) throw Exception('CPU is required.');
    if (computer.ram < 4 || computer.ram > 128) {
      throw Exception('RAM must be between 4 and 128 GB.');
    }
    if (computer.storage < 128 || computer.storage > 4096) {
      throw Exception('Storage must be between 128 and 4096 GB.');
    }
    if (computer.price <= 0) {
      throw Exception('Price must be greater than 0.');
    }
    if (computer.stock < 0) {
      throw Exception('Stock must be >= 0.');
    }
    if (computer.soldQuantity < 0) {
      throw Exception('Sold Quantity must be >= 0.');
    }

    // Check duplicate product name
    final existing = await db.query(
      'computers',
      where: 'LOWER(product_name) = ?',
      whereArgs: [name.toLowerCase()],
    );
    if (existing.isNotEmpty) {
      throw Exception('Product Name must be unique.');
    }

    return await db.insert('computers', computer.toMap());
  }

  Future<int> updateComputer(Computer computer) async {
    final db = await dbHelper.database;
    if (computer.id == null) {
      throw Exception('Computer ID cannot be null for update.');
    }

    final name = computer.productName.trim();
    if (name.isEmpty) throw Exception('Product Name is required.');
    if (computer.cpu.trim().isEmpty) throw Exception('CPU is required.');
    if (computer.ram < 4 || computer.ram > 128) {
      throw Exception('RAM must be between 4 and 128 GB.');
    }
    if (computer.storage < 128 || computer.storage > 4096) {
      throw Exception('Storage must be between 128 and 4096 GB.');
    }
    if (computer.price <= 0) {
      throw Exception('Price must be greater than 0.');
    }
    if (computer.stock < 0) {
      throw Exception('Stock must be >= 0.');
    }
    if (computer.soldQuantity < 0) {
      throw Exception('Sold Quantity must be >= 0.');
    }

    // Check duplicate product name excluding current ID
    final existing = await db.query(
      'computers',
      where: 'LOWER(product_name) = ? AND id != ?',
      whereArgs: [name.toLowerCase(), computer.id],
    );
    if (existing.isNotEmpty) {
      throw Exception('Product Name must be unique.');
    }

    return await db.update(
      'computers',
      computer.toMap(),
      where: 'id = ?',
      whereArgs: [computer.id],
    );
  }

  Future<int> deleteComputer(int id) async {
    final db = await dbHelper.database;
    return await db.delete('computers', where: 'id = ?', whereArgs: [id]);
  }

  Future<Computer?> getComputerById(int id) async {
    final db = await dbHelper.database;
    final result = await db.rawQuery(
      '''
      SELECT
        c.*,
        b.brand_name,
        ca.category_name
      FROM computers c
      INNER JOIN brands b ON c.brand_id = b.id
      INNER JOIN categories ca ON c.category_id = ca.id
      WHERE c.id = ?
    ''',
      [id],
    );

    if (result.isNotEmpty) {
      return Computer.fromMap(result.first);
    }
    return null;
  }

  Future<List<Computer>> getAllComputers() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('''
      SELECT
        c.id,
        c.product_name,
        b.brand_name,
        ca.category_name,
        c.brand_id,
        c.category_id,
        c.cpu,
        c.ram,
        c.storage,
        c.price,
        c.stock,
        c.sold_quantity,
        c.is_featured
      FROM computers c
      INNER JOIN brands b ON c.brand_id = b.id
      INNER JOIN categories ca ON c.category_id = ca.id
      ORDER BY c.product_name ASC;
    ''');

    return result.map((map) => Computer.fromMap(map)).toList();
  }

  Future<List<Computer>> getFeaturedComputers() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('''
      SELECT
        c.id,
        c.product_name,
        b.brand_name,
        ca.category_name,
        c.brand_id,
        c.category_id,
        c.cpu,
        c.ram,
        c.storage,
        c.price,
        c.stock,
        c.sold_quantity,
        c.is_featured
      FROM computers c
      INNER JOIN brands b ON c.brand_id = b.id
      INNER JOIN categories ca ON c.category_id = ca.id
      WHERE c.is_featured = 1
      ORDER BY c.product_name ASC;
    ''');

    return result.map((map) => Computer.fromMap(map)).toList();
  }

  // Unified Query Builder for Search, Filter, and Sort (Task 5)
  Future<List<Computer>> queryComputers(ComputerFilterCriteria criteria) async {
    final db = await dbHelper.database;

    final whereClauses = <String>[];
    final whereArgs = <dynamic>[];

    // 1. Search keyword (Product Name, Brand Name, CPU)
    if (criteria.keyword != null && criteria.keyword!.trim().isNotEmpty) {
      final term = '%${criteria.keyword!.trim()}%';
      whereClauses.add('''
        (c.product_name LIKE ? OR b.brand_name LIKE ? OR c.cpu LIKE ?)
      ''');
      whereArgs.add(term);
      whereArgs.add(term);
      whereArgs.add(term);
    }

    // 2. Filter by Brand
    if (criteria.brandId != null) {
      whereClauses.add('b.id = ?');
      whereArgs.add(criteria.brandId);
    }

    // 3. Filter by Category
    if (criteria.categoryId != null) {
      whereClauses.add('ca.id = ?');
      whereArgs.add(criteria.categoryId);
    }

    // 4. Filter by Featured
    if (criteria.featuredOnly) {
      whereClauses.add('c.is_featured = 1');
    }

    // 5. Filter by Stock Status
    switch (criteria.stockFilter) {
      case StockFilter.inStock:
        whereClauses.add('c.stock > 0');
        break;
      case StockFilter.lowStock:
        whereClauses.add('c.stock < 5');
        break;
      case StockFilter.outOfStock:
        whereClauses.add('c.stock = 0');
        break;
      case StockFilter.all:
        break;
    }

    // 6. Filter by RAM
    switch (criteria.ramFilter) {
      case RamFilter.ram8:
        whereClauses.add('c.ram = 8');
        break;
      case RamFilter.ram16:
        whereClauses.add('c.ram = 16');
        break;
      case RamFilter.ram32Plus:
        whereClauses.add('c.ram >= 32');
        break;
      case RamFilter.all:
        break;
    }

    // 7. Filter by Storage
    switch (criteria.storageFilter) {
      case StorageFilter.storage256:
        whereClauses.add('c.storage = 256');
        break;
      case StorageFilter.storage512:
        whereClauses.add('c.storage = 512');
        break;
      case StorageFilter.storage1TB:
        whereClauses.add('(c.storage = 1000 OR c.storage = 1024)');
        break;
      case StorageFilter.storage2TBPlus:
        whereClauses.add('c.storage >= 2000');
        break;
      case StorageFilter.all:
        break;
    }

    // 8. Filter by Price
    switch (criteria.priceFilter) {
      case PriceFilter.under500:
        whereClauses.add('c.price < 500');
        break;
      case PriceFilter.between500And1000:
        whereClauses.add('c.price BETWEEN 500 AND 1000');
        break;
      case PriceFilter.over1000:
        whereClauses.add('c.price > 1000');
        break;
      case PriceFilter.all:
        break;
    }

    // Build WHERE statement
    String whereString = '';
    if (whereClauses.isNotEmpty) {
      whereString = 'WHERE ${whereClauses.join(' AND ')}';
    }

    // Whitelisted Order By
    String orderByClause;
    switch (criteria.sortOption) {
      case SortOption.priceAsc:
        orderByClause = 'ORDER BY c.price ASC';
        break;
      case SortOption.priceDesc:
        orderByClause = 'ORDER BY c.price DESC';
        break;
      case SortOption.soldAsc:
        orderByClause = 'ORDER BY c.sold_quantity ASC';
        break;
      case SortOption.soldDesc:
        orderByClause = 'ORDER BY c.sold_quantity DESC';
        break;
      case SortOption.nameAsc:
        orderByClause = 'ORDER BY c.product_name ASC';
        break;
      case SortOption.nameDesc:
        orderByClause = 'ORDER BY c.product_name DESC';
        break;
      case SortOption.brandAsc:
        orderByClause = 'ORDER BY b.brand_name ASC';
        break;
      case SortOption.brandDesc:
        orderByClause = 'ORDER BY b.brand_name DESC';
        break;
      case SortOption.stockAsc:
        orderByClause = 'ORDER BY c.stock ASC';
        break;
      case SortOption.stockDesc:
        orderByClause = 'ORDER BY c.stock DESC';
        break;
    }

    final query =
        '''
      SELECT
        c.id,
        c.product_name,
        b.brand_name,
        ca.category_name,
        c.brand_id,
        c.category_id,
        c.cpu,
        c.ram,
        c.storage,
        c.price,
        c.stock,
        c.sold_quantity,
        c.is_featured
      FROM computers c
      INNER JOIN brands b ON c.brand_id = b.id
      INNER JOIN categories ca ON c.category_id = ca.id
      $whereString
      $orderByClause;
    ''';

    final result = await db.rawQuery(query, whereArgs);
    return result.map((map) => Computer.fromMap(map)).toList();
  }

  // Wrapper methods for Task 5.8
  Future<List<Computer>> searchComputers(String keyword) {
    return queryComputers(ComputerFilterCriteria(keyword: keyword));
  }

  Future<List<Computer>> filterComputers(ComputerFilterCriteria criteria) {
    return queryComputers(criteria);
  }

  Future<List<Computer>> sortComputers(SortOption sortOption) {
    return queryComputers(ComputerFilterCriteria(sortOption: sortOption));
  }

  Future<List<Computer>> resetFilters() {
    return getAllComputers();
  }
}
