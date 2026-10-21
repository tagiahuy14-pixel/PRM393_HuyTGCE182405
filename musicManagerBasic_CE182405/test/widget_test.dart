import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_manager_basic_ce182405/controllers/auth_controller.dart';
import 'package:music_manager_basic_ce182405/controllers/library_controller.dart';
import 'package:music_manager_basic_ce182405/main.dart';
import 'package:music_manager_basic_ce182405/models/song.dart';
import 'package:music_manager_basic_ce182405/screens/home_screen.dart';
import 'package:music_manager_basic_ce182405/screens/login_screen.dart';

import 'support/fakes.dart';

Future<void> tap(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      finder,
      200,
      scrollable: find.byType(Scrollable).first,
    );
  }
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle(
    const Duration(milliseconds: 100),
    EnginePhase.sendSemanticsUpdate,
    const Duration(seconds: 15),
  );
}

Future<void> fillSong(
  WidgetTester tester, {
  String title = 'Midnight Drive',
  String artist = 'Nova Lane',
  String? year,
}) async {
  await tester.enterText(find.byKey(const Key('song-title')), title);
  await tester.enterText(find.byKey(const Key('song-artist')), artist);
  await tester.enterText(
    find.byKey(const Key('song-year')),
    year ?? '${DateTime.now().year}',
  );
}

