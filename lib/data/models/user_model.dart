enum UserRole { acheteur, vendeur, gestionnaire, finance, admin }

class UserModel {
  final String id;
  final String email;
  final UserRole role;

  UserModel({required this.id, required this.email, required this.role});

  factory UserModel.fromMetadata(Map<String, dynamic> metadata, String id, String email) {
    return UserModel(
      id: id,
      email: email,
      role: UserRole.values.firstWhere(
        (e) => e.name == (metadata['role'] ?? 'vendeur'),
        orElse: () => UserRole.vendeur,
      ),
    );
  }
}