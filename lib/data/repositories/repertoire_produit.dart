import '../supabase_client.dart';

class RepertoireProduit {
  // Utilisation du nom correct : SupabaseClientManager
  final _db = SupabaseClientManager.client;

  // Stream pour l'acheteur (Produits publiés)
  Stream<List<Map<String, dynamic>>> getAvailableProducts() {
    return _db
        .from('produits') // Nom de la table mis à jour selon votre SQL 
        .stream(primaryKey: ['id'])
        .eq('est_publie', true) // Filtre de publication [cite: 33]
        .order('nom');
  }

  // Ajout pour le gestionnaire de stock [cite: 28]
  Future<void> addProduct(Map<String, dynamic> data) async {
    await _db.from('produits').insert(data);
  }
}