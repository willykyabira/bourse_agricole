/// Contrat que toute implémentation d'authentification doit respecter.
abstract class AuthRepository {

  /// Créer un nouveau compte utilisateur.
  Future<void> signUp({
    required String email,
    required String password,
    required String nom,
    required String telephone,
    required String role,
  });

  /// Connecter un utilisateur existant.
  Future<void> signIn({
    required String email,
    required String password,
  });
}