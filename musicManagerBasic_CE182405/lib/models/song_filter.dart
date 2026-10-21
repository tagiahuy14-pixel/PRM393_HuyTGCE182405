import 'song.dart';

enum YearFilter {
  all('All years'),
  currentYear('Current year'),
  lastFiveYears('Last 5 years');

  const YearFilter(this.label);
  final String label;
}

class SongFilter {
  const SongFilter({this.query = '', this.genre, this.year = YearFilter.all});
  final String query;
  final String? genre;
  final YearFilter year;

  bool get active =>
      query.trim().isNotEmpty || genre != null || year != YearFilter.all;

  List<Song> apply(Iterable<Song> songs, {int? currentYear}) {
    final now = currentYear ?? DateTime.now().year;
    final keyword = query.trim().toLowerCase();
    return songs.where((song) {
      final releaseYear = int.tryParse(song.year);
      final searchMatches =
          song.title.toLowerCase().contains(keyword) ||
          song.artist.toLowerCase().contains(keyword);
      final genreMatches = genre == null || song.genre == genre;
      final yearMatches = switch (year) {
        YearFilter.all => true,
        YearFilter.currentYear => releaseYear == now,
        YearFilter.lastFiveYears =>
          releaseYear != null && releaseYear >= now - 4 && releaseYear <= now,
      };
      return searchMatches && genreMatches && yearMatches;
    }).toList();
  }
}
