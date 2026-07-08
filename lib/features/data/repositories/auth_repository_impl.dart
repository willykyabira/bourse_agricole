import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bourse_agricole/features/domain/repositories/auth_repository.dart';

/// Implémentation du repository d'authentification avec Supabase.
class AuthRepositoryImpl implements AuthRepository {

  /// Instance de Supabase.
  final SupabaseClient supabaseClient;

  AuthRepositoryImpl(this.supabaseClient);

  @override
  Future<void> signUp({
    required String email,
    required String password,
    required String nom,
    required String telephone,
    required String role,
  }) async {
    try {
      // Créer un nouveau compte utilisateur.
      await supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {
          'nom_complet': nom,
          'telephone': telephone,
          'role': role,
        },
      );
    } catch (e) {
      // Retourner le message d'erreur.
      throw e.toString();
    }
  }

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Connecter un utilisateur existant.
      await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      // Retourner le message d'erreur.
      throw e.toString();
    }
  }
}