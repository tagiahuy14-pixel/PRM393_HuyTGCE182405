import 'dart:async';

import 'package:music_manager_basic_ce182405/models/song.dart';
import 'package:music_manager_basic_ce182405/services/session_service.dart';
import 'package:music_manager_basic_ce182405/services/song_database.dart';

class MemorySession implements SessionStorage {
  MemorySession({this.loggedIn = false});
  bool loggedIn;
  bool failRead = false;
  bool failWrite = false;
  Completer<void>? gate;
  int saves = 0;
  @override
  Future<bool> restore() async {
    if (failRead) throw StateError('Read failure');
    return loggedIn;
  }

  @override
  Future<void> save() async {
    if (gate != null) await gate!.future;
    if (failWrite) throw StateError('Write failure');
    saves++;
    loggedIn = true;
  }

  @override
  Future<void> clear() async {
    if (failWrite) throw StateError('Write failure');
    loggedIn = false;
  }
}

class MemorySongs implements SongRepository {
  List<Song> rows = [];
  int nextId = 1;
  int reads = 0;
  bool failRead = false;
  bool failWrite = false;
  Completer<void>? gate;

  @override
  Future<List<Song>> getSongs({bool favoritesOnly = false}) async {
    reads++;
    if (failRead) throw StateError('Read failure');
    return rows.where((song) => !favoritesOnly || song.favorite).toList();
  }

  Future<void> _write() async {
    if (gate != null) await gate!.future;
    if (failWrite) throw StateError('Write failure');
  }

  @override
  Future<Song> add(Song song) async {
    await _write();
    final saved = song.copyWith(id: nextId++, isFavorite: 0);
    rows.insert(0, saved);
    return saved;
  }

  @override
  Future<void> update(Song song) async {
    await _write();
    rows = rows.map((old) => old.id == song.id ? song : old).toList();
  }

  @override
  Future<void> setFavorite(int id, int value) async {
    await _write();
    rows = rows
        .map((song) => song.id == id ? song.copyWith(isFavorite: value) : song)
        .toList();
  }

  @override
  Future<void> delete(int id) async {
    await _write();
    rows.removeWhere((song) => song.id == id);
  }

  @override
  Future<void> close() async {}
}
