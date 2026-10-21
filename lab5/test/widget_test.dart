import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab5/main.dart';
import 'package:lab5/models/shopping_item.dart';
import 'package:lab5/services/shopping_database.dart';
import 'package:lab5/services/shopping_store.dart';
import 'package:lab5/utils/currency.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class MemoryDatabase extends ShoppingDatabase {
  MemoryDatabase() : super(factory: databaseFactoryFfi);
  final rows = <ShoppingItem>[];
  int nextId = 1;
  bool failRead = false;
  bool failWrite = false;
  Completer<void>? writeGate;

  @override
  Future<List<ShoppingItem>> getItems({String? status}) async {
    if (failRead) throw StateError('Read failure');
    return rows
        .where((item) => status == null || item.status == status)
        .toList();
  }

  @override
  Future<ShoppingItem> insert(ShoppingItem item) async {
    if (writeGate != null) await writeGate!.future;
    if (failWrite) throw StateError('Write failure');
    final saved = item.copyWith(id: nextId++);
    rows.insert(0, saved);
    return saved;
  }

  @override
  Future<void> updateStatus(int id, String status) async {
    if (failWrite) throw StateError('Write failure');
    final index = rows.indexWhere((item) => item.id == id);
    rows[index] = rows[index].copyWith(status: status);
  }

  @override
  Future<void> delete(int id) async {
    if (failWrite) throw StateError('Write failure');
    rows.removeWhere((item) => item.id == id);
  }
}

Future<void> tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> fillItem(WidgetTester tester, String name, String price) async {
  await tester.enterText(find.byKey(const Key('item-name')), name);
  await tester.enterText(find.byKey(const Key('item-price')), price);
}

