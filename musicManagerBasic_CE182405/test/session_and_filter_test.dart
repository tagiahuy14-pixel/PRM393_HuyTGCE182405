import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:music_manager_basic_ce182405/controllers/auth_controller.dart';
import 'package:music_manager_basic_ce182405/models/song.dart';
import 'package:music_manager_basic_ce182405/models/song_filter.dart';
import 'package:music_manager_basic_ce182405/services/session_service.dart';
import 'package:music_manager_basic_ce182405/utils/validation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'hard-coded login requires both correct values; session stores only a flag',
    () async {
      final auth = AuthController(SessionService());
      addTearDown(auth.dispose);
      await auth.restore();
      for (final credentials in [
        ['wrong', '123456'],
        ['admin', 'wrong'],
        ['', ''],
        ['Admin', '123456'],
      ]) {
        expect(await auth.login(credentials[0], credentials[1]), isFalse);
        expect(auth.authenticated, isFalse);
      }
      expect(await auth.login('admin', '123456'), isTrue);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getKeys(), {SessionService.sessionKey});
      expect(prefs.getBool(SessionService.sessionKey), isTrue);
    },
  );

  test('new controller restores saved session; logout clears it and survives reopening', () async {
    final first = AuthController(SessionService());
    final second = AuthController(SessionService());
    final third = AuthController(SessionService());
    addTearDown(first.dispose);
    addTearDown(second.dispose);
    addTearDown(third.dispose);
    await first.restore();
    await first.login('admin', '123456');
    await second.restore();
    expect(second.authenticated, isTrue);
    await second.logout();
    expect(second.authenticated, isFalse);
    await third.restore();
    expect(third.authenticated, isFalse);
    expect(
      (await SharedPreferences.getInstance()).containsKey(
        SessionService.sessionKey,
      ),
      isFalse,
    );
  });

  test('duplicate login is guarded while session write is pending', () async {
    final session = MemorySession()..gate = Completer<void>();
    final auth = AuthController(session);
    addTearDown(auth.dispose);
    await auth.restore();
    final first = auth.login('admin', '123456');
    expect(auth.busy, isTrue);
    expect(await auth.login('admin', '123456'), isFalse);
    session.gate!.complete();
    expect(await first, isTrue);
    expect(session.saves, 1);
  });

  test(
    'failed preference writes do not grant login or falsely log out',
    () async {
      final session = MemorySession()..failWrite = true;
      final auth = AuthController(session);
      addTearDown(auth.dispose);
      await auth.restore();
      await expectLater(auth.login('admin', '123456'), throwsStateError);
      expect(auth.authenticated, isFalse);
      expect(auth.busy, isFalse);
      session.failWrite = false;
      await auth.login('admin', '123456');
      session.failWrite = true;
      await expectLater(auth.logout(), throwsStateError);
      expect(auth.authenticated, isTrue);
      expect(auth.busy, isFalse);
    },
  );

  const songs = [
    Song(
      id: 1,
      title: 'Love Story',
      artist: 'Taylor Swift',
      year: '2026',
      genre: 'Pop',
    ),
    Song(
      id: 2,
      title: 'Midnight',
      artist: 'Love Band',
      year: '2022',
      genre: 'Rock',
    ),
    Song(
      id: 3,
      title: 'Old Song',
      artist: 'Artist',
      year: '2021',
      genre: 'Pop',
    ),
    Song(id: 4, title: 'Future', artist: 'Artist', year: '2027', genre: 'EDM'),
    Song(id: 5, title: 'Quiet', artist: 'Nova', year: '2025', genre: 'Ballad'),
  ];
  test(
    'search matches title OR artist, case-insensitively, with combined filters',
    () {
      expect(
        const SongFilter(query: ' LOVE ')
            .apply(songs, currentYear: 2026)
            .map((s) => s.id),
        [1, 2],
      );
      expect(
        const SongFilter(
          query: 'love',
          genre: 'Rock',
          year: YearFilter.lastFiveYears,
        ).apply(songs, currentYear: 2026).single.id,
        2,
      );
      expect(
        const SongFilter(query: 'love', genre: 'EDM').apply(songs),
        isEmpty,
      );
      expect(const SongFilter().apply(songs).length, 5);
    },
  );
  test(
    'current-year and rolling five-year filters include exact boundaries',
    () {
      expect(
        const SongFilter(year: YearFilter.currentYear)
            .apply(songs, currentYear: 2026)
            .map((s) => s.id),
        [1],
      );
      expect(
        const SongFilter(year: YearFilter.lastFiveYears)
            .apply(songs, currentYear: 2026)
            .map((s) => s.id),
        [1, 2, 5],
      );
      for (final genre in Song.genres) {
        expect(
          SongFilter(genre: genre)
              .apply(songs)
              .every((song) => song.genre == genre),
          isTrue,
        );
      }
    },
  );
  test('required fields, valid year limits, and model serialization', () {
    expect(Validation.requiredText('  ', 'title'), isNotNull);
    for (final year in ['', 'abcd', '999', '-2020', '2020.0', '2027']) {
      expect(Validation.year(year, currentYear: 2026), isNotNull);
    }
    expect(Validation.year('2026', currentYear: 2026), isNull);
    expect(Validation.year('1000', currentYear: 2026), isNull);
    final song = Song.fromMap(songs.first.toMap());
    expect(song.title, songs.first.title);
    expect(song.year, isA<String>());
    expect(song.isFavorite, 0);
  });
}
