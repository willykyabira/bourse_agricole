class FactureCalculator {
  final double prixUnitaire;
  final int quantite;

  FactureCalculator({required this.prixUnitaire, required this.quantite});

  double get prixBase => prixUnitaire * quantite;
  double get fraisTransport => prixBase * 0.03;
  double get manutention => prixBase * 0.01;
  double get stockage => prixBase * 0.01;
  double get commission => prixBase * 0.05;
  
  double get totalHt => prixBase + fraisTransport + manutention + stockage + commission;
  double get tva => totalHt * 0.16;
  double get totalTtc => totalHt + tva;
}