import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../models/song.dart';
import '../utils/validation.dart';

abstract class SongRepository {
  Future<List<Song>> getSongs({bool favoritesOnly = false});
  Future<Song> add(Song song);
  Future<void> update(Song song);
  Future<void> setFavorite(int id, int value);
  Future<void> delete(int id);
  Future<void> close();
}

class SongDatabase implements SongRepository {
  SongDatabase({DatabaseFactory? factory, this._databasePath})
    : _factory = factory ?? databaseFactory;

  final DatabaseFactory _factory;
  final String? _databasePath;
  Future<Database>? _opening;

  Future<Database> get database async {
    try {
      return await (_opening ??= _open());
    } catch (_) {
      _opening = null;
      rethrow;
    }
  }

  Future<Database> _open() async => _factory.openDatabase(
    _databasePath ??
        path.join(await _factory.getDatabasesPath(), 'music_library.db'),
    options: OpenDatabaseOptions(
      version: 1,
      onCreate: (db, version) async {
        // The sole application table. sqlite_sequence is SQLite's internal
        // AUTOINCREMENT bookkeeping, not an additional application table.
        await db.execute('''
          CREATE TABLE Song (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL CHECK(length(trim(title)) BETWEEN 1 AND 120),
            artist TEXT NOT NULL CHECK(length(trim(artist)) BETWEEN 1 AND 120),
            year TEXT NOT NULL CHECK(length(year) = 4 AND year NOT GLOB '*[^0-9]*' AND CAST(year AS INTEGER) >= 1000),
            genre TEXT NOT NULL CHECK(genre IN ('Pop', 'Rock', 'EDM', 'Ballad')),
            isFavorite INTEGER NOT NULL DEFAULT 0 CHECK(isFavorite IN (0, 1))
          )
        ''');
      },
    ),
  );

  @override
  Future<List<Song>> getSongs({bool favoritesOnly = false}) async {
    final db = await database;
    final rows = await db.query(
      'Song',
      where: favoritesOnly ? 'isFavorite = ?' : null,
      whereArgs: favoritesOnly ? [1] : null,
      orderBy: 'id DESC',
    );
    return rows.map(Song.fromMap).toList();
  }

  @override
  Future<Song> add(Song song) async {
    Validation.song(song);
    if (song.id != null) {
      throw ArgumentError('New songs must have an automatic ID');
    }
    final created = song.copyWith(isFavorite: 0);
    final db = await database;
    final id = await db.insert('Song', created.toMap());
    return created.copyWith(id: id);
  }

  @override
  Future<void> update(Song song) async {
    Validation.song(song);
    if (song.id == null) throw ArgumentError('Missing song ID');
    final db = await database;
    final values = song.toMap()..remove('id');
    final count = await db.update(
      'Song',
      values,
      where: 'id = ?',
      whereArgs: [song.id],
    );
    if (count != 1) throw StateError('This song no longer exists');
  }

  @override
  Future<void> setFavorite(int id, int value) async {
    if (value != 0 && value != 1) {
      throw ArgumentError('Favorite must be 0 or 1');
    }
    final db = await database;
    final count = await db.update(
      'Song',
      {'isFavorite': value},
      where: 'id = ?',
      whereArgs: [id],
    );
    if (count != 1) throw StateError('This song no longer exists');
  }

  @override
  Future<void> delete(int id) async {
    final db = await database;
    final count = await db.delete('Song', where: 'id = ?', whereArgs: [id]);
    if (count != 1) throw StateError('This song no longer exists');
  }

  @override
  Future<void> close() async {
    final opening = _opening;
    _opening = null;
    if (opening != null) await (await opening).close();
  }
}
