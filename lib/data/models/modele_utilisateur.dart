enum UserRole { acheteur, vendeur, gestionnaire, finance, admin }

class ModeleUtilisateur {
  final String id;
  final String email;
  final UserRole role;

  ModeleUtilisateur({required this.id, required this.email, required this.role});

  factory ModeleUtilisateur.fromMetadata(Map<String, dynamic> metadata, String id, String email) {
    return ModeleUtilisateur(
      id: id,
      email: email,
      role: UserRole.values.firstWhere(
        (e) => e.name == (metadata['role'] ?? 'vendeur'),
        orElse: () => UserRole.vendeur,
      ),
    );
  }
}