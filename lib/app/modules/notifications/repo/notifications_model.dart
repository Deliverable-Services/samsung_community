class NotificationItem {
  final String id;
  final String title;
  final String message;
  final bool isRead;
  final String notificationType;
  final DateTime createdAt;
  final String? relatedEntityType;
  final String? relatedEntityId;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    required this.notificationType,
    required this.createdAt,
    this.relatedEntityType,
    this.relatedEntityId,
  });
}