void main() {
  late MemoryDatabase database;
  late ShoppingStore store;

  setUp(() {
    database = MemoryDatabase();
    store = ShoppingStore(database);
  });
  tearDown(() => store.dispose());

  testWidgets(
    'empty state, navigation, form validation, cancel, and defaults',
    (tester) async {
      await tester.pumpWidget(MyApp(store: store));
      await tester.pumpAndSettle();
      expect(find.text('No shopping items yet'), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      await tap(tester, find.byTooltip('Add Item'));
      expect(find.text('Wishlist'), findsOneWidget);
      await tap(tester, find.byKey(const Key('save-item')));
      expect(find.text('Error'), findsOneWidget);
      expect(database.rows, isEmpty);
      await tap(tester, find.text('OK'));
      await fillItem(tester, 'Desk', '-123abc');
      await tap(tester, find.byKey(const Key('save-item')));
      expect(find.text('Error'), findsOneWidget);
      expect(database.rows, isEmpty);
      await tap(tester, find.text('OK'));
      await tap(tester, find.text('Cancel'));
      expect(find.text('Favorite Shopping Items'), findsOneWidget);
      await tap(tester, find.byIcon(Icons.favorite_border));
      expect(find.text('Your wishlist is empty'), findsOneWidget);
      expect(find.text(formatVnd(0)), findsOneWidget);
    },
  );

  testWidgets(
    'add, details, toggle both ways, synchronized totals, delete confirmation',
    (tester) async {
      await tester.pumpWidget(MyApp(store: store));
      await tester.pumpAndSettle();
      await tap(tester, find.byTooltip('Add Item'));
      await fillItem(tester, 'Nike Air Force 1', '2500000.50');
      await tap(tester, find.byKey(const Key('save-item')));
      expect(find.text('Success'), findsOneWidget);
      expect(database.rows.single.status, ShoppingItem.wishlist);
      await tap(tester, find.text('OK'));
      expect(find.text('Nike Air Force 1'), findsOneWidget);
      await tap(tester, find.byIcon(Icons.favorite_border));
      expect(
        tester.widget<Text>(find.byKey(const Key('wishlist-total'))).data,
        formatVnd(2500000.50),
      );
      await tap(tester, find.text('Nike Air Force 1'));
      expect(find.text('#1'), findsOneWidget);
      expect(find.text('Fashion'), findsOneWidget);
      await tap(tester, find.byKey(const Key('toggle-status')));
      expect(find.text('Item marked as Purchased'), findsOneWidget);
      await tap(tester, find.text('OK'));
      expect(database.rows.single.status, ShoppingItem.purchased);
      await tap(tester, find.byKey(const Key('toggle-status')));
      expect(find.text('Item moved to Wishlist'), findsOneWidget);
      await tap(tester, find.text('OK'));
      expect(database.rows.single.status, ShoppingItem.wishlist);
      await tap(tester, find.byKey(const Key('toggle-status')));
      await tap(tester, find.text('OK'));
      await tap(tester, find.byKey(const Key('back-home')));
      await tap(tester, find.byIcon(Icons.favorite_border));
      expect(find.text('Your wishlist is empty'), findsOneWidget);
      expect(
        tester.widget<Text>(find.byKey(const Key('wishlist-total'))).data,
        formatVnd(0),
      );
      await tap(tester, find.byIcon(Icons.home_outlined));
      expect(find.text('Purchased'), findsOneWidget);
      await tap(tester, find.text('Nike Air Force 1'));
      await tap(tester, find.byKey(const Key('delete-item')));
      expect(find.text('Confirm Delete'), findsOneWidget);
      await tap(tester, find.text('CANCEL'));
      expect(database.rows.length, 1);
      await tap(tester, find.byKey(const Key('delete-item')));
      await tap(tester, find.byKey(const Key('confirm-delete')));
      expect(find.text('Item deleted'), findsOneWidget);
      await tap(tester, find.text('OK'));
      expect(database.rows, isEmpty);
      expect(find.text('No shopping items yet'), findsOneWidget);
    },
  );

  testWidgets('category and Purchased status can be selected when adding', (
    tester,
  ) async {
    await tester.pumpWidget(MyApp(store: store));
    await tester.pumpAndSettle();
    await tap(tester, find.byTooltip('Add Item'));
    await fillItem(tester, 'AirPods Pro 2', '5600000');
    await tap(tester, find.byKey(const Key('item-category')));
    await tap(tester, find.text('Electronics').last);
    await tap(tester, find.byKey(const Key('item-status')));
    await tap(tester, find.text('Purchased').last);
    await tap(tester, find.byKey(const Key('save-item')));
    await tap(tester, find.text('OK'));
    expect(database.rows.single.category, 'Electronics');
    expect(database.rows.single.status, ShoppingItem.purchased);
    await tap(tester, find.byIcon(Icons.favorite_border));
    expect(find.text('Your wishlist is empty'), findsOneWidget);
  });

  testWidgets('failed status and delete operations keep the existing item', (
    tester,
  ) async {
    await database.insert(
      const ShoppingItem(itemName: 'Desk', category: 'Home', price: 100),
    );
    await tester.pumpWidget(MyApp(store: store));
    await tester.pumpAndSettle();
    await tap(tester, find.text('Desk'));
    database.failWrite = true;
    await tap(tester, find.byKey(const Key('toggle-status')));
    expect(find.text('Error'), findsOneWidget);
    expect(database.rows.single.status, ShoppingItem.wishlist);
    await tap(tester, find.text('OK'));
    await tap(tester, find.byKey(const Key('delete-item')));
    await tap(tester, find.byKey(const Key('confirm-delete')));
    expect(find.text('Error'), findsOneWidget);
    expect(database.rows.single.itemName, 'Desk');
    expect(store.items.single.itemName, 'Desk');
    await tap(tester, find.text('OK'));
  });

  testWidgets(
    'duplicate submissions are blocked while SQLite write is pending',
    (tester) async {
      database.writeGate = Completer<void>();
      await tester.pumpWidget(MyApp(store: store));
      await tester.pumpAndSettle();
      await tap(tester, find.byTooltip('Add Item'));
      await fillItem(tester, 'Desk', '100');
      final button = find.byKey(const Key('save-item'));
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pump();
      expect(tester.widget<FilledButton>(button).onPressed, isNull);
      await tester.tap(button);
      await tester.pump();
      database.writeGate!.complete();
      await tester.pumpAndSettle();
      expect(database.rows.length, 1);
      await tap(tester, find.text('OK'));
    },
  );

  testWidgets('database errors offer retry and preserve entered data', (
    tester,
  ) async {
    database.failRead = true;
    await tester.pumpWidget(MyApp(store: store));
    await tester.pumpAndSettle();
    expect(find.textContaining('Could not load saved items'), findsOneWidget);
    database.failRead = false;
    await tap(tester, find.text('Retry'));
    expect(find.textContaining('Could not load saved items'), findsNothing);
    await tap(tester, find.byTooltip('Add Item'));
    await fillItem(tester, 'Desk', '100');
    database.failWrite = true;
    await tap(tester, find.byKey(const Key('save-item')));
    expect(find.text('Error'), findsOneWidget);
    expect(database.rows, isEmpty);
    await tap(tester, find.text('OK'));
    expect(find.text('Desk'), findsOneWidget);
    database.failWrite = false;
    await tap(tester, find.byKey(const Key('save-item')));
    await tap(tester, find.text('OK'));
    expect(database.rows.single.itemName, 'Desk');
  });

  testWidgets(
    'small phones and landscape support all screens without overflow',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await database.insert(
        const ShoppingItem(
          itemName:
              'A very long shopping item name that wraps across multiple lines',
          category: 'Electronics',
          price: 999999999999.99,
        ),
      );
      for (final size in [const Size(320, 568), const Size(800, 360)]) {
        tester.view.physicalSize = size;
        await tester.pumpWidget(MyApp(key: ValueKey(size), store: store));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tap(tester, find.byIcon(Icons.favorite_border));
        expect(tester.takeException(), isNull);
        await tap(tester, find.text(database.rows.single.itemName));
        expect(tester.takeException(), isNull);
        await tap(tester, find.byKey(const Key('back-home')));
        await tap(tester, find.byTooltip('Add Item'));
        expect(tester.takeException(), isNull);
        await tap(tester, find.text('Cancel'));
      }
    },
  );
}
