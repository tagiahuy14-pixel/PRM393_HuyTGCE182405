import 'package:flutter/material.dart';

import '../controllers/library_controller.dart';
import '../models/song.dart';
import '../theme.dart';
import '../widgets/app_feedback.dart';
import '../widgets/content_width.dart';
import '../widgets/song_tile.dart';
import 'edit_song_screen.dart';

class SongDetailScreen extends StatefulWidget {
  const SongDetailScreen({
    super.key,
    required this.library,
    required this.songId,
  });
  final LibraryController library;
  final int songId;
  @override
  State<SongDetailScreen> createState() => _SongDetailScreenState();
}

class _SongDetailScreenState extends State<SongDetailScreen> {
  bool _busy = false;

  Future<void> _edit(Song song) async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    final saved = await Navigator.push<Song>(
      context,
      MaterialPageRoute(
        builder: (_) => EditSongScreen(library: widget.library, song: song),
      ),
    );
    if (mounted && saved != null) {
      showMessage(context, 'Song updated successfully');
    }
  }

  Future<void> _favorite() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final updated = await widget.library.toggleFavorite(widget.songId);
      if (mounted) {
        showMessage(
          context,
          updated.favorite ? 'Added to favorites' : 'Removed from favorites',
        );
      }
    } catch (error) {
      if (mounted) {
        showMessage(
          context,
          'Could not update favorites. Please try again.',
          error: true,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete(Song song) async {
    if (_busy) return;
    setState(() => _busy = true);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete song?'),
        content: Text(
          'Are you sure you want to delete "${song.title}"? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('confirm-delete'),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (confirmed != true) {
      setState(() => _busy = false);
      return;
    }
    try {
      await widget.library.delete(widget.songId);
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        showMessage(
          context,
          'Could not delete this song. Please try again.',
          error: true,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.library,
    builder: (context, child) {
      final song = widget.library.find(widget.songId);
      final blocked = _busy || widget.library.writing || widget.library.loading;
      return PopScope(
        canPop: !_busy,
        child: Scaffold(
          appBar: AppBar(title: const Text('Song details')),
          body: SafeArea(
            child: ContentWidth(
              maxWidth: 650,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                child: song == null
                    ? const Text('This song is no longer available.')
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            height: 190,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF2E395D), Color(0xFF7562DD)],
                              ),
                            ),
                            child: Icon(
                              genreIcon(song.genre),
                              size: 86,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            song.title,
                            style: const TextStyle(
                              color: ink,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            song.artist,
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                children: [
                                  _info(Icons.tag, 'Song ID', '#${song.id}'),
                                  const Divider(height: 26),
                                  _info(
                                    Icons.calendar_today_outlined,
                                    'Release year',
                                    song.year,
                                  ),
                                  const Divider(height: 26),
                                  _info(
                                    Icons.category_outlined,
                                    'Genre',
                                    song.genre,
                                  ),
                                  const Divider(height: 26),
                                  _info(
                                    Icons.favorite_border,
                                    'Favorite',
                                    song.favorite ? 'Yes' : 'No',
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          FilledButton.icon(
                            key: const Key('detail-favorite'),
                            onPressed: blocked ? null : _favorite,
                            style: FilledButton.styleFrom(
                              backgroundColor: song.favorite
                                  ? favoriteColor
                                  : accent,
                            ),
                            icon: Icon(
                              song.favorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                            ),
                            label: Text(
                              song.favorite
                                  ? 'Remove from favorites'
                                  : 'Add to favorites',
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            key: const Key('edit-song'),
                            onPressed: blocked ? null : () => _edit(song),
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text('Edit song'),
                          ),
                          const SizedBox(height: 12),
                          TextButton.icon(
                            key: const Key('delete-song'),
                            onPressed: blocked ? null : () => _delete(song),
                            style: TextButton.styleFrom(
                              foregroundColor: Theme.of(context)
                                  .colorScheme
                                  .error,
                            ),
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Delete song'),
                          ),
                          if (widget.library.writing)
                            const LinearProgressIndicator(),
                        ],
                      ),
              ),
            ),
          ),
        ),
      );
    },
  );

  Widget _info(IconData icon, String label, String value) => Row(
    children: [
      Icon(icon, size: 21, color: accent),
      const SizedBox(width: 12),
      Expanded(
        child: Text(label, style: const TextStyle(color: Colors.black54)),
      ),
      const SizedBox(width: 12),
      Flexible(
        child: Text(
          value,
          textAlign: TextAlign.right,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    ],
  );
}
