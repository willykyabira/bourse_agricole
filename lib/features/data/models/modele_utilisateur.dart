// lib/data/models/modele_utilisateur.dart

enum UserRole { admin, acheteur, vendeur }

class UserModel {
  final String id;
  final String nomComplet;
  final String email;
  final UserRole role;

  UserModel({
    required this.id,
    required this.nomComplet,
    required this.email,
    required this.role,
  });
}