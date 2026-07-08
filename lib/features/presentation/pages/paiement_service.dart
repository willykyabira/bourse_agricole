import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentService {
  final _supabase = Supabase.instance.client;

  Future<void> initierPaiement({
    required double montant,
    required String numeroClient, // Doit correspondre à l'appel
    required String transactionId, // Doit correspondre à l'appel
    required String operateur,     // Doit correspondre à l'appel
    required String devise,        // Doit correspondre à l'appel
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'initier-paiement', // Nom de votre Edge Function dans Supabase
        body: {
          'montant': montant,
          'telephone': numeroClient,
          'commandeId': transactionId,
          'reseau': operateur,
          'devise': devise,
        },
      );

      if (response.status == 200) {
        // ignore: avoid_print
        print("Paiement initié avec succès");
      } else {
        // Lance une erreur si le serveur répond autre chose que 200
        throw Exception("Erreur PawaPay: ${response.data}");
      }
    } catch (e) {
      // Re-lance l'erreur pour qu'elle soit capturée par le catch dans PaiementPage
      rethrow; 
    }
  }
}