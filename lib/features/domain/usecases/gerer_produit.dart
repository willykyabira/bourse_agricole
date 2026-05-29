import 'package:bourse_agricole/core/resultat/resultat.dart';
import 'package:bourse_agricole/features/domain/repositories/produit_repository.dart';

// Use Case pour ajouter un produit (utilisé par le vendeur)
class AjouterProduit {
  final ProduitRepository repository;

  AjouterProduit({required this.repository});

  // On passe maintenant un Map (nom, prix, catégorie, etc.) au lieu du numéro de série
  FutureResultat call(Map<String, dynamic> produitData) {
    return repository.ajouterProduit(produitData);
  }
}

// Use Case pour supprimer un produit (utilisé par le vendeur ou l'admin)
class SupprimerProduit {
  final ProduitRepository repository;

  SupprimerProduit({required this.repository});

  // On utilise l'ID unique du produit pour la suppression
  FutureResultat call(String idProduit) {
    return repository.supprimerProduit(idProduit);
  }
}

// Use Case additionnel pour la consultation (Section Accueil/Achats)
class ConsulterProduits {
  final ProduitRepository repository;

  ConsulterProduits({required this.repository});

  FutureResultat call() {
    return repository.consulterListeProduits();
  }
}