class UserModel {
  final String id;
  final String email;
  final String name;
  final UserRole role;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.role = UserRole.user,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      role: UserRole.values.firstWhere(
        (role) => role.toString() == json['role'],
        orElse: () => UserRole.user,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email, 'name': name, 'role': role.toString()};
  }
}

enum UserRole { admin, user }
