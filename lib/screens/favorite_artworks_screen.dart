import 'package:flutter/material.dart';

import '../models/artwork.dart';
import '../services/database_helper.dart';
import 'artwork_detail_screen.dart';

class FavoriteArtworksScreen extends StatefulWidget {
  final int userId;

  const FavoriteArtworksScreen({super.key, required this.userId});

  @override
  State<FavoriteArtworksScreen> createState() => _FavoriteArtworksScreenState();
}

class _FavoriteArtworksScreenState extends State<FavoriteArtworksScreen> {
  List<Artwork> _favoriteArtworks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final list = await DatabaseHelper.instance.getFavoriteArtworks(
        widget.userId,
      );
      if (mounted) {
        setState(() {
          _favoriteArtworks = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _removeFavorite(Artwork artwork) async {
    try {
      await DatabaseHelper.instance.removeFavorite(widget.userId, artwork.id!);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Removed "${artwork.title}" from favorites'),
          backgroundColor: const Color(0xFF00796B),
          duration: const Duration(seconds: 2),
        ),
      );

      _loadFavorites();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to remove: $e'),
          backgroundColor: const Color(0xFFC62828),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryTeal = Color(0xFF00796B);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Favorite Artworks',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: primaryTeal,
                strokeWidth: 2.5,
              ),
            )
          : _favoriteArtworks.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.favorite_border_rounded,
                        size: 40,
                        color: Colors.red.shade300,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No favorite artworks yet',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Mark your favorite pieces by tapping "Add to Favorite" on any artwork detail screen.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _favoriteArtworks.length,
              itemBuilder: (context, index) {
                final artwork = _favoriteArtworks[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2F1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFB2DFDB),
                          width: 1,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.palette_outlined,
                          color: primaryTeal,
                          size: 22,
                        ),
                      ),
                    ),
                    title: Text(
                      artwork.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    subtitle: Text(
                      '${artwork.artist} • ${artwork.year}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.favorite,
                        color: Color(0xFFE53935),
                        size: 24,
                      ),
                      tooltip: 'Remove from favorites',
                      onPressed: () => _removeFavorite(artwork),
                    ),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ArtworkDetailScreen(
                            artworkId: artwork.id!,
                            userId: widget.userId,
                          ),
                        ),
                      );
                      _loadFavorites();
                    },
                  ),
                );
              },
            ),
    );
  }
}
