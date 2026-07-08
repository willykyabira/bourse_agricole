import 'package:bourse_agricole/core/resultat/resultat.dart';
import 'package:bourse_agricole/features/domain/repositories/produit_repository.dart';

/// Cas d'utilisation permettant d'obtenir la liste des produits.
class ConsulterListeProduits {
  final ProduitRepository repository;

  ConsulterListeProduits({
    required this.repository,
  });

  /// Retourne la liste des produits disponibles.
  FutureResultat call() {
    return repository.consulterListeProduits();
  }
}

/// Cas d'utilisation permettant de rechercher un produit.
class RechercherProduits {
  final ProduitRepository repository;

  RechercherProduits({
    required this.repository,
  });

  /// Recherche un produit à partir d'un mot-clé.
  FutureResultat call(String query) {
    return repository.rechercherProduits(query);
  }
}