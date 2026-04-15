class ProductModel {
  final String? id;
  final String nom;
  final double quantite;
  final String unite;
  final double prixUnitaire;
  final bool estPublie;

  ProductModel({this.id, required this.nom, required this.quantite, 
                required this.unite, required this.prixUnitaire, this.estPublie = false});

  Map<String, dynamic> toJson() => {
    'nom': nom, 'quantite': quantite, 'unite': unite, 
    'prix_unitaire': prixUnitaire, 'statut_publication': estPublie,
  };
}
