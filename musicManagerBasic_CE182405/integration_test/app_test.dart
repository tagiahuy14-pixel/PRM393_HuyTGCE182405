import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:music_manager_basic_ce182405/controllers/auth_controller.dart';
import 'package:music_manager_basic_ce182405/controllers/library_controller.dart';
import 'package:music_manager_basic_ce182405/main.dart';
import 'package:music_manager_basic_ce182405/screens/home_screen.dart';
import 'package:music_manager_basic_ce182405/screens/login_screen.dart';
import 'package:music_manager_basic_ce182405/services/session_service.dart';
import 'package:music_manager_basic_ce182405/services/song_database.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('all twelve tasks using native SQLite and SharedPreferences', (
    tester,
  ) async {
    final file = path.join(
      await getDatabasesPath(),
      'lab2_integration_test.db',
    );
    await deleteDatabase(file);
    await SessionService().clear();
    var database = SongDatabase(databasePath: file);
    var library = LibraryController(database);
    var auth = AuthController(SessionService());

    Future<void> tap(Finder finder) async {
      await tester.ensureVisible(finder);
      await tester.pumpAndSettle();
      await tester.tap(finder);
      await tester.pumpAndSettle();
    }

    Future<void> screenshot(String name) async {
      final scaffold = find.byType(Scaffold).last;
      ScaffoldMessenger.of(tester.element(scaffold)).hideCurrentSnackBar();
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await binding.takeScreenshot(name);
    }

    Future<void> rebuild() async {
      await tester.pumpWidget(const SizedBox.shrink());
      auth.dispose();
      library.dispose();
      await database.close();
      database = SongDatabase(databasePath: file);
      library = LibraryController(database);
      auth = AuthController(SessionService());
      await tester.pumpWidget(MusicManagerApp(auth: auth, library: library));
      await tester.pumpAndSettle();
    }

    Future<void> login() async {
      await tester.enterText(find.byKey(const Key('username')), 'admin');
      await tester.enterText(find.byKey(const Key('password')), '123456');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tap(find.byKey(const Key('login-button')));
      expect(find.byType(HomeScreen), findsOneWidget);
    }

    await tester.pumpWidget(MusicManagerApp(auth: auth, library: library));
    await tester.pumpAndSettle();
    if (Platform.isAndroid) await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    await screenshot('01_login');
    await tap(find.byKey(const Key('login-button')));
    expect(find.text('Please enter your username'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('username')), 'admin');
    await tester.enterText(find.byKey(const Key('password')), 'wrong');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tap(find.byKey(const Key('login-button')));
    expect(find.text('Invalid username or password'), findsWidgets);
    await login();
    expect(await SessionService().restore(), isTrue);

    await tap(find.byKey(const Key('add-song')));
    await screenshot('03_add_song');
    await tap(find.byKey(const Key('save-song')));
    expect(find.text('Please enter a song title'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('song-title')),
      'Midnight Drive',
    );
    await tester.enterText(find.byKey(const Key('song-artist')), 'Nova Lane');
    await tester.enterText(
      find.byKey(const Key('song-year')),
      '${DateTime.now().year}',
    );
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tap(find.byKey(const Key('save-song')));
    expect((await database.getSongs()).single.isFavorite, 0);
    await screenshot('02_home');

    await tap(find.text('Midnight Drive'));
    await screenshot('04_song_detail');
    await tap(find.byKey(const Key('detail-favorite')));
    expect((await database.getSongs(favoritesOnly: true)).length, 1);
    await tap(find.byKey(const Key('edit-song')));
    await screenshot('05_edit_song');
    await tester.enterText(
      find.byKey(const Key('song-title')),
      'Midnight Acoustic',
    );
    await tester.enterText(
      find.byKey(const Key('song-year')),
      '${DateTime.now().year - 1}',
    );
    await tap(find.byKey(const Key('song-genre')));
    await tap(find.text('Ballad').last);
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tap(find.byKey(const Key('save-song')));
    expect(find.text('Midnight Acoustic'), findsOneWidget);
    expect((await database.getSongs()).single.isFavorite, 1);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tap(find.byKey(const Key('open-favorites')));
    await screenshot('06_favorites');
    final id = library.songs.single.id!;
    await tap(find.byKey(ValueKey('favorite-$id')));
    expect(find.text('No favorites yet'), findsOneWidget);
    expect((await database.getSongs()).single.isFavorite, 0);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('song-search')), 'nova');
    await tester.pumpAndSettle();
    expect(find.text('Midnight Acoustic'), findsOneWidget);
    await tap(find.byKey(const Key('genre-filter')));
    await tap(find.text('Ballad').last);
    await tap(find.byKey(const Key('year-filter')));
    await tap(find.text('Current year').last);
    expect(find.text('No songs match'), findsOneWidget);
    await tap(find.byKey(const Key('year-filter')));
    await tap(find.text('Last 5 years').last);
    expect(find.text('Midnight Acoustic'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('song-search')), 'acoustic');
    await tester.pumpAndSettle();
    expect(find.text('Midnight Acoustic'), findsOneWidget);
    await tap(find.text('Reset'));
    await tap(find.byKey(ValueKey('favorite-$id')));

    await rebuild();
    expect(find.byType(LoginScreen), findsNothing);
    expect(find.text('Midnight Acoustic'), findsOneWidget);
    expect(library.songs.single.isFavorite, 1);
    final db = await database.database;
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' AND name != 'android_metadata'",
    );
    expect(tables.map((row) => row['name']), ['Song']);
    await tap(find.byKey(const Key('logout')));
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Logged out successfully'), findsOneWidget);
    expect(await SessionService().restore(), isFalse);
    await rebuild();
    expect(find.byType(LoginScreen), findsOneWidget);
    await login();
    expect(library.songs.length, 1);
    await tap(find.text('Midnight Acoustic'));
    await tap(find.byKey(const Key('delete-song')));
    await tap(find.text('Cancel'));
    expect((await database.getSongs()).length, 1);
    await tap(find.byKey(const Key('delete-song')));
    await tap(find.byKey(const Key('confirm-delete')));
    expect(find.text('Song deleted successfully'), findsOneWidget);
    expect(await database.getSongs(), isEmpty);
    await tap(find.byKey(const Key('logout')));

    await tester.pumpWidget(const SizedBox.shrink());
    auth.dispose();
    library.dispose();
    await database.close();
    await deleteDatabase(file);
    await SessionService().clear();
  });
}
