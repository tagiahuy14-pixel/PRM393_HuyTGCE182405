class User {
  final int? id;
  final String username;
  final String email;
  final String password;
  final String createdAt;

  User({
    this.id,
    required this.username,
    required this.email,
    required this.password,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'username': username,
      'email': email,
      'password': password,
      'createdAt': createdAt,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      username: map['username'] as String? ?? '',
      email: map['email'] as String? ?? '',
      password: map['password'] as String? ?? '',
      createdAt: map['createdAt'] as String? ?? '',
    );
  }

  User copyWith({
    int? id,
    String? username,
    String? email,
    String? password,
    String? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
