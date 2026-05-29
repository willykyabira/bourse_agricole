import 'package:equatable/equatable.dart';

class Utilisateur extends Equatable {
  final String id;
  final String email;
  final String nom;
  final String prenom;

  const Utilisateur({
    this.id = "",
    this.email = "",
    this.nom = "",
    this.prenom = "",
  });

  @override
  List<Object?> get props => [id];
}

class Eolienne extends Equatable {
  final String idUtilisateur;
  final String numeroSerie;
  final double vitesseRotation;
  final double puissanceGenere;
  final double orientation;
  final String hashSecurite;
  final DateTime? tempsDerniereMesure;
  final bool actif;
  

  const Eolienne({
    this.idUtilisateur = "",
    this.numeroSerie = "",
    this.vitesseRotation = 0,
    this.puissanceGenere = 0,
    this.orientation = 0,
    this.hashSecurite = "",
    this.actif = true,
    this.tempsDerniereMesure,
  });

  @override
  List<Object?> get props => [numeroSerie];
}
