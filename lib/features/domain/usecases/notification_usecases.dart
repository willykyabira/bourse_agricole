import 'package:bourse_agricole/features/domain/entities/notification.dart';
import 'package:bourse_agricole/features/domain/repositories/notification_repository.dart';

class GetNotifications {
  final NotificationRepository repository;
  GetNotifications(this.repository);
  Future<List<NotificationEntity>> call(String vendeurId) => repository.getNotifications(vendeurId);
}

class WatchNotifications {
  final NotificationRepository repository;
  WatchNotifications(this.repository);
  Stream<List<NotificationEntity>> call(String vendeurId) => repository.watchNotifications(vendeurId);
}

class CreerNotification {
  final NotificationRepository repository;
  CreerNotification(this.repository);
  Future<void> call(NotificationEntity notification) => repository.creerNotification(notification);
}
