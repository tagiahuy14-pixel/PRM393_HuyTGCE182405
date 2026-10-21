class Favorite {
  final int? id;
  final int userId;
  final int artworkId;
  final String createdAt;

  Favorite({
    this.id,
    required this.userId,
    required this.artworkId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'userId': userId,
      'artworkId': artworkId,
      'createdAt': createdAt,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory Favorite.fromMap(Map<String, dynamic> map) {
    return Favorite(
      id: map['id'] as int?,
      userId: map['userId'] as int? ?? 0,
      artworkId: map['artworkId'] as int? ?? 0,
      createdAt: map['createdAt'] as String? ?? '',
    );
  }
}
