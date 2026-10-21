import 'package:flutter_test/flutter_test.dart';
import 'package:lab1/models/artwork.dart';
import 'package:lab1/models/favorite.dart';
import 'package:lab1/models/gallery_stats.dart';
import 'package:lab1/models/user.dart';
import 'package:lab1/services/database_helper.dart';
import 'package:lab1/services/password_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('PasswordHelper Tests', () {
    test('Hashes password and verifies correctly', () {
      const password = 'mySecretPassword123';
      final hash = PasswordHelper.hashPassword(password);

      expect(hash, isNotEmpty);
      expect(hash, isNot(equals(password))); // Must not be plaintext
      expect(PasswordHelper.verifyPassword(password, hash), isTrue);
      expect(PasswordHelper.verifyPassword('wrongPassword', hash), isFalse);
    });
  });

  group('Models Serialization Tests', () {
    test('User toMap and fromMap', () {
      final user = User(
        id: 1,
        username: 'alice',
        email: 'alice@example.com',
        password: 'hashedpassword',
        createdAt: '2026-10-21T12:00:00Z',
      );

      final map = user.toMap();
      expect(map['id'], 1);
      expect(map['username'], 'alice');
      expect(map['email'], 'alice@example.com');

      final deserialized = User.fromMap(map);
      expect(deserialized.id, user.id);
      expect(deserialized.username, user.username);
      expect(deserialized.email, user.email);
    });

    test('Artwork toMap, fromMap, and copyWith', () {
      final artwork = Artwork(
        id: 10,
        title: 'Starry Night',
        artist: 'Van Gogh',
        year: '1889',
        category: 'Landscape',
        description: 'Post-impressionist masterpiece',
        createdBy: 1,
      );

      final map = artwork.toMap();
      expect(map['title'], 'Starry Night');
      expect(map['category'], 'Landscape');

      final deserialized = Artwork.fromMap(map);
      expect(deserialized.id, 10);
      expect(deserialized.title, 'Starry Night');
      expect(deserialized.artist, 'Van Gogh');

      final updated = deserialized.copyWith(
        title: 'Starry Night Over the Rhone',
      );
      expect(updated.title, 'Starry Night Over the Rhone');
      expect(updated.id, 10);
      expect(updated.artist, 'Van Gogh');
    });

    test('Favorite toMap and fromMap', () {
      final fav = Favorite(
        id: 5,
        userId: 1,
        artworkId: 10,
        createdAt: '2026-10-21T12:30:00Z',
      );

      final map = fav.toMap();
      expect(map['id'], 5);
      expect(map['userId'], 1);
      expect(map['artworkId'], 10);

      final deserialized = Favorite.fromMap(map);
      expect(deserialized.id, fav.id);
      expect(deserialized.userId, fav.userId);
      expect(deserialized.artworkId, fav.artworkId);
    });

    test('GalleryStats default values', () {
      const stats = GalleryStats();
      expect(stats.totalArtworks, 0);
      expect(stats.favoriteArtworks, 0);
      expect(stats.totalCategories, 0);
    });
  });

  group('DatabaseHelper Flow and 14 Tasks Verification', () {
    late DatabaseHelper dbHelper;

    setUp(() async {
      dbHelper = DatabaseHelper.instance;
    });

    tearDown(() async {
      final db = await dbHelper.database;
      await db.delete(DatabaseHelper.tableFavorites);
      await db.delete(DatabaseHelper.tableArtworks);
      await db.delete(DatabaseHelper.tableUsers);
    });

    test(
      'Tasks 1 & 2: User Registration and Login with duplicate prevention',
      () async {
        final user = User(
          username: 'testartist',
          email: 'artist@test.com',
          password: 'Password123!',
          createdAt: DateTime.now().toIso8601String(),
        );

        // Task 1: Register
        final userId = await dbHelper.registerUser(user);
        expect(userId, greaterThan(0));

        // Task 1: Prevent duplicate username
        final isTaken = await dbHelper.isUsernameTaken('testartist');
        expect(isTaken, isTrue);

        expect(
          () async => await dbHelper.registerUser(user),
          throwsA(isA<Exception>()),
        );

        // Task 2: Login success
        final loggedInUser = await dbHelper.login('testartist', 'Password123!');
        expect(loggedInUser, isNotNull);
        expect(loggedInUser!.id, userId);
        expect(loggedInUser.username, 'testartist');

        // Task 2: Login failure with wrong password
        final wrongPasswordUser = await dbHelper.login(
          'testartist',
          'WrongPassword',
        );
        expect(wrongPasswordUser, isNull);

        // Task 2: Login failure with nonexistent user
        final nonexistentUser = await dbHelper.login(
          'nonexistent',
          'Password123!',
        );
        expect(nonexistentUser, isNull);
      },
    );

    test('Tasks 5, 6, 7, 8, 9: Artwork CRUD Operations', () async {
      final user = User(
        username: 'curator',
        email: 'curator@gallery.com',
        password: 'Pass',
        createdAt: DateTime.now().toIso8601String(),
      );
      final userId = await dbHelper.registerUser(user);

      // Task 6: Add Artwork (Auto-increment ID)
      final artwork1 = Artwork(
        title: 'Mona Lisa',
        artist: 'Leonardo da Vinci',
        year: '1503',
        category: 'Portrait',
        description: 'Famous Renaissance portrait',
        createdBy: userId,
      );
      final id1 = await dbHelper.insertArtwork(artwork1);
      expect(id1, greaterThan(0));

      final artwork2 = Artwork(
        title: 'Sunflowers',
        artist: 'Vincent van Gogh',
        year: '1888',
        category: 'Landscape',
        description: 'Vibrant sunflowers in vase',
        createdBy: userId,
      );
      final id2 = await dbHelper.insertArtwork(artwork2);
      expect(id2, greaterThan(id1)); // Auto-incrementing

      // Task 7: Artwork Detail
      final detail = await dbHelper.getArtworkById(id1);
      expect(detail, isNotNull);
      expect(detail!.title, 'Mona Lisa');
      expect(detail.category, 'Portrait');

      // Task 8: Update Artwork
      final updatedArtwork = detail.copyWith(
        title: 'Mona Lisa (Restored)',
        description: 'Updated condition report',
      );
      final rowsUpdated = await dbHelper.updateArtwork(updatedArtwork);
      expect(rowsUpdated, 1);

      final reFetched = await dbHelper.getArtworkById(id1);
      expect(reFetched!.title, 'Mona Lisa (Restored)');
      expect(reFetched.description, 'Updated condition report');

      // Task 9: Delete Artwork
      final rowsDeleted = await dbHelper.deleteArtwork(id1);
      expect(rowsDeleted, 1);

      final deletedCheck = await dbHelper.getArtworkById(id1);
      expect(deletedCheck, isNull);

      final remainingArtworks = await dbHelper.getAllArtworks();
      expect(remainingArtworks.length, 1);
      expect(remainingArtworks.first.id, id2);
    });

    test('Tasks 10 & 11: Dynamic Search and Filtering', () async {
      final user = User(
        username: 'searcher',
        email: 'searcher@test.com',
        password: 'Pass',
        createdAt: DateTime.now().toIso8601String(),
      );
      final userId = await dbHelper.registerUser(user);

      final currentYear = DateTime.now().year.toString();

      await dbHelper.insertArtwork(
        Artwork(
          title: 'Sunrise Over the Sea',
          artist: 'Claude Monet',
          year: currentYear,
          category: 'Landscape',
          description: 'Impressionist dawn',
          createdBy: userId,
        ),
      );

      await dbHelper.insertArtwork(
        Artwork(
          title: 'Sunlight Landscape',
          artist: 'Alfred Sisley',
          year: '2020',
          category: 'Landscape',
          description: 'Bright landscape',
          createdBy: userId,
        ),
      );

      await dbHelper.insertArtwork(
        Artwork(
          title: 'Abstract Harmony',
          artist: 'Wassily Kandinsky',
          year: currentYear,
          category: 'Abstract',
          description: 'Geometric abstract shapes',
          createdBy: userId,
        ),
      );

      // Task 10: Dynamic Search by title "Sun"
      final searchResults = await dbHelper.searchAndFilterArtworks(
        query: 'Sun',
      );
      expect(searchResults.length, 2);
      expect(
        searchResults.map((e) => e.title),
        containsAll(['Sunrise Over the Sea', 'Sunlight Landscape']),
      );

      // Task 11: Filter by category "Abstract"
      final categoryResults = await dbHelper.searchAndFilterArtworks(
        categoryFilter: 'Abstract',
      );
      expect(categoryResults.length, 1);
      expect(categoryResults.first.title, 'Abstract Harmony');

      // Task 11: Filter by year "Current year"
      final yearResults = await dbHelper.searchAndFilterArtworks(
        yearFilter: 'Current year',
      );
      expect(yearResults.length, 2);

      // Combined search + category + year
      final combined = await dbHelper.searchAndFilterArtworks(
        query: 'Sun',
        categoryFilter: 'Landscape',
        yearFilter: 'Current year',
      );
      expect(combined.length, 1);
      expect(combined.first.title, 'Sunrise Over the Sea');
    });

    test('Tasks 12, 13 & 14: Favorites and Gallery Statistics', () async {
      final user = User(
        username: 'fan',
        email: 'fan@test.com',
        password: 'Pass',
        createdAt: DateTime.now().toIso8601String(),
      );
      final userId = await dbHelper.registerUser(user);

      // Initial stats
      var stats = await dbHelper.getGalleryStats(userId);
      expect(stats.totalArtworks, 0);
      expect(stats.favoriteArtworks, 0);
      expect(stats.totalCategories, 0);

      // Add 2 artworks of different categories
      final art1Id = await dbHelper.insertArtwork(
        Artwork(
          title: 'Piece A',
          artist: 'Artist A',
          year: '2024',
          category: 'Abstract',
          description: 'Desc A',
          createdBy: userId,
        ),
      );

      final art2Id = await dbHelper.insertArtwork(
        Artwork(
          title: 'Piece B',
          artist: 'Artist B',
          year: '2025',
          category: 'Portrait',
          description: 'Desc B',
          createdBy: userId,
        ),
      );

      // Stats update automatically after artwork added
      stats = await dbHelper.getGalleryStats(userId);
      expect(stats.totalArtworks, 2);
      expect(stats.favoriteArtworks, 0);
      expect(stats.totalCategories, 2);

      // Task 12: Add to favorites
      final added1 = await dbHelper.addFavorite(userId, art1Id);
      expect(added1, isTrue);

      // Task 12: Prevent duplicate favorite
      final addedAgain = await dbHelper.addFavorite(userId, art1Id);
      expect(addedAgain, isFalse);

      // Check stats after favorite added
      stats = await dbHelper.getGalleryStats(userId);
      expect(stats.favoriteArtworks, 1);

      // Task 13: Favorite Artworks Screen list
      final favorites = await dbHelper.getFavoriteArtworks(userId);
      expect(favorites.length, 1);
      expect(favorites.first.id, art1Id);

      // Task 13: Remove favorite
      final removed = await dbHelper.removeFavorite(userId, art1Id);
      expect(removed, 1);

      // Stats update after favorite removed
      stats = await dbHelper.getGalleryStats(userId);
      expect(stats.favoriteArtworks, 0);

      // Task 9 & 14: Delete artwork and verify stats update
      await dbHelper.deleteArtwork(art2Id);
      stats = await dbHelper.getGalleryStats(userId);
      expect(stats.totalArtworks, 1);
      expect(stats.totalCategories, 1);
    });
  });
}
