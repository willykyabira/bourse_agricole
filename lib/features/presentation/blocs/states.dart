abstract class BanState {}

/// État initial (repos)
class IdleState extends BanState {}

/// État de chargement (Cercle de progression)
class LoadingState extends BanState {}

// ignore: unintended_html_in_doc_comment
/// État de succès (Retourne une valeur générique <T>)
class SuccesState<T> extends BanState {
  final T valeur;
  SuccesState(this.valeur);
}

/// État d'échec (Retourne un message d'erreur)
class EchecState extends BanState {
  final String message;
  EchecState(this.message);
}