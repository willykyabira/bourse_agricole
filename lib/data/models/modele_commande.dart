class ModeleCommande {
  final String? id;
  final String acheteurId;
  final String produitId;
  final double quantite;
  final double total;
  final DateTime createdAt;

  ModeleCommande({
    this.id,
    required this.acheteurId,
    required this.produitId,
    required this.quantite,
    required this.total,
    required this.createdAt,
  });

  factory ModeleCommande.fromJson(Map<String, dynamic> json) => ModeleCommande(
    id: json['id'],
    acheteurId: json['acheteur_id'],
    produitId: json['produit_id'],
    quantite: json['quantite_commandee'].toDouble(),
    total: json['total'].toDouble(),
    createdAt: DateTime.parse(json['created_at']),
  );
}