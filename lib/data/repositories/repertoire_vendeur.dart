import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/modele_produit_vendeur.dart';
import '../models/modele_notification.dart';

class RepertoireVendeur {
  final SupabaseClient _supabase = Supabase.instance.client;

  // CAS 1: Consulter les informations de ses produits (Manioc, etc.)
  Future<List<ModeleProduitVendeur>> getMyProducts(String sellerId) async {
    final response = await _supabase
        .from('products')
        .select()
        .eq('vendeur_id', sellerId); // Filtrer par l'ID du vendeur
    
    return (response as List)
        .map((json) => ModeleProduitVendeur.fromJson(json))
        .toList();
  }

  // CAS 2: Consulter les notifications (Alertes de vente ou de réception)
  Future<List<ModeleNotification>> getMyNotifications(String sellerId) async {
    final response = await _supabase
        .from('notifications')
        .select()
        .eq('user_id', sellerId)
        .order('created_at', ascending: false);
    
    return (response as List)
        .map((json) => ModeleNotification.fromJson(json))
        .toList();
  }
}