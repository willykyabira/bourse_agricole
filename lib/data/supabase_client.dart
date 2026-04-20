import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseClientManager {
  // Le nom de la classe doit bien être SupabaseClientManager
  static SupabaseClient get client => Supabase.instance.client;

  static User? get currentUser => client.auth.currentUser;
}