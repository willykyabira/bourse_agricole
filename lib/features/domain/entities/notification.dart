import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final String id;
  final String? vendeurId;
  final String message;
  final DateTime dateNotification;
  final bool isRead;

  const NotificationEntity({
    required this.id,
    this.vendeurId,
    required this.message,
    required this.dateNotification,
    this.isRead = false,
  });

  NotificationEntity copyWith({
    String? id,
    String? vendeurId,
    String? message,
    DateTime? dateNotification,
    bool? isRead,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      vendeurId: vendeurId ?? this.vendeurId,
      message: message ?? this.message,
      dateNotification: dateNotification ?? this.dateNotification,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  List<Object?> get props => [id, vendeurId, message, dateNotification, isRead];
}
