import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bourse_agricole/core/services/notification_center.dart';
import 'package:bourse_agricole/ui/couleurs.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final center = NotificationCenter();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: couleurPrincipale,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Tout marquer comme lu',
            onPressed: () {
              center.markAllAsRead();
            },
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: center,
        builder: (context, _) {
          final notifications = center.notifications;
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                children: [
                  Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune notification',
                    style: GoogleFonts.poppins(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notif = notifications[index];
              return _buildNotificationTile(context, notif, center);
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationTile(BuildContext context, dynamic notif, NotificationCenter center) {
    return Dismissible(
      key: Key(notif.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        center.clear();
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: const Icon(Icons.notifications_rounded, color: Color(0xFF334C50)),
          title: Text(
            'Notification',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(notif.message, style: GoogleFonts.inter(fontSize: 12)),
              const SizedBox(height: 4),
              Text(
                _formatDate(notif.dateNotification),
                style: GoogleFonts.inter(fontSize: 10, color: Colors.grey[500]),
              ),
            ],
          ),
          isThreeLine: true,
          onTap: () {
            center.markAsRead(notif.id);
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours} h';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays} jours';
    return '${date.day}/${date.month}/${date.year}';
  }
}
