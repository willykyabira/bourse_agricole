import 'package:supabase_flutter/supabase_flutter.dart';

class FinanceRepository {
  final _supabase = Supabase.instance.client;

  // Récupérer le total des revenus des commandes validées
  Future<double> getTotalRevenue() async {
    final response = await _supabase
        .from('orders')
        .select('total_price');
    
    double total = 0;
    for (var item in response) {
      total += (item['total_price'] ?? 0).toDouble();
    }
    return total;
  }
}
