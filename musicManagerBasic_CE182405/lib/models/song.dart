class Song {
  const Song({
    this.id,
    required this.title,
    required this.artist,
    required this.year,
    required this.genre,
    this.isFavorite = 0,
  });

  static const genres = ['Pop', 'Rock', 'EDM', 'Ballad'];

  final int? id;
  final String title;
  final String artist;
  final String year;
  final String genre;
  final int isFavorite;

  bool get favorite => isFavorite == 1;

  Song copyWith({
    int? id,
    String? title,
    String? artist,
    String? year,
    String? genre,
    int? isFavorite,
  }) => Song(
    id: id ?? this.id,
    title: title ?? this.title,
    artist: artist ?? this.artist,
    year: year ?? this.year,
    genre: genre ?? this.genre,
    isFavorite: isFavorite ?? this.isFavorite,
  );

  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'title': title,
    'artist': artist,
    'year': year,
    'genre': genre,
    'isFavorite': isFavorite,
  };

  factory Song.fromMap(Map<String, Object?> map) => Song(
    id: map['id'] as int,
    title: map['title'] as String,
    artist: map['artist'] as String,
    year: map['year'] as String,
    genre: map['genre'] as String,
    isFavorite: map['isFavorite'] as int,
  );
}
