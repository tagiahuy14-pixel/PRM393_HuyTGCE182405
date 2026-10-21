import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:music_manager_basic_ce182405/controllers/library_controller.dart';
import 'package:music_manager_basic_ce182405/models/song.dart';
import 'package:music_manager_basic_ce182405/services/song_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  late Directory directory;
  late SongDatabase repository;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('music_manager_test_');
    repository = SongDatabase(
      factory: databaseFactoryFfi,
      databasePath: '${directory.path}/songs.db',
    );
  });
  tearDown(() async {
    await repository.close();
    await directory.delete(recursive: true);
  });

  test(
    'schema has exactly one application table Song and required column types',
    () async {
      final db = await repository.database;
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%'",
      );
      expect(tables.map((row) => row['name']), ['Song']);
      final columns = await db.rawQuery('PRAGMA table_info(Song)');
      expect(
        {for (final column in columns) column['name']: column['type']},
        {
          'id': 'INTEGER',
          'title': 'TEXT',
          'artist': 'TEXT',
          'year': 'TEXT',
          'genre': 'TEXT',
          'isFavorite': 'INTEGER',
        },
      );
    },
  );

  test(
    'real SQLite CRUD, automatic IDs, default favorites, and persistence',
    () async {
      expect(await repository.getSongs(), isEmpty);
      final first = await repository.add(
        const Song(
          title: 'Love Story',
          artist: 'Taylor Swift',
          year: '2008',
          genre: 'Pop',
          isFavorite: 1,
        ),
      );
      expect(first.isFavorite, 0);
      final second = await repository.add(
        const Song(
          title: 'A second song',
          artist: 'Artist',
          year: '2020',
          genre: 'Rock',
        ),
      );
      expect(second.id, greaterThan(first.id!));
      await repository.setFavorite(first.id!, 1);
      final edited = first.copyWith(
        title: 'Love Story (Live)',
        artist: 'Taylor',
        year: '2021',
        genre: 'Ballad',
        isFavorite: 1,
      );
      await repository.update(edited);
      await repository.close();
      final persisted = await repository.getSongs();
      expect(persisted.length, 2);
      final favorite = (await repository.getSongs(favoritesOnly: true)).single;
      expect(favorite.title, 'Love Story (Live)');
      expect(favorite.artist, 'Taylor');
      expect(favorite.year, '2021');
      expect(favorite.genre, 'Ballad');
      await repository.setFavorite(first.id!, 0);
      expect(await repository.getSongs(favoritesOnly: true), isEmpty);
      await repository.delete(second.id!);
      await repository.close();
      expect((await repository.getSongs()).single.id, first.id);
      final third = await repository.add(
        const Song(
          title: 'Third',
          artist: 'Artist',
          year: '2020',
          genre: 'EDM',
        ),
      );
      expect(third.id, greaterThan(second.id!));
    },
  );

  test(
    'shared controller preserves favorite on edit and synchronizes deletion',
    () async {
      final library = LibraryController(repository);
      addTearDown(library.dispose);
      await library.refresh();
      final song = await library.add(
        const Song(title: 'A', artist: 'B', year: '2020', genre: 'Pop'),
      );
      await library.toggleFavorite(song.id!);
      expect(library.favorites.single.id, song.id);
      await library.edit(
        song.id!,
        const Song(
          title: 'Edited',
          artist: 'New artist',
          year: '2021',
          genre: 'Rock',
        ),
      );
      expect(library.find(song.id!)!.isFavorite, 1);
      expect(library.favorites.single.title, 'Edited');
      await library.refresh();
      expect(library.favorites.single.title, 'Edited');
      await library.toggleFavorite(song.id!);
      expect(library.favorites, isEmpty);
      await library.delete(song.id!);
      expect(library.songs, isEmpty);
      expect(await repository.getSongs(), isEmpty);
    },
  );

  test('invalid data and missing rows are rejected without changes', () async {
    for (final song in [
      const Song(title: '', artist: 'A', year: '2020', genre: 'Pop'),
      const Song(title: 'A', artist: ' ', year: '2020', genre: 'Pop'),
      const Song(title: 'A', artist: 'A', year: 'abc', genre: 'Pop'),
      const Song(title: 'A', artist: 'A', year: '2020', genre: 'Jazz'),
      const Song(
        title: 'A',
        artist: 'A',
        year: '2020',
        genre: 'Pop',
        isFavorite: 2,
      ),
    ]) {
      await expectLater(repository.add(song), throwsArgumentError);
    }
    await expectLater(repository.setFavorite(99, 2), throwsArgumentError);
    await expectLater(repository.setFavorite(99, 1), throwsStateError);
    await expectLater(repository.delete(99), throwsStateError);
    final db = await repository.database;
    await expectLater(
      db.insert('Song', {
        'title': 'A',
        'artist': 'B',
        'year': '2020',
        'genre': 'Pop',
        'isFavorite': 3,
      }),
      throwsA(isA<DatabaseException>()),
    );
    expect(await repository.getSongs(), isEmpty);
  });

  test('failed database initialization can be retried', () async {
    final parent = File('${directory.path}/blocked');
    await parent.writeAsString('blocks database directory');
    final retry = SongDatabase(
      factory: databaseFactoryFfi,
      databasePath: '${parent.path}/songs.db',
    );
    final library = LibraryController(retry);
    addTearDown(library.dispose);
    addTearDown(retry.close);
    await library.refresh();
    expect(library.error, isNotNull);
    expect(library.loading, isFalse);
    await parent.delete();
    await Directory(parent.path).create();
    await library.refresh();
    expect(library.error, isNull);
    expect(library.songs, isEmpty);
  });
}
