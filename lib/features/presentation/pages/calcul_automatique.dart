/// Classe permettant de calculer le montant d'une facture.
class FactureCalculator {
  final double prixUnitaire;
  final int quantite;

  FactureCalculator({
    required this.prixUnitaire,
    required this.quantite,
  });

  /// Montant des produits avant les frais.
  double get prixBase => prixUnitaire * quantite;

  /// Frais appliqués à la commande.
  double get fraisTransport => prixBase * 0.03;
  double get manutention => prixBase * 0.01;
  double get stockage => prixBase * 0.01;
  double get commission => prixBase * 0.05;

  /// Total hors taxes (HT).
  double get totalHt =>
      prixBase +
      fraisTransport +
      manutention +
      stockage +
      commission;

  /// Taxe sur la valeur ajoutée (TVA).
  double get tva => totalHt * 0.16;

  /// Montant total toutes taxes comprises (TTC).
  double get totalTtc => totalHt + tva;
}