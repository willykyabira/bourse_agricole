import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bourse_agricole/features/domain/entities/notification.dart';

class NotificationCenter extends ChangeNotifier {
  static final NotificationCenter _instance = NotificationCenter._internal();
  factory NotificationCenter() => _instance;
  NotificationCenter._internal();

  final List<NotificationEntity> _notifications = [];
  int _unreadCount = 0;
  RealtimeChannel? _channel;

  List<NotificationEntity> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _unreadCount;

  void startListening(String userId) {
    _channel = Supabase.instance.client
        .channel('public:notifications:client-$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'acheteur_id',
            value: userId,
          ),
          callback: (payload) {
            final data = payload.newRecord;
            add(NotificationEntity(
              id: data['id'],
              vendeurId: data['acheteur_id'] ?? data['vendeur_id'],
              message: data['message'],
              dateNotification: DateTime.parse(data['date_notification']),
              isRead: data['is_read'] ?? false,
            ));
          },
        )
        .subscribe();
  }

  void add(NotificationEntity notification) {
    _notifications.insert(0, notification);
    _updateUnreadCount();
    notifyListeners();
  }

  void _updateUnreadCount() {
    _unreadCount = _notifications.where((n) => !n.isRead).length;
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _updateUnreadCount();
      notifyListeners();
      // Ici, on pourrait ajouter un appel Supabase pour mettre à jour en BDD
    }
  }

  void markAllAsRead() {
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    _updateUnreadCount();
    notifyListeners();
  }

  void clear() {
    _notifications.clear();
    _unreadCount = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }
}
