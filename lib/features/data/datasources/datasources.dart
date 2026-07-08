import 'package:bourse_agricole/core/resultat/resultat.dart';

/// Contrat que toute source de données (Supabase, API...) doit respecter.
abstract class DatabaseDatasource {

  // ================= AUTHENTIFICATION =================

  /// Créer un nouveau compte utilisateur.
  FutureResultat enregistrer({
    required String email,
    required String nomComplet,
    required String motDePasse,
    required String role,
  });

  /// Connecter un utilisateur.
  FutureResultat authentifier(
    String email,
    String motDePasse,
  );

  // ================= PRODUITS =================

  /// Ajouter un produit.
  FutureResultat ajouterProduit(
    Map<String, dynamic> donneesProduit,
  );

  /// Obtenir la liste des produits.
  FutureResultat consulterListeProduits();

  /// Consulter les détails d'un produit.
  FutureResultat consulterDetailProduit(
    String idProduit,
  );

  /// Rechercher un produit par son nom.
  FutureResultat rechercherProduits(
    String nomProduit,
  );

  /// Supprimer un produit.
  FutureResultat supprimerProduit(
    String idProduit,
  );

  // ================= COMMANDES =================

  /// Créer une nouvelle commande.
  FutureResultat creerCommande(
    Map<String, dynamic> donneesCommande,
  );

  /// Consulter les commandes d'un utilisateur.
  FutureResultat consulterMesCommandes(
    String userId,
  );
}