import 'package:flutter/foundation.dart';

import '../models/song.dart';
import '../services/song_database.dart';

class LibraryController extends ChangeNotifier {
  LibraryController(this.repository);
  final SongRepository repository;
  List<Song> _songs = const [];
  bool loading = false;
  bool writing = false;
  String? error;
  bool _disposed = false;

  List<Song> get songs => List.unmodifiable(_songs);
  List<Song> get favorites => _songs.where((song) => song.favorite).toList();
  Song? find(int id) {
    for (final song in _songs) {
      if (song.id == id) return song;
    }
    return null;
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> refresh() async {
    if (loading || writing) return;
    loading = true;
    error = null;
    _notify();
    try {
      _songs = await repository.getSongs();
    } catch (failure) {
      debugPrint('Loading songs failed: $failure');
      error = 'Could not load your library. Please try again.';
    } finally {
      loading = false;
      _notify();
    }
  }

  Future<T> _write<T>(Future<T> Function() operation) async {
    if (writing || loading) {
      throw StateError('Please wait for the current operation');
    }
    writing = true;
    _notify();
    try {
      return await operation();
    } finally {
      writing = false;
      _notify();
    }
  }

  Future<Song> add(Song song) => _write(() async {
    final saved = await repository.add(song.copyWith(isFavorite: 0));
    _songs = [saved, ..._songs];
    return saved;
  });

  Future<Song> edit(int id, Song values) => _write(() async {
    final current = find(id);
    if (current == null) throw StateError('This song no longer exists');
    final updated = current.copyWith(
      title: values.title,
      artist: values.artist,
      year: values.year,
      genre: values.genre,
    );
    await repository.update(updated);
    _songs = _songs.map((song) => song.id == id ? updated : song).toList();
    return updated;
  });

  Future<Song> toggleFavorite(int id) => _write(() async {
    final current = find(id);
    if (current == null) throw StateError('This song no longer exists');
    final updated = current.copyWith(isFavorite: current.favorite ? 0 : 1);
    await repository.setFavorite(id, updated.isFavorite);
    _songs = _songs.map((song) => song.id == id ? updated : song).toList();
    return updated;
  });

  Future<void> delete(int id) => _write(() async {
    await repository.delete(id);
    _songs = _songs.where((song) => song.id != id).toList();
  });

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
