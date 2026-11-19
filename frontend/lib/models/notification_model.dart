class InAppNotificationModel {
  final int id;
  final String title;
  final String message;
  final String notificationType;
  final String notificationTypeDisplay;
  final int? trainId;
  final String? trainNumber;
  bool isRead;
  final String createdAt;

  InAppNotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.notificationType,
    required this.notificationTypeDisplay,
    this.trainId,
    this.trainNumber,
    required this.isRead,
    required this.createdAt,
  });

  factory InAppNotificationModel.fromJson(Map<String, dynamic> json) {
    return InAppNotificationModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      notificationType: json['notification_type'] ?? 'SYSTEM_NOTICE',
      notificationTypeDisplay: json['notification_type_display'] ?? 'Notice',
      trainId: json['train'],
      trainNumber: json['train_number'],
      isRead: json['is_read'] ?? false,
      createdAt: json['created_at'] ?? '',
    );
  }
}
