import 'dart:async';

import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import '../controllers/library_controller.dart';
import '../models/song.dart';
import '../models/song_filter.dart';
import '../theme.dart';
import '../widgets/app_feedback.dart';
import '../widgets/content_width.dart';
import '../widgets/library_empty_state.dart';
import '../widgets/song_tile.dart';
import 'add_song_screen.dart';
import 'favorites_screen.dart';
import 'song_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.auth, required this.library});
  final AuthController auth;
  final LibraryController library;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _search = TextEditingController();
  String? _genre;
  YearFilter _year = YearFilter.all;

  @override
  void initState() {
    super.initState();
    unawaited(widget.library.refresh());
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _reset() => setState(() {
    _search.clear();
    _genre = null;
    _year = YearFilter.all;
  });

  Future<void> _add() async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    final saved = await Navigator.push<Song>(
      context,
      MaterialPageRoute(builder: (_) => AddSongScreen(library: widget.library)),
    );
    if (mounted && saved != null) {
      _reset();
      showMessage(context, 'Song added successfully');
    }
  }

  Future<void> _open(Song song) async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    final deleted = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            SongDetailScreen(library: widget.library, songId: song.id!),
      ),
    );
    if (mounted && deleted == true) {
      showMessage(context, 'Song deleted successfully');
    }
  }

  Future<void> _favorite(Song song) async {
    try {
      final updated = await widget.library.toggleFavorite(song.id!);
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
    }
  }

  Future<void> _logout() async {
    if (widget.auth.busy || widget.library.writing) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await widget.auth.logout();
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Logged out successfully')),
        );
    } catch (error) {
      if (mounted) {
        showMessage(
          context,
          'Could not clear your session. Please try again.',
          error: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.library,
    builder: (context, child) {
      final library = widget.library;
      final all = library.songs;
      final filter = SongFilter(
        query: _search.text,
        genre: _genre,
        year: _year,
      );
      final songs = filter.apply(all);
      final blocked = library.writing || library.loading || widget.auth.busy;
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Music library',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          actions: [
            IconButton(
              key: const Key('open-favorites'),
              tooltip: 'Favorite songs',
              icon: const Icon(Icons.favorite_border),
              onPressed: () => Navigator.push<void>(
                context,
                MaterialPageRoute(
                  builder: (_) => FavoritesScreen(library: library),
                ),
              ),
            ),
            IconButton(
              key: const Key('logout'),
              tooltip: 'Logout',
              onPressed: blocked ? null : _logout,
              icon: const Icon(Icons.logout),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: ContentWidth(
            child: Column(
              children: [
                if (library.loading) const LinearProgressIndicator(),
                if (library.error != null)
                  MaterialBanner(
                    content: Text(library.error!),
                    leading: const Icon(Icons.error_outline),
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
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
                      itemCount: songs.isEmpty ? 2 : songs.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return _header(
                            all.length,
                            songs.length,
                            library.favorites.length,
                          );
                        }
                        if (songs.isEmpty) {
                          if (library.loading || library.error != null) {
                            return const SizedBox.shrink();
                          }
                          return LibraryEmptyState(
                            title: filter.active
                                ? 'No songs match'
                                : 'Your library starts here',
                            message: filter.active
                                ? 'Try another title, artist, genre, or year.'
                                : 'Add your first song and start a collection you love.',
                            action: filter.active
                                ? OutlinedButton(
                                    onPressed: _reset,
                                    child: const Text('Clear filters'),
                                  )
                                : FilledButton.icon(
                                    onPressed: blocked ? null : _add,
                                    icon: const Icon(Icons.add),
                                    label: const Text('Add your first song'),
                                  ),
                          );
                        }
                        final song = songs[index - 1];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: SongTile(
                            key: ValueKey('song-${song.id}'),
                            song: song,
                            onTap: () => _open(song),
                            onFavorite: () => _favorite(song),
                            busy: blocked,
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
        floatingActionButton: FloatingActionButton.extended(
          key: const Key('add-song'),
          onPressed: blocked || library.error != null ? null : _add,
          backgroundColor: accent,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('Add song'),
        ),
      );
    },
  );

  Widget _header(int total, int shown, int favorites) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF28345A), Color(0xFF6554CB)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'YOUR COLLECTION',
              style: TextStyle(
                color: Colors.white70,
                letterSpacing: 2,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Good music,\nalways close.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 29,
                height: 1.15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              '$total ${total == 1 ? 'song' : 'songs'}   ·   $favorites ${favorites == 1 ? 'favorite' : 'favorites'}',
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      TextField(
        key: const Key('song-search'),
        controller: _search,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'Search title or artist',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _search.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Clear search',
                  onPressed: () => setState(() => _search.clear()),
                  icon: const Icon(Icons.close),
                ),
        ),
      ),
      const SizedBox(height: 16),
      LayoutBuilder(
        builder: (context, constraints) {
          final genre = _dropdown<String>(
            'Genre',
            'genre-filter',
            _genre ?? 'All genres',
            ['All genres', ...Song.genres],
            (value) =>
                setState(() => _genre = value == 'All genres' ? null : value),
          );
          final year = _dropdown<YearFilter>(
            'Year',
            'year-filter',
            _year,
            YearFilter.values,
            (value) => setState(() => _year = value),
            label: (value) => value.label,
          );
          return constraints.maxWidth < 450 ||
                  MediaQuery.textScalerOf(context).scale(14) > 21
              ? Column(children: [genre, const SizedBox(height: 12), year])
              : Row(
                  children: [
                    Expanded(child: genre),
                    const SizedBox(width: 14),
                    Expanded(child: year),
                  ],
                );
        },
      ),
      const SizedBox(height: 22),
      Row(
        children: [
          Expanded(
            child: Text(
              'Songs · $shown',
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: ink,
              ),
            ),
          ),
          if (_search.text.isNotEmpty ||
              _genre != null ||
              _year != YearFilter.all)
            TextButton(onPressed: _reset, child: const Text('Reset')),
        ],
      ),
      const SizedBox(height: 14),
    ],
  );

  Widget _dropdown<T>(
    String title,
    String key,
    T value,
    List<T> values,
    ValueChanged<T> onChanged, {
    String Function(T)? label,
  }) => InputDecorator(
    decoration: InputDecoration(
      labelText: title,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<T>(
        key: Key(key),
        value: value,
        isExpanded: true,
        items: values
            .map(
              (item) => DropdownMenuItem<T>(
                value: item,
                child: Text(label?.call(item) ?? '$item'),
              ),
            )
            .toList(),
        onChanged: (item) {
          if (item != null) onChanged(item);
        },
      ),
    ),
  );
}
