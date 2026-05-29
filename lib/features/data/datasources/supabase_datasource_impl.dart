import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseDatasourceImpl {
  final SupabaseClient supabase;
  SupabaseDatasourceImpl(this.supabase);

  Future<void> signUp({
    required String email,
    required String password,
    required String nom,
    required String telephone,
    required String role,
  }) async {
    try {
      await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'nom_complet': nom,       // Exactement comme dans ton SQL : new.raw_user_meta_data->>'nom_complet'
          'telephone': telephone,   // Exactement comme dans ton SQL : new.raw_user_meta_data->>'telephone'
          'role': role,             // "client"
        },
      );
    } on AuthException catch (e) {
      throw e.message;
    } catch (e) {
      throw "Erreur de connexion. Vérifiez votre réseau à Bunia.";
    }
  }
}