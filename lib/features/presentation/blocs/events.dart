/// Classe de base de tous les événements.
abstract class BanEvent {}

// ================= AUTHENTIFICATION =================

/// Événement de connexion.
class AuthentifierEvent extends BanEvent {
  final String email;
  final String motDePasse;

  AuthentifierEvent({
    required this.email,
    required this.motDePasse,
  });
}

/// Événement de création d'un compte.
class EnregistrerEvent extends BanEvent {
  final String email;
  final String nomComplet;
  final String motDePasse;
  final String telephone;
  final String role;

  EnregistrerEvent({
    required this.email,
    required this.nomComplet,
    required this.motDePasse,
    required this.telephone,
    required this.role,
  });
}

// ================= PRODUITS =================

/// Ajouter un nouveau produit.
class AjouterProduitEvent extends BanEvent {
  final Map<String, dynamic> produitData;

  AjouterProduitEvent(this.produitData);
}

/// Consulter le stock d'un produit.
class ConsulterEtatStockEvent extends BanEvent {
  final String produitId;

  ConsulterEtatStockEvent(this.produitId);
}

/// Charger la liste des produits.
class ConsulterListeProduitEvent extends BanEvent {}

/// Supprimer un produit.
class SupprimerProduitEvent extends BanEvent {
  final String produitId;

  SupprimerProduitEvent(this.produitId);
}