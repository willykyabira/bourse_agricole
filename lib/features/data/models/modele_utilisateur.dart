// Modèle représentant un utilisateur de l'application.

/// Les différents rôles disponibles.
enum UserRole {
  admin,
  acheteur,
  vendeur,
}

class UserModel {
  /// Identifiant unique de l'utilisateur.
  final String id;

  /// Nom complet.
  final String nomComplet;

  /// Adresse e-mail.
  final String email;

  /// Rôle de l'utilisateur.
  final UserRole role;

  UserModel({
    required this.id,
    required this.nomComplet,
    required this.email,
    required this.role,
  });
}