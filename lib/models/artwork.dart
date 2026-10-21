class Artwork {
  final int? id;
  final String title;
  final String artist;
  final String year;
  final String category;
  final String description;
  final int createdBy;

  Artwork({
    this.id,
    required this.title,
    required this.artist,
    required this.year,
    required this.category,
    required this.description,
    required this.createdBy,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'title': title,
      'artist': artist,
      'year': year,
      'category': category,
      'description': description,
      'createdBy': createdBy,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory Artwork.fromMap(Map<String, dynamic> map) {
    return Artwork(
      id: map['id'] as int?,
      title: map['title'] as String? ?? '',
      artist: map['artist'] as String? ?? '',
      year: map['year']?.toString() ?? '',
      category: map['category'] as String? ?? '',
      description: map['description'] as String? ?? '',
      createdBy: map['createdBy'] as int? ?? 0,
    );
  }

  Artwork copyWith({
    int? id,
    String? title,
    String? artist,
    String? year,
    String? category,
    String? description,
    int? createdBy,
  }) {
    return Artwork(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      year: year ?? this.year,
      category: category ?? this.category,
      description: description ?? this.description,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}
