import 'package:bourse_agricole/core/resultat/resultat.dart';
import 'package:bourse_agricole/features/domain/repositories/produit_repository.dart';

/// Cas d'utilisation permettant de consulter l'état d'un produit en stock.
class ConsulterEtatStock {
  final ProduitRepository repository;

  ConsulterEtatStock({
    required this.repository,
  });

  /// Retourne les informations d'un produit à partir de son identifiant.
  FutureResultat call(String idProduit) {
    return repository.consulterDetailProduit(idProduit);
  }
}