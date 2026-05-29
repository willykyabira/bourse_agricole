import 'package:bourse_agricole/core/resultat/resultat.dart';
import 'package:bourse_agricole/features/domain/repositories/produit_repository.dart';

class ConsulterEtatStock {
  final ProduitRepository repository;

  ConsulterEtatStock({required this.repository});

  /// Dans la BAN, on ne cherche plus par 'numeroSerie' mais par 'idProduit'.
  /// Ce Use Case permet de voir si le produit est toujours disponible, 
  /// sa quantité restante et les détails du vendeur.
  FutureResultat call(String idProduit) {
    return repository.consulterDetailProduit(idProduit);
  }
}