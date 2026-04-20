class NotificationModel {
  final String id;
  final String titre;
  final String message;
  final DateTime createdAt;
  final bool lu;
  final String? type; // Pour distinguer 'vente', 'stock_bas', 'info'

  NotificationModel({
    required this.id,
    required this.titre,
    required this.message,
    required this.createdAt,
    this.lu = false,
    this.type,
  });

  /// Transforme les données JSON de Supabase en instance de NotificationModel
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      titre: json['titre'] ?? '',
      message: json['message'] ?? '',
      // Supabase renvoie des dates au format ISO8601 String
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      lu: json['lu'] ?? false,
      type: json['type'],
    );
  }

  /// Prépare l'objet pour une éventuelle mise à jour (ex: marquer comme lu)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'message': message,
      'lu': lu,
      'type': type,
      // On ne renvoie généralement pas created_at car Supabase le gère (DEFAULT NOW())
    };
  }

  /// Utilitaire pour afficher une date lisible dans l'app Mobile
  /// Affiche "Aujourd'hui", "Hier" ou la date précise
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays == 0) {
      return "Aujourd'hui à ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}";
    } else if (difference.inDays == 1) {
      return "Hier";
    } else {
      return "${createdAt.day}/${createdAt.month}/${createdAt.year}";
    }
  }
}