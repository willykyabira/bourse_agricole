import 'package:supabase_flutter/supabase_flutter.dart';

/// Service d'intégration PawaPay.
///
/// Deux méthodes principales :
/// - [creerPaymentPage] — Nouvelle Payment Page (recommandée)
/// - [verifierStatutPaiement] — Vérifier le statut après retour
/// - [initierPaiement] — Ancienne API Deposit (conservée pour compatibilité)
class PawaPayService {
  // ─────────────────────────────────────────────────────────────────
  // NOUVELLE INTÉGRATION : Payment Page
  // ─────────────────────────────────────────────────────────────────

  /// Crée une session Payment Page PawaPay.
  ///
  /// Retourne un [Map] contenant :
  /// - `redirectUrl` : URL à ouvrir dans le navigateur
  /// - `depositId`   : identifiant du dépôt pour suivi
  /// - `referenceCommande` : référence de la commande
  Future<Map<String, dynamic>> creerPaymentPage({
    required double montant,
    required String referenceCommande,
    String? raison,
  }) async {
    try {
      final FunctionResponse response = await Supabase.instance.client.functions
          .invoke(
            'pawa-payment-page',
            body: {
              'amount': montant,
              'referenceCommande': referenceCommande,
              'reason': raison,
            },
          );

      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      } else {
        return {'data': response.data};
      }
    } on FunctionException catch (e) {
      throw Exception('Erreur Payment Page [Statut ${e.status}]: ${e.details}');
    } catch (e) {
      throw Exception('Erreur de connexion inattendue : $e');
    }
  }

  /// Vérifie le statut d'un paiement PawaPay après retour de la Payment Page.
  ///
  /// Retourne un [Map] contenant notamment :
  /// - `status` : `COMPLETED`, `FAILED`, `PENDING`, etc.
  /// - `amount`, `currency`, `depositId`
  Future<Map<String, dynamic>> verifierStatutPaiement({
    required String depositId,
  }) async {
    try {
      final FunctionResponse response = await Supabase.instance.client.functions
          .invoke('pawa-status-check', body: {'depositId': depositId});

      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      } else {
        return {'status': 'UNKNOWN', 'data': response.data};
      }
    } on FunctionException catch (e) {
      throw Exception(
        'Erreur vérification statut [Statut ${e.status}]: ${e.details}',
      );
    } catch (e) {
      throw Exception('Erreur de connexion inattendue : $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // ANCIENNE INTÉGRATION : API Deposit directe (conservée)
  // ─────────────────────────────────────────────────────────────────

  /// @deprecated Utiliser [creerPaymentPage] à la place.
  Future<Map<String, dynamic>> initierPaiement({
    required double montant,
    required String telephone,
    required String referenceCommande,
    required String reseau,
    String devise = 'CDF',
  }) async {
    try {
      final FunctionResponse response = await Supabase.instance.client.functions
          .invoke(
            'pawa-payment-v2',
            body: {
              'amount': montant,
              'phoneNumber': telephone,
              'reference': referenceCommande,
              'operator': reseau,
              'currency': devise,
            },
          );

      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      } else {
        return {'data': response.data};
      }
    } on FunctionException catch (e) {
      throw Exception(
        'Erreur d\'exécution Supabase [Statut ${e.status}]: ${e.details}',
      );
    } catch (e) {
      throw Exception('Erreur de connexion inattendue : $e');
    }
  }
}
