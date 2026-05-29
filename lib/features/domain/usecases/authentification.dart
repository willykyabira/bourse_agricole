import 'package:bourse_agricole/features/domain/repositories/auth_repository.dart';

class Authentifier {
  final AuthRepository repository;
  Authentifier({required this.repository});

  Future<void> call(String email, String motDePasse) async {
    return await repository.signIn(email: email, password: motDePasse);
  }
}

class Enregistrer {
  final AuthRepository repository;
  Enregistrer({required this.repository});

  Future<void> call({
    required String email,
    required String password,
    required String nom,
    required String telephone,
    required String role,
  }) async {
    return await repository.signUp(
      email: email,
      password: password,
      nom: nom,
      telephone: telephone,
      role: role,
    );
  }
}