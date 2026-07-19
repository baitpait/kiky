class UserModel {
  UserModel({
    required this.id,
    required this.username,
    required this.role,
    required this.name,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    return UserModel(
      id: id is int ? id : (id as num).toInt(),
      username: json['username'] as String,
      role: json['role'] as String,
      name: json['name'] as String,
    );
  }

  final int id;
  final String username;
  final String role;
  final String name;

  bool get isAdmin => role == 'admin';
  bool get isTeacher => role == 'teacher';
  bool get isParent => role == 'parent';
}

class AuthTokens {
  AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  final String accessToken;
  final String refreshToken;
  final UserModel user;
}
