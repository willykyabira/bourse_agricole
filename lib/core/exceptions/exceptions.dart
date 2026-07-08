/// Exception utilisée lorsqu'une erreur provient du serveur.
class ServerException implements Exception {
  /// Message décrivant l'erreur.
  final String message;

  ServerException({this.message = ""});
}