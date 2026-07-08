import 'package:supabase_flutter/supabase_flutter.dart';

/// Implémentation des opérations d'authentification avec Supabase.
class SupabaseDatasourceImpl {

  /// Instance de Supabase.
  final SupabaseClient supabase;

  SupabaseDatasourceImpl(this.supabase);

  /// Créer un nouveau compte utilisateur.
  Future<void> signUp({
    required String email,
    required String password,
    required String nom,
    required String telephone,
    required String role,
  }) async {
    try {
      // Enregistrer l'utilisateur dans Supabase Auth.
      await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          // Informations enregistrées dans raw_user_meta_data.
          'nom_complet': nom,
          'telephone': telephone,
          'role': role,
        },
      );
    } on AuthException catch (e) {
      // Erreur renvoyée par Supabase.
      throw e.message;
    } catch (e) {
      // Erreur générale (réseau, serveur...).
      throw "Erreur de connexion. Vérifiez votre réseau à Bunia.";
    }
  }
}