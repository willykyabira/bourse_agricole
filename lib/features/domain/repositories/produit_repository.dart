import 'package:bourse_agricole/core/resultat/resultat.dart';

/// Contrat que toute implémentation du repository devra respecter.
abstract class ProduitRepository {

  // ================= AUTHENTIFICATION =================

  /// Connecter un utilisateur.
  FutureResultat authentifier(
    String email,
    String motDePasse,
  );

  /// Créer un nouveau compte utilisateur.
  FutureResultat enregistrer({
    required String email,
    required String nomComplet,
    required String motDePasse,
    required String role,
  });

  // ================= PRODUITS =================

  /// Ajouter un produit.
  FutureResultat ajouterProduit(
    Map<String, dynamic> produitData,
  );

  /// Supprimer un produit.
  FutureResultat supprimerProduit(
    String id,
  );

  /// Obtenir tous les produits.
  FutureResultat consulterListeProduits();

  /// Consulter un produit précis.
  FutureResultat consulterDetailProduit(
    String id,
  );

  /// Rechercher des produits.
  FutureResultat rechercherProduits(
    String query,
  );

  // ================= COMMANDES =================

  /// Créer une nouvelle commande.
  FutureResultat creerCommande(
    Map<String, dynamic> donneesCommande,
  );
}