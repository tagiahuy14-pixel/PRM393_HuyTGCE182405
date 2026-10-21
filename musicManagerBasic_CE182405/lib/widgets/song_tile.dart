import 'package:flutter/material.dart';

import '../models/song.dart';
import '../theme.dart';

IconData genreIcon(String genre) => switch (genre) {
  'Rock' => Icons.electric_bolt,
  'EDM' => Icons.graphic_eq,
  'Ballad' => Icons.piano,
  _ => Icons.music_note_rounded,
};

class SongTile extends StatelessWidget {
  const SongTile({
    super.key,
    required this.song,
    required this.onTap,
    this.onFavorite,
    this.busy = false,
  });
  final Song song;
  final VoidCallback onTap;
  final VoidCallback? onFavorite;
  final bool busy;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFEDE9FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(genreIcon(song.genre), color: accent, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: const TextStyle(
                      color: ink,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    song.artist,
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${song.year} · ${song.genre}',
                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              key: ValueKey('favorite-${song.id}'),
              onPressed: busy ? null : onFavorite,
              tooltip: song.favorite
                  ? 'Remove from favorites'
                  : 'Add to favorites',
              icon: Icon(
                song.favorite ? Icons.favorite : Icons.favorite_border,
                color: song.favorite ? favoriteColor : Colors.black38,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
