import 'package:equatable/equatable.dart';

/// Classe de base représentant le résultat d'une opération.
abstract class Resultat extends Equatable {}

/// Résultat en cas de succès.
// ignore: must_be_immutable
class Succes<T> extends Resultat {
  /// Valeur retournée par l'opération.
  T valeur;

  /// Variable optionnelle pouvant servir plus tard.
  int age = 0;

  Succes(this.valeur);

  @override
  List<Object?> get props => [valeur];
}

/// Résultat en cas d'échec.
// ignore: must_be_immutable
class Echec extends Resultat {
  /// Message décrivant l'erreur.
  String message;

  Echec({this.message = ""});

  @override
  List<Object?> get props => [message];
}

/// Type utilisé pour les méthodes asynchrones
/// retournant un objet Resultat.
typedef FutureResultat = Future<Resultat>;