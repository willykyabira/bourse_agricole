import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bourse_agricole/features/domain/entities/notification.dart';
import 'package:bourse_agricole/features/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final SupabaseClient client;

  NotificationRepositoryImpl(this.client);

  @override
  Future<List<NotificationEntity>> getNotifications(String vendeurId) async {
    final response = await client
        .from('notifications')
        .select()
        .eq('vendeur_id', vendeurId)
        .order('date_notification', ascending: false)
        .limit(50);

    return (response as List)
        .map((json) => NotificationEntity(
              id: json['id'] as String,
              vendeurId: json['vendeur_id'] as String,
              message: json['message'] as String,
              dateNotification: DateTime.parse(json['date_notification'] as String),
            ))
        .toList();
  }

  @override
  Stream<List<NotificationEntity>> watchNotifications(String vendeurId) {
    return client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('vendeur_id', vendeurId)
        .order('date_notification', ascending: false)
        .map((rows) => rows
            .map((json) => NotificationEntity(
                  id: json['id'] as String,
                  vendeurId: json['vendeur_id'] as String,
                  message: json['message'] as String,
                  dateNotification: DateTime.parse(json['date_notification'] as String),
                ))
            .toList());
  }

  @override
  Future<void> creerNotification(NotificationEntity notification) async {
    await client.from('notifications').insert({
      'vendeur_id': notification.vendeurId,
      'message': notification.message,
      'date_notification': notification.dateNotification.toIso8601String(),
    });
  }
}