void main() {
  WidgetController.hitTestWarningShouldBeFatal = true;
  late MemorySession session;
  late MemorySongs repository;
  late AuthController auth;
  late LibraryController library;
  setUp(() {
    session = MemorySession(loggedIn: true);
    repository = MemorySongs();
    auth = AuthController(session);
    library = LibraryController(repository);
  });
  tearDown(() {
    auth.dispose();
    library.dispose();
  });

  Future<void> start(WidgetTester tester) async {
    await tester.pumpWidget(MusicManagerApp(auth: auth, library: library));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'login validation, exact credentials, session, and logout feedback',
    (tester) async {
      session.loggedIn = false;
      await start(tester);
      expect(find.byType(LoginScreen), findsOneWidget);
      await tap(tester, find.byKey(const Key('login-button')));
      expect(find.text('Please enter your username'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
      await tester.enterText(find.byKey(const Key('username')), 'admin');
      await tester.enterText(find.byKey(const Key('password')), 'wrong');
      await tap(tester, find.byKey(const Key('login-button')));
      expect(find.text('Invalid username or password'), findsWidgets);
      expect(repository.reads, 0);
      await tester.enterText(find.byKey(const Key('password')), '123456');
      await tap(tester, find.byKey(const Key('login-button')));
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(session.loggedIn, isTrue);
      await tap(tester, find.byKey(const Key('logout')));
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('Logged out successfully'), findsOneWidget);
      expect(session.loggedIn, isFalse);
    },
  );

  testWidgets(
    'session startup errors offer recovery; saved session opens Home',
    (tester) async {
      session.failRead = true;
      await start(tester);
      expect(
        find.textContaining('Could not restore your session'),
        findsOneWidget,
      );
      session.failRead = false;
      await tap(tester, find.text('Retry'));
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
    },
  );

  testWidgets(
    'add validates required inputs and year; cancel discards changes',
    (tester) async {
      await start(tester);
      await tap(tester, find.byKey(const Key('add-song')));
      await tap(tester, find.byKey(const Key('save-song')));
      expect(find.text('Please enter a song title'), findsOneWidget);
      expect(find.text('Please enter an artist'), findsOneWidget);
      expect(repository.rows, isEmpty);
      await fillSong(tester, year: 'abcd');
      await tap(tester, find.byKey(const Key('save-song')));
      expect(find.textContaining('Enter a four-digit year'), findsOneWidget);
      await tap(tester, find.byKey(const Key('cancel-song')));
      expect(repository.rows, isEmpty);
      await tap(tester, find.byKey(const Key('add-song')));
      await fillSong(tester);
      await tap(tester, find.byKey(const Key('song-genre')));
      await tap(tester, find.text('EDM').last);
      await tap(tester, find.byKey(const Key('save-song')));
      expect(repository.rows.single.isFavorite, 0);
      expect(repository.rows.single.genre, 'EDM');
      expect(find.text('Song added successfully'), findsOneWidget);
    },
  );

  testWidgets(
    'detail edit favorite and delete stay synchronized across screens',
    (tester) async {
      final song = await repository.add(
        const Song(
          title: 'Midnight Drive',
          artist: 'Nova Lane',
          year: '2020',
          genre: 'Pop',
        ),
      );
      await start(tester);
      await tap(tester, find.text('Midnight Drive'));
      expect(find.text('#${song.id}'), findsOneWidget);
      await tap(tester, find.byKey(const Key('detail-favorite')));
      expect(repository.rows.single.isFavorite, 1);
      await tap(tester, find.byKey(const Key('edit-song')));
      await fillSong(
        tester,
        title: 'Midnight Acoustic',
        artist: 'Nova',
        year: '2021',
      );
      await tap(tester, find.byKey(const Key('save-song')));
      expect(find.text('Midnight Acoustic'), findsOneWidget);
      expect(repository.rows.single.isFavorite, 1);
      expect(find.text('2021'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tap(tester, find.byKey(const Key('open-favorites')));
      expect(find.text('Midnight Acoustic'), findsOneWidget);
      await tap(tester, find.byKey(ValueKey('favorite-${song.id}')));
      expect(find.text('No favorites yet'), findsOneWidget);
      expect(library.favorites, isEmpty);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(repository.rows.single.isFavorite, 0);
      await tap(tester, find.text('Midnight Acoustic'));
      await tap(tester, find.byKey(const Key('delete-song')));
      expect(find.text('Delete song?'), findsOneWidget);
      await tap(tester, find.text('Cancel'));
      expect(repository.rows.length, 1);
      await tap(tester, find.byKey(const Key('delete-song')));
      await tap(tester, find.byKey(const Key('confirm-delete')));
      expect(repository.rows, isEmpty);
      expect(find.text('Song deleted successfully'), findsOneWidget);
    },
  );

  testWidgets('search by artist combines dynamically with genre and year', (
    tester,
  ) async {
    await repository.add(
      Song(
        title: 'Current',
        artist: 'Nova',
        year: '${DateTime.now().year}',
        genre: 'Pop',
      ),
    );
    await repository.add(
      const Song(title: 'Older', artist: 'Nova', year: '2000', genre: 'Rock'),
    );
    await start(tester);
    await tester.enterText(find.byKey(const Key('song-search')), 'nova');
    await tester.pumpAndSettle();
    await tap(tester, find.byKey(const Key('genre-filter')));
    await tap(tester, find.text('Pop').last);
    expect(find.text('Current'), findsOneWidget);
    expect(find.text('Older'), findsNothing);
    await tap(tester, find.byKey(const Key('year-filter')));
    await tap(tester, find.text('Current year').last);
    expect(find.text('Current'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('song-search')), 'missing');
    await tester.pumpAndSettle();
    expect(find.text('No songs match'), findsOneWidget);
    await tap(tester, find.text('Reset'));
    expect(library.songs.length, 2);
    expect(find.text('Songs · 2'), findsOneWidget);
  });

  testWidgets('duplicate save is disabled while write is pending', (
    tester,
  ) async {
    repository.gate = Completer<void>();
    await start(tester);
    await tap(tester, find.byKey(const Key('add-song')));
    await fillSong(tester);
    final button = find.byKey(const Key('save-song'));
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pump();
    expect(tester.widget<FilledButton>(button).onPressed, isNull);
    await tester.tap(button);
    await tester.pump();
    repository.gate!.complete();
    await tester.pumpAndSettle();
    expect(repository.rows.length, 1);
  });

  testWidgets(
    'database load and save failures offer retry and preserve form input',
    (tester) async {
      repository.failRead = true;
      await start(tester);
      expect(
        find.textContaining('Could not load your library'),
        findsOneWidget,
      );
      repository.failRead = false;
      await tap(tester, find.text('Retry'));
      await tap(tester, find.byKey(const Key('add-song')));
      await fillSong(tester);
      repository.failWrite = true;
      await tap(tester, find.byKey(const Key('save-song')));
      expect(find.textContaining('Could not save this song'), findsOneWidget);
      expect(repository.rows, isEmpty);
      expect(
        tester
            .widget<TextFormField>(find.byKey(const Key('song-title')))
            .controller!
            .text,
        'Midnight Drive',
      );
      repository.failWrite = false;
      await tap(tester, find.byKey(const Key('save-song')));
      expect(repository.rows.single.title, 'Midnight Drive');
    },
  );

  testWidgets(
    'all six screens fit small phones, landscape, and enlarged text',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await repository.add(
        const Song(
          title: 'A long title that wraps onto more than one line',
          artist: 'An artist with a longer name',
          year: '2020',
          genre: 'Ballad',
        ),
      );
      for (final size in [const Size(320, 568), const Size(800, 360)]) {
        tester.view.physicalSize = size;
        tester.platformDispatcher.textScaleFactorTestValue = size.width == 320
            ? 1.5
            : 1;
        session.loggedIn = false;
        await tester.pumpWidget(
          MusicManagerApp(key: ValueKey(size), auth: auth, library: library),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.enterText(find.byKey(const Key('username')), 'admin');
        await tester.enterText(find.byKey(const Key('password')), '123456');
        await tap(tester, find.byKey(const Key('login-button')));
        expect(tester.takeException(), isNull);
        await tap(tester, find.byKey(const Key('add-song')));
        await tap(tester, find.byKey(const Key('cancel-song')));
        await tap(tester, find.text(repository.rows.single.title));
        await tap(tester, find.byKey(const Key('edit-song')));
        await tap(tester, find.byKey(const Key('cancel-song')));
        await tester.pageBack();
        await tester.pumpAndSettle();
        await tap(tester, find.byKey(const Key('open-favorites')));
        expect(tester.takeException(), isNull);
        await tester.pageBack();
        await tester.pumpAndSettle();
      }
    },
  );
}
