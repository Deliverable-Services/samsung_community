/// Notification Model based on Supabase schema

enum NotificationType {
  like,
  comment,
  follow,
  event,
  points,
  approval,
  other;

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => NotificationType.other,
    );
  }

  String toJson() => name;
}

class NotificationModel {
  final String id;
  final String userId;
  final NotificationType notificationType;
  final String title;
  final String message;
  final bool isRead;
  final String? relatedEntityType;
  final String? relatedEntityId;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.notificationType,
    required this.title,
    required this.message,
    required this.isRead,
    this.relatedEntityType,
    this.relatedEntityId,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'notification_type': notificationType.toJson(),
      'title': title,
      'message': message,
      'is_read': isRead,
      'related_entity_type': relatedEntityType,
      'related_entity_id': relatedEntityId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      notificationType: NotificationType.fromString(
        json['notification_type'] as String,
      ),
      title: json['title'] as String,
      message: json['message'] as String,
      isRead: json['is_read'] as bool? ?? false,
      relatedEntityType: json['related_entity_type'] as String?,
      relatedEntityId: json['related_entity_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    NotificationType? notificationType,
    String? title,
    String? message,
    bool? isRead,
    String? relatedEntityType,
    String? relatedEntityId,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      notificationType: notificationType ?? this.notificationType,
      title: title ?? this.title,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      relatedEntityType: relatedEntityType ?? this.relatedEntityType,
      relatedEntityId: relatedEntityId ?? this.relatedEntityId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

