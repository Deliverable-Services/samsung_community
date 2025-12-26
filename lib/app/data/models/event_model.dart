/// Event Model based on Supabase schema

enum EventType {
  zoomWorkshop,
  liveEvent,
  reel;

  static EventType fromString(String value) {
    // Handle snake_case from database
    final normalizedValue = value.replaceAll('_', '');
    return EventType.values.firstWhere(
      (e) => e.name.toLowerCase() == normalizedValue.toLowerCase() ||
          e.name == value,
      orElse: () => EventType.zoomWorkshop,
    );
  }

  String toJson() {
    // Convert to snake_case for database
    switch (this) {
      case EventType.zoomWorkshop:
        return 'zoom_workshop';
      case EventType.liveEvent:
        return 'live_event';
      case EventType.reel:
        return 'reel';
    }
  }
}

class EventModel {
  final String id;
  final String title;
  final String? description;
  final EventType eventType;
  final DateTime eventDate;
  final int? durationMinutes;
  final int? costPoints;
  final int? costCreditCents;
  final int? maxTickets;
  final int ticketsSold;
  final String? zoomLink;
  final String? zoomMeetingId;
  final String? imageUrl;
  final String? videoUrl;
  final DateTime? endDate;
  final bool isPublished;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  EventModel({
    required this.id,
    required this.title,
    this.description,
    required this.eventType,
    required this.eventDate,
    this.durationMinutes,
    this.costPoints,
    this.costCreditCents,
    this.maxTickets,
    required this.ticketsSold,
    this.zoomLink,
    this.zoomMeetingId,
    this.imageUrl,
    this.videoUrl,
    this.endDate,
    required this.isPublished,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'event_type': eventType.toJson(),
      'event_date': eventDate.toIso8601String(),
      'duration_minutes': durationMinutes,
      'cost_points': costPoints,
      'cost_credit_cents': costCreditCents,
      'max_tickets': maxTickets,
      'tickets_sold': ticketsSold,
      'zoom_link': zoomLink,
      'zoom_meeting_id': zoomMeetingId,
      'image_url': imageUrl,
      'video_url': videoUrl,
      'end_date': endDate?.toIso8601String(),
      'is_published': isPublished,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      eventType: EventType.fromString(json['event_type'] as String),
      eventDate: DateTime.parse(json['event_date'] as String),
      durationMinutes: json['duration_minutes'] as int?,
      costPoints: json['cost_points'] as int?,
      costCreditCents: json['cost_credit_cents'] as int?,
      maxTickets: json['max_tickets'] as int?,
      ticketsSold: json['tickets_sold'] as int? ?? 0,
      zoomLink: json['zoom_link'] as String?,
      zoomMeetingId: json['zoom_meeting_id'] as String?,
      imageUrl: json['image_url'] as String?,
      videoUrl: json['video_url'] as String?,
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      isPublished: json['is_published'] as bool? ?? false,
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    EventType? eventType,
    DateTime? eventDate,
    int? durationMinutes,
    int? costPoints,
    int? costCreditCents,
    int? maxTickets,
    int? ticketsSold,
    String? zoomLink,
    String? zoomMeetingId,
    String? imageUrl,
    String? videoUrl,
    DateTime? endDate,
    bool? isPublished,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      eventType: eventType ?? this.eventType,
      eventDate: eventDate ?? this.eventDate,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      costPoints: costPoints ?? this.costPoints,
      costCreditCents: costCreditCents ?? this.costCreditCents,
      maxTickets: maxTickets ?? this.maxTickets,
      ticketsSold: ticketsSold ?? this.ticketsSold,
      zoomLink: zoomLink ?? this.zoomLink,
      zoomMeetingId: zoomMeetingId ?? this.zoomMeetingId,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      endDate: endDate ?? this.endDate,
      isPublished: isPublished ?? this.isPublished,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

