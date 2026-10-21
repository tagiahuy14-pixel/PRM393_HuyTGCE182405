import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../models/shopping_item.dart';
import '../utils/item_validation.dart';

class ShoppingDatabase {
  ShoppingDatabase({DatabaseFactory? factory, this._databasePath})
    : _factory = factory ?? databaseFactory;

  final DatabaseFactory _factory;
  final String? _databasePath;
  Future<Database>? _opening;

  Future<Database> get database async {
    try {
      return await (_opening ??= _open());
    } catch (_) {
      _opening = null; // A failed initialization can be retried from the UI.
      rethrow;
    }
  }

  Future<Database> _open() async {
    final file =
        _databasePath ??
        path.join(
          await _factory.getDatabasesPath(),
          'favorite_shopping_items.db',
        );
    return _factory.openDatabase(
      file,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE shopping_items (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              itemName TEXT NOT NULL CHECK(length(trim(itemName)) > 0),
              category TEXT NOT NULL CHECK(length(trim(category)) > 0),
              price REAL NOT NULL CHECK(price > 0 AND price <= 999999999999.99),
              status TEXT NOT NULL DEFAULT 'Wishlist'
                CHECK(status IN ('Wishlist', 'Purchased'))
            )
          ''');
          await db.execute(
            'CREATE INDEX shopping_items_status ON shopping_items(status)',
          );
        },
      ),
    );
  }

  Future<List<ShoppingItem>> getItems({String? status}) async {
    final db = await database;
    final rows = await db.query(
      'shopping_items',
      where: status == null ? null : 'status = ?',
      whereArgs: status == null ? null : [status],
      orderBy: 'id DESC',
    );
    return rows.map(ShoppingItem.fromMap).toList();
  }

  Future<ShoppingItem> insert(ShoppingItem item) async {
    if (item.id != null ||
        item.itemName.trim().isEmpty ||
        item.category.trim().isEmpty ||
        !item.price.isFinite ||
        item.price <= 0 ||
        item.price > ItemValidation.maxPrice ||
        !ShoppingItem.statuses.contains(item.status)) {
      throw ArgumentError('Invalid shopping item');
    }
    final db = await database;
    final id = await db.insert('shopping_items', item.toMap());
    return item.copyWith(id: id);
  }

  Future<void> updateStatus(int id, String status) async {
    if (!ShoppingItem.statuses.contains(status)) {
      throw ArgumentError.value(status, 'status');
    }
    final db = await database;
    final changed = await db.update(
      'shopping_items',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
    if (changed != 1) throw StateError('Item no longer exists');
  }

  Future<void> delete(int id) async {
    final db = await database;
    final changed = await db.delete(
      'shopping_items',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (changed != 1) throw StateError('Item no longer exists');
  }

  Future<void> close() async {
    final opening = _opening;
    _opening = null;
    if (opening != null) await (await opening).close();
  }
}
