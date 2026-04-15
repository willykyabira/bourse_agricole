import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final _client = Supabase.instance.client;

  Future<AuthResponse> login(String email, String password) async {
    return await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<String> getUserRole(String userId) async {
    final data = await _client.from('profiles').select('role').eq('id', userId).single();
    return data['role'];
  }
}
