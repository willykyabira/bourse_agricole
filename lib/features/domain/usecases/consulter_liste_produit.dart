import 'package:bourse_agricole/core/resultat/resultat.dart';
import 'package:bourse_agricole/features/domain/repositories/produit_repository.dart';

class ConsulterListeProduits {
  final ProduitRepository repository;

  ConsulterListeProduits({required this.repository});

  // Cette méthode sera appelée par votre Bloc ou Provider 
  // pour afficher les articles sur le "Tableau de Bord" (Accueil)
  FutureResultat call() {
    return repository.consulterListeProduits();
  }
}

// Nous pouvons aussi ajouter le Use Case pour la recherche ici 
// car il est très similaire et indispensable pour l'onglet Achats
class RechercherProduits {
  final ProduitRepository repository;

  RechercherProduits({required this.repository});

  FutureResultat call(String query) {
    return repository.rechercherProduits(query);
  }
}