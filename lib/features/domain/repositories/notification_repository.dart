import 'package:bourse_agricole/features/domain/entities/notification.dart';

abstract class NotificationRepository {
  Future<List<NotificationEntity>> getNotifications(String vendeurId);
  Stream<List<NotificationEntity>> watchNotifications(String vendeurId);
  Future<void> creerNotification(NotificationEntity notification);
}
