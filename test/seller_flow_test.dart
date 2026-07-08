import 'package:flutter_test/flutter_test.dart';

/// ======================================================================
/// TESTS DE L'APPLICATION MOBILE - BOURSE AGRICOLE NUMÉRIQUE (BAN)
/// ----------------------------------------------------------------------
/// Ces tests vérifient quelques règles simples utilisées dans
/// l'application côté client (Acheteur).
///
/// Remarque :
/// Lorsque votre classe Produit (ou ModeleProduit) sera créée,
/// vous pourrez remplacer les tests sur le JSON par des tests
/// directement sur votre modèle.
/// ======================================================================

void main() {
  group('Tests Application Mobile Acheteur', () {
    //--------------------------------------------------------------------
    // Test 1 : Vérifier les données d'un produit
    //--------------------------------------------------------------------
    test('Les informations du produit sont correctes', () {
      // Données simulées provenant de Supabase.
      final produit = {
        'id': 'prod_001',
        'nom': 'Manioc',
        'prix_unitaire': 1500.0,
        'provenance': 'Territoire de Mahagi',
        'unite': 'Sac de 50kg',
        'disponible': true,
      };

      expect(produit['id'], equals('prod_001'));
      expect(produit['nom'], equals('Manioc'));
      expect(produit['prix_unitaire'], equals(1500.0));
      expect(produit['provenance'], equals('Territoire de Mahagi'));
      expect(produit['unite'], equals('Sac de 50kg'));
      expect(produit['disponible'], isTrue);
    });

    //--------------------------------------------------------------------
    // Test 2 : Vérifier les données du panier
    //--------------------------------------------------------------------
    test('Le panier contient les bonnes informations', () {
      final panier = {
        'produit_id': 'prod_001',
        'quantite_voulue': 2,
        'prix_total': 3000.0,
        'date_selection': '2026-05-08T10:00:00Z',
      };

      expect(panier['produit_id'], equals('prod_001'));
      expect(panier['quantite_voulue'], equals(2));
      expect(panier['prix_total'], equals(3000.0));
      expect(panier['date_selection'], isNotNull);
    });

    //--------------------------------------------------------------------
    // Test 3 : Vérifier qu'un prix est valide
    //--------------------------------------------------------------------
    test('Le prix doit être supérieur à zéro', () {
      const prix = 1500.0;

      expect(prix, greaterThan(0));
    });

    //--------------------------------------------------------------------
    // Test 4 : Vérifier qu'une quantité est valide
    //--------------------------------------------------------------------
    test('La quantité doit être supérieure à zéro', () {
      const quantite = 5;

      expect(quantite, greaterThan(0));
    });

    //--------------------------------------------------------------------
    // Test 5 : Vérifier qu'un produit est disponible
    //--------------------------------------------------------------------
    test('Le produit est disponible', () {
      const disponible = true;

      expect(disponible, isTrue);
    });

    //--------------------------------------------------------------------
    // Test 6 : Vérifier le calcul du montant total
    //--------------------------------------------------------------------
    test('Le montant total est correctement calculé', () {
      const prixUnitaire = 1500.0;
      const quantite = 2;

      final total = prixUnitaire * quantite;

      expect(total, equals(3000.0));
    });

    //--------------------------------------------------------------------
    // Test 7 : Vérifier le nom du produit
    //--------------------------------------------------------------------
    test('Le nom du produit ne doit pas être vide', () {
      const nomProduit = 'Manioc';

      expect(nomProduit.isNotEmpty, isTrue);
    });

    //--------------------------------------------------------------------
    // Test 8 : Vérifier l'identifiant du produit
    //--------------------------------------------------------------------
    test('Chaque produit possède un identifiant', () {
      const id = 'prod_001';

      expect(id.startsWith('prod_'), isTrue);
    });
  });
}