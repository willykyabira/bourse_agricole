abstract class BanEvent {}

// --- AUTHENTIFICATION ---
class AuthentifierEvent extends BanEvent {
  final String email;
  final String motDePasse;
  AuthentifierEvent({required this.email, required this.motDePasse});
}

class EnregistrerEvent extends BanEvent {
  final String email;
  final String nomComplet;
  final String motDePasse;
  final String telephone; // Correction : Ajouté comme propriété
  final String role;

  EnregistrerEvent({
    required this.email,
    required this.nomComplet,
    required this.motDePasse,
    required this.telephone, // Correction : Ajouté ici
    required this.role,
  });
}

// --- GESTION DES PRODUITS ---
class AjouterProduitEvent extends BanEvent {
  final Map<String, dynamic> produitData;
  AjouterProduitEvent(this.produitData);
}

class ConsulterEtatStockEvent extends BanEvent {
  final String produitId;
  ConsulterEtatStockEvent(this.produitId);
}

class ConsulterListeProduitEvent extends BanEvent {}

class SupprimerProduitEvent extends BanEvent {
  final String produitId;
  SupprimerProduitEvent(this.produitId);
}