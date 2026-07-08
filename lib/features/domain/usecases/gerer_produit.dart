import 'package:bourse_agricole/core/resultat/resultat.dart';
import 'package:bourse_agricole/features/domain/repositories/produit_repository.dart';

/// Cas d'utilisation permettant d'ajouter un produit.
class AjouterProduit {
  final ProduitRepository repository;

  AjouterProduit({
    required this.repository,
  });

  /// Enregistre un nouveau produit.
  FutureResultat call(Map<String, dynamic> produitData) {
    return repository.ajouterProduit(produitData);
  }
}

/// Cas d'utilisation permettant de supprimer un produit.
class SupprimerProduit {
  final ProduitRepository repository;

  SupprimerProduit({
    required this.repository,
  });

  /// Supprime un produit à partir de son identifiant.
  FutureResultat call(String idProduit) {
    return repository.supprimerProduit(idProduit);
  }
}

/// Cas d'utilisation permettant de consulter les produits.
class ConsulterProduits {
  final ProduitRepository repository;

  ConsulterProduits({
    required this.repository,
  });

  /// Retourne la liste des produits disponibles.
  FutureResultat call() {
    return repository.consulterListeProduits();
  }
}