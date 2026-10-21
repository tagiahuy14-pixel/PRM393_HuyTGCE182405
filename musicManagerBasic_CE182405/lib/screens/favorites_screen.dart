import 'package:flutter/material.dart';

import '../controllers/library_controller.dart';
import '../models/song.dart';
import '../theme.dart';
import '../widgets/app_feedback.dart';
import '../widgets/content_width.dart';
import '../widgets/library_empty_state.dart';
import '../widgets/song_tile.dart';
import 'song_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key, required this.library});
  final LibraryController library;

  Future<void> _remove(BuildContext context, Song song) async {
    try {
      await library.toggleFavorite(song.id!);
      if (context.mounted) showMessage(context, 'Removed from favorites');
    } catch (error) {
      if (context.mounted) {
        showMessage(
          context,
          'Could not update favorites. Please try again.',
          error: true,
        );
      }
    }
  }

  Future<void> _open(BuildContext context, Song song) async {
    final deleted = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => SongDetailScreen(library: library, songId: song.id!),
      ),
    );
    if (context.mounted && deleted == true) {
      showMessage(context, 'Song deleted successfully');
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: library,
    builder: (context, child) {
      final songs = library.favorites;
      return Scaffold(
        appBar: AppBar(title: const Text('Favorite songs')),
        body: SafeArea(
          child: ContentWidth(
            child: Column(
              children: [
                if (library.loading) const LinearProgressIndicator(),
                if (library.error != null)
                  MaterialBanner(
                    content: Text(library.error!),
                    actions: [
                      TextButton(
                        onPressed: library.refresh,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: library.refresh,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      itemCount: songs.isEmpty ? 2 : songs.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.favorite,
                                  color: favoriteColor,
                                  size: 36,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'On repeat, in your heart.',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 25,
                                    color: ink,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${songs.length} ${songs.length == 1 ? 'song' : 'songs'} you love',
                                  style: const TextStyle(color: Colors.black54),
                                ),
                              ],
                            ),
                          );
                        }
                        if (songs.isEmpty) {
                          return const LibraryEmptyState(
                            title: 'No favorites yet',
                            message: 'Tap the heart on a song to keep it here.',
                            icon: Icons.favorite_border,
                          );
                        }
                        final song = songs[index - 1];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: SongTile(
                            song: song,
                            onTap: () => _open(context, song),
                            onFavorite: () => _remove(context, song),
                            busy: library.loading || library.writing,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
