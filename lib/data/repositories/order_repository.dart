import 'package:supabase_flutter/supabase_flutter.dart';

class OrderRepository {
  final _supabase = Supabase.instance.client;

  Future<void> createOrder(String productId, double quantity) async {
    final userId = _supabase.auth.currentUser!.id;
    await _supabase.from('orders').insert({
      'acheteur_id': userId,
      'produit_id': productId,
      'quantite_commandee': quantity,
    });
  }

  Future<void> requestNewProduct(String name, String details) async {
    final userId = _supabase.auth.currentUser!.id;
    await _supabase.from('special_requests').insert({
      'user_id': userId,
      'product_name': name,
      'details': details,
    });
  }
}
