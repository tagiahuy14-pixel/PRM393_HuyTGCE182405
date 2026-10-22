import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:computer_store_sys/models/brand.dart';
import 'package:computer_store_sys/models/category.dart';
import 'package:computer_store_sys/models/computer.dart';
import 'package:computer_store_sys/database/database_helper.dart';
import 'package:computer_store_sys/services/brand_repository.dart';
import 'package:computer_store_sys/services/category_repository.dart';
import 'package:computer_store_sys/services/computer_repository.dart';
import 'package:computer_store_sys/services/statistics_repository.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Model Unit Tests', () {
    test('Brand model toMap and fromMap', () {
      final brand = Brand(
        id: 1,
        brandName: 'ASUS',
        country: 'Taiwan',
        foundedYear: 1989,
        productCount: 5,
      );

      final map = brand.toMap();
      expect(map['brand_name'], 'ASUS');
      expect(map['country'], 'Taiwan');
      expect(map['founded_year'], 1989);

      final fromMap = Brand.fromMap({
        'id': 1,
        'brand_name': 'ASUS',
        'country': 'Taiwan',
        'founded_year': 1989,
        'totalProducts': 5,
      });

      expect(fromMap.id, 1);
      expect(fromMap.brandName, 'ASUS');
      expect(fromMap.country, 'Taiwan');
      expect(fromMap.foundedYear, 1989);
      expect(fromMap.productCount, 5);
    });

    test('Category model toMap and fromMap', () {
      final category = Category(id: 1, categoryName: 'Laptop', productCount: 8);
      final map = category.toMap();
      expect(map['category_name'], 'Laptop');

      final fromMap = Category.fromMap({
        'id': 1,
        'category_name': 'Laptop',
        'totalProducts': 8,
      });
      expect(fromMap.id, 1);
      expect(fromMap.categoryName, 'Laptop');
      expect(fromMap.productCount, 8);
    });

    test('Computer business calculations (Page 11-12 of Lab3.pdf)', () {
      final computer = Computer(
        id: 1,
        productName: 'ROG Strix G16',
        brandId: 1,
        categoryId: 1,
        cpu: 'Intel Core i7',
        ram: 16,
        storage: 1000,
        price: 1250.0,
        stock: 15,
        soldQuantity: 32,
        isFeatured: 1,
      );

      // Revenue = Price × Sold Quantity
      expect(computer.revenue, 1250.0 * 32); // 40000.0
      // Inventory Value = Price × Stock
      expect(computer.inventoryValue, 1250.0 * 15); // 18750.0
      // Total Units = Stock + Sold Quantity
      expect(computer.totalUnits, 15 + 32); // 47
      // isFeaturedBool
      expect(computer.isFeaturedBool, isTrue);
    });
  });

  group('Database & Repositories Integration Tests', () {
    late DatabaseHelper dbHelper;
    late BrandRepository brandRepo;
    late CategoryRepository categoryRepo;
    late ComputerRepository computerRepo;
    late StatisticsRepository statsRepo;

    setUp(() async {
      dbHelper = DatabaseHelper.instance;
      // Ensure database is ready
      await dbHelper.database;
      brandRepo = BrandRepository(helper: dbHelper);
      categoryRepo = CategoryRepository(helper: dbHelper);
      computerRepo = ComputerRepository(helper: dbHelper);
      statsRepo = StatisticsRepository(helper: dbHelper);
    });

    test('Task 1: Seed data initialization check', () async {
      final brands = await brandRepo.getAllBrands();
      final categories = await categoryRepo.getAllCategories();
      final computers = await computerRepo.getAllComputers();

      // Minimum requirements: 5 Brands, 3 Categories, 15 Computers
      expect(brands.length, greaterThanOrEqualTo(5));
      expect(categories.length, equals(3));
      expect(computers.length, greaterThanOrEqualTo(15));
    });

    test('Task 2: Brand CRUD, Duplicate Name, and Delete Check', () async {
      // 1. Cannot delete brand currently used by computers
      final asus = (await brandRepo.getAllBrands()).firstWhere(
        (b) => b.brandName == 'ASUS',
      );
      expect(
        () async => await brandRepo.deleteBrand(asus.id!),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains(
              'This brand cannot be deleted because it is currently used by one or more products.',
            ),
          ),
        ),
      );

      // 2. Add new Brand
      final newBrand = Brand(
        brandName: 'Razer Test',
        country: 'United States',
        foundedYear: 2005,
      );
      final newId = await brandRepo.insertBrand(newBrand);
      expect(newId, isPositive);

      // 3. Duplicate brand name throws
      expect(
        () async => await brandRepo.insertBrand(
          Brand(brandName: 'razer test', country: 'USA', foundedYear: 2005),
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Duplicate Brand Name is not allowed.'),
          ),
        ),
      );

      // 4. Update brand
      await brandRepo.updateBrand(
        Brand(
          id: newId,
          brandName: 'Razer Inc',
          country: 'Singapore',
          foundedYear: 2005,
        ),
      );
      final updated = await brandRepo.getBrandById(newId);
      expect(updated?.brandName, 'Razer Inc');
      expect(updated?.country, 'Singapore');

      // 5. Delete unused brand succeeds
      final deleted = await brandRepo.deleteBrand(newId);
      expect(deleted, isTrue);
    });

    test('Task 3: Category CRUD, Duplicate Name, and Delete Check', () async {
      // 1. Cannot delete category in use
      final laptopCat = (await categoryRepo.getAllCategories()).firstWhere(
        (c) => c.categoryName == 'Laptop',
      );
      expect(
        () async => await categoryRepo.deleteCategory(laptopCat.id!),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains(
              'This category cannot be deleted because one or more products belong to this category.',
            ),
          ),
        ),
      );

      // 2. Add new Category
      final newCat = Category(categoryName: 'Accessory Test');
      final newId = await categoryRepo.insertCategory(newCat);
      expect(newId, isPositive);

      // 3. Duplicate category name throws
      expect(
        () async => await categoryRepo.insertCategory(
          Category(categoryName: 'accessory test'),
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Category Name must be unique.'),
          ),
        ),
      );

      // 4. Delete unused category succeeds
      final deleted = await categoryRepo.deleteCategory(newId);
      expect(deleted, isTrue);
    });

    test('Task 4: Computer CRUD, joins, and validations', () async {
      final brands = await brandRepo.getAllBrands();
      final categories = await categoryRepo.getAllCategories();

      // 1. Insert computer
      final testComputer = Computer(
        productName: 'Unique Super Machine X1',
        brandId: brands.first.id!,
        categoryId: categories.first.id!,
        cpu: 'Intel Core i9-14900HX',
        ram: 64,
        storage: 2048,
        price: 2999.0,
        stock: 10,
        soldQuantity: 5,
        isFeatured: 1,
      );

      final compId = await computerRepo.insertComputer(testComputer);
      expect(compId, isPositive);

      // 2. Read with joins
      final fetched = await computerRepo.getComputerById(compId);
      expect(fetched, isNotNull);
      expect(fetched?.productName, 'Unique Super Machine X1');
      expect(fetched?.brandName, isNotEmpty);
      expect(fetched?.categoryName, isNotEmpty);
      expect(fetched?.revenue, 2999.0 * 5);

      // 3. Update
      final updatedComp = fetched!.copyWith(price: 2899.0, stock: 9);
      await computerRepo.updateComputer(updatedComp);
      final refreshed = await computerRepo.getComputerById(compId);
      expect(refreshed?.price, 2899.0);
      expect(refreshed?.stock, 9);

      // 4. Delete
      final deletedCount = await computerRepo.deleteComputer(compId);
      expect(deletedCount, equals(1));
    });

    test('Task 5: Search, Filter, Sort, and Reset', () async {
      // 1. Search by Keyword (Product Name, Brand, CPU)
      final searchAsus = await computerRepo.searchComputers('ASUS');
      expect(
        searchAsus.every(
          (c) =>
              c.productName.toUpperCase().contains('ASUS') ||
              (c.brandName?.toUpperCase().contains('ASUS') ?? false) ||
              c.cpu.toUpperCase().contains('ASUS'),
        ),
        isTrue,
      );

      // 2. Filter by Featured
      final featuredOnly = await computerRepo.filterComputers(
        const ComputerFilterCriteria(featuredOnly: true),
      );
      expect(featuredOnly.every((c) => c.isFeatured == 1), isTrue);

      // 3. Filter by Price under 500
      final under500 = await computerRepo.filterComputers(
        const ComputerFilterCriteria(priceFilter: PriceFilter.under500),
      );
      expect(under500.every((c) => c.price < 500), isTrue);

      // 4. Sort by Price Ascending
      final sortedByPrice = await computerRepo.sortComputers(
        SortOption.priceAsc,
      );
      for (int i = 0; i < sortedByPrice.length - 1; i++) {
        expect(
          sortedByPrice[i].price,
          lessThanOrEqualTo(sortedByPrice[i + 1].price),
        );
      }

      // 5. Reset Filters
      final allComputers = await computerRepo.resetFilters();
      expect(allComputers.length, greaterThanOrEqualTo(15));
    });

    test('Task 6: Statistics SQL aggregate calculations', () async {
      final general = await statsRepo.getStatistics();
      expect(general.totalProducts, greaterThanOrEqualTo(15));
      expect(general.totalRevenue, greaterThan(0));
      expect(general.totalSoldQuantity, greaterThan(0));
      expect(general.averagePrice, greaterThan(0));
      expect(general.totalInventoryValue, greaterThan(0));

      final brandStats = await statsRepo.getBrandStatistics();
      expect(brandStats.isNotEmpty, isTrue);

      final categoryStats = await statsRepo.getCategoryStatistics();
      expect(categoryStats.isNotEmpty, isTrue);

      final bestSelling = await statsRepo.getBestSellingProduct();
      expect(bestSelling, isNotNull);
      expect(bestSelling!.soldQuantity, greaterThan(0));

      final mostExpensive = await statsRepo.getMostExpensiveProduct();
      expect(mostExpensive, isNotNull);
      expect(mostExpensive!.price, greaterThan(0));

      final lowStock = await statsRepo.getLowStockProducts();
      expect(lowStock.every((p) => p.stock < 5), isTrue);

      final topBrand = await statsRepo.getTopBrand();
      expect(topBrand, isNotNull);
      expect(topBrand!.totalSold, greaterThan(0));

      final featStats = await statsRepo.getFeaturedStatistics();
      expect(featStats.totalFeaturedProducts, greaterThan(0));
    });
  });
}
