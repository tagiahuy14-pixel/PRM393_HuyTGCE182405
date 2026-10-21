import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lab5/main.dart';
import 'package:lab5/models/shopping_item.dart';
import 'package:lab5/services/shopping_database.dart';
import 'package:lab5/services/shopping_store.dart';
import 'package:lab5/utils/currency.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'native SQLite UI flow, persistence, status toggles, totals, and deletion',
    (tester) async {
      final databasePath = path.join(
        await getDatabasesPath(),
        'lab5_integration_test.db',
      );
      await deleteDatabase(databasePath);
      final database = ShoppingDatabase(databasePath: databasePath);
      final store = ShoppingStore(database);
      await tester.pumpWidget(MyApp(store: store));
      await tester.pumpAndSettle();
      expect(find.text('No shopping items yet'), findsOneWidget);

      Future<void> tap(Finder finder) async {
        await tester.ensureVisible(finder);
        await tester.tap(finder);
        await tester.pumpAndSettle();
      }

      await tap(find.byTooltip('Add Item'));
      await tap(find.byKey(const Key('save-item')));
      expect(find.text('Error'), findsOneWidget);
      await tap(find.text('OK'));
      await tester.enterText(
        find.byKey(const Key('item-name')),
        'Nike Air Force 1',
      );
      await tester.enterText(find.byKey(const Key('item-price')), '2500000.50');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tap(find.byKey(const Key('save-item')));
      await tap(find.text('OK'));
      expect((await database.getItems()).single.itemName, 'Nike Air Force 1');
      await tap(find.byIcon(Icons.favorite_border));
      expect(
        tester.widget<Text>(find.byKey(const Key('wishlist-total'))).data,
        formatVnd(2500000.50),
      );
      await tap(find.text('Nike Air Force 1'));
      await tap(find.byKey(const Key('toggle-status')));
      await tap(find.text('OK'));
      expect((await database.getItems()).single.status, ShoppingItem.purchased);
      await tap(find.byKey(const Key('back-home')));
      await tap(find.byIcon(Icons.favorite_border));
      expect(find.text('Your wishlist is empty'), findsOneWidget);
      expect(
        tester.widget<Text>(find.byKey(const Key('wishlist-total'))).data,
        formatVnd(0),
      );

      // Recreate the database connection and app state to verify disk persistence.
      await tester.pumpWidget(const SizedBox.shrink());
      store.dispose();
      await database.close();
      final reopened = ShoppingDatabase(databasePath: databasePath);
      final reopenedStore = ShoppingStore(reopened);
      await tester.pumpWidget(MyApp(store: reopenedStore));
      await tester.pumpAndSettle();
      expect(find.text('Nike Air Force 1'), findsOneWidget);
      expect(find.text('Purchased'), findsOneWidget);
      await tap(find.text('Nike Air Force 1'));
      await tap(find.byKey(const Key('toggle-status')));
      await tap(find.text('OK'));
      expect((await reopened.getItems()).single.status, ShoppingItem.wishlist);
      await tap(find.byKey(const Key('delete-item')));
      await tap(find.text('CANCEL'));
      expect((await reopened.getItems()).length, 1);
      await tap(find.byKey(const Key('delete-item')));
      await tap(find.byKey(const Key('confirm-delete')));
      await tap(find.text('OK'));
      expect(await reopened.getItems(), isEmpty);
      expect(find.text('No shopping items yet'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      reopenedStore.dispose();
      await reopened.close();
      await deleteDatabase(databasePath);
    },
  );
}
