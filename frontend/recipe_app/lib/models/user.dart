class User {
  final String id;
  final String email;
  final String username;
  final bool isVegetarian;
  final DateTime createdAt;
  final String? token;

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.isVegetarian,
    required this.createdAt,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      email: json['email'],
      username: json['username'],
      isVegetarian: json['isVegetarian'] ?? json['is_vegetarian'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? json['created_at']),
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'isVegetarian': isVegetarian,
      'createdAt': createdAt.toIso8601String(),
      'token': token,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? username,
    bool? isVegetarian,
    DateTime? createdAt,
    String? token,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      isVegetarian: isVegetarian ?? this.isVegetarian,
      createdAt: createdAt ?? this.createdAt,
      token: token ?? this.token,
    );
  }
}
