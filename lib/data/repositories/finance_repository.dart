import '../supabase_client.dart';

class FinanceRepository {
  // Maintenant, SupabaseClientManager est reconnu grâce à l'import
  final _client = SupabaseClientManager.client;

  Future<List<Map<String, dynamic>>> getRevenueStats() async {
    // Récupération des données financières (montant et acheteur) [cite: 62, 70]
    final response = await _client.from('commandes').select('''
      montant_total,
      acheteurs (nom, prenom)
    '''); 
    return response;
  }
}