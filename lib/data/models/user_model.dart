enum UserRole { vendeur, acheteur, gestionnaire, finance, admin }

class UserModel {
  final String id;
  final String email;
  final UserRole role;

  UserModel({required this.id, required this.email, required this.role});

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'],
    email: json['email'],
    role: UserRole.values.firstWhere((e) => e.name == json['role']),
  );
}
