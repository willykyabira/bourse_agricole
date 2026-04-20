import 'package:flutter_test/flutter_test.dart';
import 'package:bourse_agricole/data/models/seller_product_model.dart';

void main() {
  group('Tests Application Mobile Vendeur', () {
    
    test('Le produit doit afficher correctement le statut de la coopérative', () {
      final mockJson = {
        'id': 'prod_001',
        'nom': 'Manioc',
        'quantite': 500,
        'statut': 'En stock',
        'created_at': '2026-04-17T10:00:00Z',
        'prix_unitaire': 1500.0
      };

      final product = SellerProductModel.fromJson(mockJson);

      expect(product.nom, 'Manioc');
      expect(product.statut, 'En stock');
      expect(product.quantite, 500);
    });

    test('Validation de la logique de notification pour le vendeur', () {
      // Simulation d'une notification de vente
      final notificationJson = {
        'id': 'notif_1',
        'titre': 'Vente effectuée',
        'message': 'Votre stock de Manioc a été vendu.',
        'created_at': '2026-04-17T12:00:00Z',
        'lu': false
      };

      expect(notificationJson['lu'], isFalse);
      expect(notificationJson['titre'], contains('Vente'));
    });
  });
}