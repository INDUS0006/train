import 'package:flutter/foundation.dart';
import '../core/constants/api_constants.dart';
import '../models/notification_model.dart';
import '../services/api_service.dart';

class NotificationProvider with ChangeNotifier {
  List<InAppNotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;

  List<InAppNotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  NotificationProvider() {
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners();

    final response = await ApiService.get(ApiConstants.notifications);
    _isLoading = false;

    if (response.success && response.data != null) {
      _unreadCount = response.data['unread_count'] ?? 0;
      final list = response.data['notifications'] as List? ?? [];
      _notifications = list.map((n) => InAppNotificationModel.fromJson(n)).toList();
    }
    notifyListeners();
  }

  Future<void> markAsRead(int notifId) async {
    final response = await ApiService.post(
      ApiConstants.notificationMarkRead(notifId),
      requireAuth: true,
    );
    if (response.success) {
      final index = _notifications.indexWhere((n) => n.id == notifId);
      if (index != -1 && !_notifications[index].isRead) {
        _notifications[index].isRead = true;
        _unreadCount = (_unreadCount > 0) ? _unreadCount - 1 : 0;
        notifyListeners();
      }
    }
  }

  Future<void> markAllAsRead() async {
    final response = await ApiService.post(
      ApiConstants.notificationReadAll,
      requireAuth: true,
    );
    if (response.success) {
      for (var n in _notifications) {
        n.isRead = true;
      }
      _unreadCount = 0;
      notifyListeners();
    }
  }
}
