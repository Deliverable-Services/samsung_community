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

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    bool isReadValue = false;
    if (json['is_read'] != null) {
      if (json['is_read'] is bool) {
        isReadValue = json['is_read'] as bool;
      } else if (json['is_read'] is String) {
        isReadValue = json['is_read'].toString().toLowerCase() == 'true';
      } else {
        isReadValue = json['is_read'] == 1 || json['is_read'] == true;
      }
    }

    return NotificationItem(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      isRead: isReadValue,
      notificationType: json['notification_type'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      relatedEntityType: json['related_entity_type'] as String?,
      relatedEntityId: json['related_entity_id'] as String?,
    );
  }

  NotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    bool? isRead,
    String? notificationType,
    DateTime? createdAt,
    String? relatedEntityType,
    String? relatedEntityId,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      notificationType: notificationType ?? this.notificationType,
      createdAt: createdAt ?? this.createdAt,
      relatedEntityType: relatedEntityType ?? this.relatedEntityType,
      relatedEntityId: relatedEntityId ?? this.relatedEntityId,
    );
  }
}
