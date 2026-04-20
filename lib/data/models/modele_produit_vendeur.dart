class ModeleProduitVendeur {
  final String id;
  final String nom;
  final int quantite;
  final String statut;
  final DateTime dateDepot;
  final double prixFixe;

  ModeleProduitVendeur({
    required this.id,
    required this.nom,
    required this.quantite,
    required this.statut,
    required this.dateDepot,
    required this.prixFixe,
  });

  factory ModeleProduitVendeur.fromJson(Map<String, dynamic> json) {
    return ModeleProduitVendeur(
      id: json['id'],
      nom: json['nom'] ?? 'Produit inconnu',
      quantite: json['quantite'] ?? 0,
      statut: json['statut'] ?? 'Non défini',
      dateDepot: DateTime.parse(json['created_at']),
      prixFixe: (json['prix_unitaire'] ?? 0).toDouble(),
    );
  }
}