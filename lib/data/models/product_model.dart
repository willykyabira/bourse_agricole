class ProductModel {
  final String? id;
  final String nom;
  final int quantite;
  final double prix;
  final String statut;

  ProductModel({
    this.id,
    required this.nom,
    required this.quantite,
    required this.prix,
    required this.statut,
  });

  // Conversion JSON (Supabase) -> Objet Dart
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      nom: json['nom'] ?? '',
      quantite: json['quantite'] ?? 0,
      // Gestion de la conversion num -> double (important pour le web)
      prix: (json['prix'] ?? 0).toDouble(),
      statut: json['statut'] ?? 'indisponible',
    );
  }

  // Conversion Objet Dart -> JSON (Pour insertion Supabase)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nom': nom,
      'quantite': quantite,
      'prix': prix,
      'statut': statut,
    };
  }
}