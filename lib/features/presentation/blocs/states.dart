/// ======================================================================
/// CLASSE DE BASE DE TOUS LES ÉTATS DU BLOC
///
/// Tous les états de l'application héritent de cette classe.
/// ======================================================================
abstract class BanState {}

/// ======================================================================
/// ÉTAT INITIAL
///
/// Cet état est utilisé lorsque rien ne s'est encore produit.
/// Exemple : au lancement de la page.
/// ======================================================================
class IdleState extends BanState {}

/// ======================================================================
/// ÉTAT DE CHARGEMENT
///
/// Utilisé lorsqu'une opération est en cours
/// (connexion, inscription, récupération des données, etc.).
///
/// Généralement, cet état permet d'afficher un
/// CircularProgressIndicator.
/// ======================================================================
class LoadingState extends BanState {}

/// ======================================================================
/// ÉTAT DE SUCCÈS
///
// ignore: unintended_html_in_doc_comment
/// <T> représente le type de donnée renvoyée.
///
/// Exemples :
// ignore: unintended_html_in_doc_comment
/// - SuccesState<bool>
// ignore: unintended_html_in_doc_comment
/// - SuccesState<String>
// ignore: unintended_html_in_doc_comment
/// - SuccesState<List<Produit>>
/// ======================================================================

// ignore: unintended_html_in_doc_comment
class SuccesState<T> extends BanState {

  /// Donnée retournée après une opération réussie.
  final T valeur;

  SuccesState(this.valeur);
}

/// ======================================================================
/// ÉTAT D'ÉCHEC
///
/// Cet état est utilisé lorsqu'une erreur survient.
/// Le message sera généralement affiché dans un SnackBar
/// ou dans une boîte de dialogue.
/// ======================================================================
class EchecState extends BanState {

  /// Message décrivant l'erreur.
  final String message;

  EchecState(this.message);
}