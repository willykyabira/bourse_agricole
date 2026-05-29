import 'package:equatable/equatable.dart';

abstract class Resultat extends Equatable {}

// ignore: must_be_immutable
class Succes<T> extends Resultat {
  T valeur;
  int age = 0;
  Succes(this.valeur);

  @override
  List<Object?> get props => [valeur];
}

// ignore: must_be_immutable
class Echec extends Resultat {
  String message;
  Echec({this.message = ""});

  @override
  List<Object?> get props => [message];
}

typedef FutureResultat = Future<Resultat>;
