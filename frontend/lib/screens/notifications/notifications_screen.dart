import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/demo_banner.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  IconData _getIcon(String type) {
    switch (type.toUpperCase()) {
      case 'CROWD_UPDATE':
        return Icons.campaign_rounded;
      case 'JOURNEY_REMINDER':
        return Icons.alarm_rounded;
      case 'NEW_REPORT':
        return Icons.rate_review_rounded;
      case 'SYSTEM_NOTICE':
      default:
        return Icons.info_rounded;
    }
  }

  Color _getColor(String type) {
    switch (type.toUpperCase()) {
      case 'CROWD_UPDATE':
        return AppColors.warning;
      case 'JOURNEY_REMINDER':
        return AppColors.primaryBlue;
      case 'NEW_REPORT':
        return AppColors.success;
      case 'SYSTEM_NOTICE':
      default:
        return AppColors.navyBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifProv = Provider.of<NotificationProvider>(context);
    final notifications = notifProv.notifications;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (notifications.any((n) => !n.isRead))
            TextButton(
              onPressed: () => notifProv.markAllAsRead(),
              child: const Text('Mark all read', style: TextStyle(color: Colors.white, fontSize: 12.5)),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const DemoBanner(),
            Expanded(
              child: notifProv.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : notifications.isEmpty
                      ? const Center(
                          child: Text(
                            'No notifications at this time.',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: notifications.length,
                          itemBuilder: (context, index) {
                            final notif = notifications[index];
                            final color = _getColor(notif.notificationType);

                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: BorderSide(
                                  color: notif.isRead ? AppColors.border : AppColors.primaryBlue.withAlpha(80),
                                  width: notif.isRead ? 1 : 1.5,
                                ),
                              ),
                              color: notif.isRead ? Colors.white : AppColors.softBlue.withAlpha(50),
                              child: ListTile(
                                onTap: () => notifProv.markAsRead(notif.id),
                                contentPadding: const EdgeInsets.all(14),
                                leading: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: color.withAlpha(25),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(_getIcon(notif.notificationType), color: color, size: 22),
                                ),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        notif.title,
                                        style: TextStyle(
                                          fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.w800,
                                          fontSize: 14,
                                          color: AppColors.navyBlue,
                                        ),
                                      ),
                                    ),
                                    if (!notif.isRead)
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: AppColors.primaryBlue,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    notif.message,
                                    style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.3),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
