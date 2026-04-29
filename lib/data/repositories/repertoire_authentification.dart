// lib/data/repositories/repertoire_authentification.dart

import '../supabase_client.dart'; // Assurez-vous que le chemin est correct vers votre client Supabase

class RepertoireAuthentification {
  // Utilisation du client Supabase initialisé dans votre projet
  final _supabase = SupabaseClientManager.client;

  /// Connexion d'un utilisateur existant
  Future<void> signIn(String email, String password) async {
    try {
      await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Inscription d'un nouvel utilisateur (ou création par l'Admin)
  /// CRITIQUE : Les clés 'nom_complet' et 'role' doivent correspondre au Trigger SQL
  Future<void> signUp(String email, String password, String name, String role) async {
    try {
      await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'nom_complet': name, // Sera récupéré par : new.raw_user_meta_data->>'nom_complet'
          'role': role,        // Sera récupéré par : new.raw_user_meta_data->>'role'
        },
      );
    } catch (e) {
      // Si une erreur survient ici, c'est souvent lié aux politiques de sécurité (RLS) 
      // ou à une erreur 500 du Trigger SQL
      rethrow;
    }
  }

  /// Déconnexion de l'utilisateur actuel
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  /// Récupération du rôle de l'utilisateur connecté depuis la table 'profiles'
  Future<String> getUserRole(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('role')
          .eq('id', userId)
          .single();
      
      return response['role'] as String;
    } catch (e) {
      // Retourne un rôle par défaut ou lève une exception si le profil n'existe pas
      rethrow;
    }
  }

  /// Récupération du profil complet (Optionnel, utile pour afficher le nom de l'admin)
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      return response;
    } catch (e) {
      rethrow;
    }
  }
}