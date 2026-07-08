import 'package:bourse_agricole/features/domain/repositories/auth_repository.dart';

/// Cas d'utilisation permettant de connecter un utilisateur.
class Authentifier {
  final AuthRepository repository;

  Authentifier({
    required this.repository,
  });

  Future<void> call(String email, String motDePasse) {
    return repository.signIn(
      email: email,
      password: motDePasse,
    );
  }
}

/// Cas d'utilisation permettant de créer un nouveau compte.
class Enregistrer {
  final AuthRepository repository;

  Enregistrer({
    required this.repository,
  });

  Future<void> call({
    required String email,
    required String password,
    required String nom,
    required String telephone,
    required String role,
  }) {
    return repository.signUp(
      email: email,
      password: password,
      nom: nom,
      telephone: telephone,
      role: role,
    );
  }
}