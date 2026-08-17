class UserModel {
  final int? id;
  final String name;
  final String username;
  final String? email;
  final String role;
  final String? createdAt;

  UserModel({
    this.id,
    required this.name,
    required this.username,
    this.email,
    required this.role,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      email: json['email'],
      role: json['role'] ?? 'kasir',
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'role': role,
      'created_at': createdAt,
    };
  }
}
