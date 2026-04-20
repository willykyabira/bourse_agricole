import '../supabase_client.dart';

class RepertoireAuthentification {
  final _supabase = SupabaseClientManager.client;

  Future<void> signIn(String email, String password) async {
    await _supabase.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signUp(String email, String password, String name, String role) async {
    // On s'assure que le rôle envoyé est exactement celui attendu par le type app_role
    await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': name,
        'role': role, 
      },
    );
  }

  Future<String> getUserRole(String userId) async {
    final response = await _supabase
        .from('profiles')
        .select('role')
        .eq('id', userId)
        .single();
    return response['role'] as String;
  }
}