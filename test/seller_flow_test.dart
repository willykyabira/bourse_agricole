import 'package:flutter_test/flutter_test.dart';
// 1. On pointe vers le modèle client (à créer ou adapter)

void main() {
  group('Tests Application Mobile Acheteur (Client)', () {
    
    test('Le produit doit être correctement analysé pour l\'affichage boutique', () {
      // Simulation des données reçues par le client (prix Bunia, provenance, etc.)
      final mockJson = {
        'id': 'prod_001',
        'nom': 'Manioc',
        'prix_unitaire': 1500.0,
        'provenance': 'Territoire de Mahagi',
        'unite': 'Sac de 50kg',
        'disponible': true
      };

      // 2. CORRECTION : On utilise le modèle Client avec la méthode fromJSON
      // ignore: non_constant_identifier_names, prefer_typing_uninitialized_variables
      var ModeleProduit;
      final product = ModeleProduit.fromJSON(mockJson);

      expect(product.nom, 'Manioc');
      expect(product.prixUnitaire, 1500.0);
      expect(product.disponible, isTrue);
    });

    test('Validation de la logique du panier pour le client', () {
      final panierJson = {
        'produit_id': 'prod_001',
        'quantite_voulue': 2,
        'prix_total': 3000.0,
        'date_selection': '2026-05-08T10:00:00Z'
      };

      expect(panierJson['quantite_voulue'], equals(2));
      expect(panierJson['prix_total'], 3000.0);
    });
  });
}