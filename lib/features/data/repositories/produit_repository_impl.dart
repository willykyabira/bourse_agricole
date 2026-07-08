import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bourse_agricole/features/domain/repositories/auth_repository.dart';

/// Implémentation du repository d'authentification avec Supabase.
class AuthRepositoryImpl implements AuthRepository {

  /// Instance de Supabase.
  final SupabaseClient _supabase;

  AuthRepositoryImpl(this._supabase);

  @override
  Future<void> signUp({
    required String email,
    required String password,
    required String nom,
    required String telephone,
    required String role,
  }) async {
    try {
      // Création du compte utilisateur.
      await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'nom_complet': nom,
          'telephone': telephone,
          'role': role,
        },
      );
    } catch (e) {
      // Retourne le message d'erreur.
      throw e.toString();
    }
  }

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    // Connexion avec l'email et le mot de passe.
    await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }
}