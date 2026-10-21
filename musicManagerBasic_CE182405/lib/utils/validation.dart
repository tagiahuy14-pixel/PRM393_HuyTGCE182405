import '../models/song.dart';

class Validation {
  static String? requiredText(String? value, String field) {
    if (value == null || value.trim().isEmpty) return 'Please enter $field';
    if (value.trim().length > 120) return 'Use at most 120 characters';
    return null;
  }

  static String? year(String? value, {int? currentYear}) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Please enter a release year';
    final number = int.tryParse(text);
    final latest = currentYear ?? DateTime.now().year;
    if (!RegExp(r'^\d{4}$').hasMatch(text) ||
        number == null ||
        number < 1000 ||
        number > latest) {
      return 'Enter a four-digit year from 1000 to $latest';
    }
    return null;
  }

  static void song(Song song) {
    if (requiredText(song.title, 'a title') != null ||
        requiredText(song.artist, 'an artist') != null ||
        year(song.year) != null ||
        !Song.genres.contains(song.genre) ||
        (song.isFavorite != 0 && song.isFavorite != 1)) {
      throw ArgumentError('Invalid song information');
    }
  }
}
