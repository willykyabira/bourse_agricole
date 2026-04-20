import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/seller_product_model.dart';
import '../models/notification_model.dart';

class SellerRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // CAS 1: Consulter les informations de ses produits (Manioc, etc.)
  Future<List<SellerProductModel>> getMyProducts(String sellerId) async {
    final response = await _supabase
        .from('products')
        .select()
        .eq('vendeur_id', sellerId); // Filtrer par l'ID du vendeur
    
    return (response as List)
        .map((json) => SellerProductModel.fromJson(json))
        .toList();
  }

  // CAS 2: Consulter les notifications (Alertes de vente ou de réception)
  Future<List<NotificationModel>> getMyNotifications(String sellerId) async {
    final response = await _supabase
        .from('notifications')
        .select()
        .eq('user_id', sellerId)
        .order('created_at', ascending: false);
    
    return (response as List)
        .map((json) => NotificationModel.fromJson(json))
        .toList();
  }
}