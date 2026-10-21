import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lab5/models/shopping_item.dart';
import 'package:lab5/services/shopping_database.dart';
import 'package:lab5/services/shopping_store.dart';
import 'package:lab5/utils/currency.dart';
import 'package:lab5/utils/item_validation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  late Directory directory;
  late ShoppingDatabase database;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('lab5_sqlite_');
    database = ShoppingDatabase(
      factory: databaseFactoryFfi,
      databasePath: '${directory.path}/shopping.db',
    );
  });

  tearDown(() async {
    await database.close();
    await directory.delete(recursive: true);
  });

  test(
    'SQLite CRUD, generated IDs, status filters, and persistence on reopening',
    () async {
      expect(await database.getItems(), isEmpty);
      final first = await database.insert(
        const ShoppingItem(
          itemName: 'Nike Air Force 1',
          category: 'Fashion',
          price: 2500000.50,
        ),
      );
      final second = await database.insert(
        const ShoppingItem(
          itemName: 'AirPods Pro 2',
          category: 'Electronics',
          price: 5600000,
        ),
      );
      expect(first.id, isPositive);
      expect(second.id, greaterThan(first.id!));
      expect((await database.getItems()).length, 2);
      await database.updateStatus(first.id!, ShoppingItem.purchased);
      expect(
        (await database.getItems(status: ShoppingItem.wishlist)).single.id,
        second.id,
      );
      await database.close();
      final reopened = await database.getItems();
      expect(reopened.length, 2);
      expect(
        reopened.firstWhere((item) => item.id == first.id).price,
        2500000.50,
      );
      expect(
        reopened.firstWhere((item) => item.id == first.id).status,
        ShoppingItem.purchased,
      );
      await database.updateStatus(first.id!, ShoppingItem.wishlist);
      expect(
        (await database.getItems(status: ShoppingItem.wishlist)).length,
        2,
      );
      await database.delete(first.id!);
      await database.close();
      expect((await database.getItems()).single.id, second.id);
      final third = await database.insert(
        const ShoppingItem(itemName: 'Desk', category: 'Home', price: 100),
      );
      expect(third.id, greaterThan(second.id!));
    },
  );

  test(
    'store synchronizes CRUD, toggles both ways, totals, and reload',
    () async {
      final store = ShoppingStore(database);
      addTearDown(store.dispose);
      await store.load();
      final first = await store.add(
        const ShoppingItem(itemName: 'A', category: 'Home', price: 0.10),
      );
      await store.add(
        const ShoppingItem(itemName: 'B', category: 'Home', price: 0.20),
      );
      await store.add(
        const ShoppingItem(
          itemName: 'C',
          category: 'Home',
          price: 900,
          status: ShoppingItem.purchased,
        ),
      );
      expect(store.wishlist.length, 2);
      expect(store.wishlistTotal, 0.30);
      expect((await store.toggle(first.id!)).status, ShoppingItem.purchased);
      expect(store.wishlistTotal, 0.20);
      expect((await store.toggle(first.id!)).status, ShoppingItem.wishlist);
      expect(store.wishlistTotal, 0.30);
      await store.delete(first.id!);
      await store.load();
      expect(store.items.length, 2);
      expect(store.wishlist.single.itemName, 'B');
      expect(store.wishlistTotal, 0.20);
      await store.delete(store.wishlist.single.id!);
      expect(store.wishlist, isEmpty);
      expect(store.wishlistTotal, 0);
    },
  );

  test('database rejects invalid values and missing records', () async {
    for (final item in [
      const ShoppingItem(itemName: '', category: 'Home', price: 1),
      const ShoppingItem(itemName: 'A', category: '', price: 1),
      const ShoppingItem(itemName: 'A', category: 'Home', price: -1),
      const ShoppingItem(itemName: 'A', category: 'Home', price: double.nan),
      const ShoppingItem(
        itemName: 'A',
        category: 'Home',
        price: double.infinity,
      ),
      const ShoppingItem(
        itemName: 'A',
        category: 'Home',
        price: 1,
        status: 'Invalid',
      ),
    ]) {
      await expectLater(database.insert(item), throwsArgumentError);
    }
    await expectLater(
      database.updateStatus(999, ShoppingItem.purchased),
      throwsStateError,
    );
    await expectLater(
      database.updateStatus(999, 'Invalid'),
      throwsArgumentError,
    );
    await expectLater(database.delete(999), throwsStateError);
    expect(await database.getItems(), isEmpty);
  });

  test('failed initialization can recover on retry', () async {
    var fail = true;
    final retryDb = ShoppingDatabase(
      factory: _RetryFactory(databaseFactoryFfi, () {
        if (fail) throw StateError('Simulated unavailable storage');
      }),
      databasePath: '${directory.path}/retry.db',
    );
    addTearDown(retryDb.close);
    final store = ShoppingStore(retryDb);
    addTearDown(store.dispose);
    await store.load();
    expect(store.loadError, isNotNull);
    expect(store.loading, isFalse);
    fail = false;
    await store.load();
    expect(store.loadError, isNull);
    expect(store.items, isEmpty);
  });

  test(
    'price validation rejects malformed, non-finite, zero, and negative input',
    () {
      for (final value in [
        '',
        ' ',
        'abc',
        '-100',
        '0',
        'NaN',
        'Infinity',
        '1e9',
        '12abc',
        '1,000',
        '1.234',
        '999999999999999999999',
      ]) {
        expect(ItemValidation.price(value), isNotNull, reason: value);
      }
      for (final value in ['100', '2500000', '2500000.50', ' 0.10 ']) {
        expect(ItemValidation.price(value), isNull, reason: value);
      }
      expect(ItemValidation.requiredText('  ', 'item name'), isNotNull);
      expect(formatVnd(2500000), '2.500.000 ₫');
      expect(formatVnd(0.30), '0,3 ₫');
      expect(totalPrices([0.1, 0.2]), 0.3);
    },
  );
}

class _RetryFactory implements DatabaseFactory {
  _RetryFactory(this.delegate, this.beforeOpen);
  final DatabaseFactory delegate;
  final void Function() beforeOpen;

  @override
  Future<Database> openDatabase(String path, {OpenDatabaseOptions? options}) {
    beforeOpen();
    return delegate.openDatabase(path, options: options);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
