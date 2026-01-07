/// Academy Content Model based on Supabase schema
library;

enum AcademyFileType {
  video,
  zoomWorkshop,
  assignment,
  reel;

  static AcademyFileType fromString(String value) {
    return AcademyFileType.values.firstWhere(
      (e) => e.name == value.replaceAll('_', ''),
      orElse: () => AcademyFileType.video,
    );
  }

  String toJson() {
    switch (this) {
      case AcademyFileType.zoomWorkshop:
        return 'zoom_workshop';
      default:
        return name;
    }
  }
}

class AcademyContentModel {
  final String id;
  final String title;
  final String? description;
  final AcademyFileType fileType;
  final String? mediaFileUrl;
  final int pointsToEarn;
  final String? eventId;
  final Map<String, dynamic>? assignmentDetails;
  final bool isPublished;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  AcademyContentModel({
    required this.id,
    required this.title,
    this.description,
    required this.fileType,
    this.mediaFileUrl,
    this.pointsToEarn = 0,
    this.eventId,
    this.assignmentDetails,
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
      'file_type': fileType.toJson(),
      'media_file_url': mediaFileUrl,
      'points_to_earn': pointsToEarn,
      'event_id': eventId,
      'assignment_details': assignmentDetails,
      'is_published': isPublished,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory AcademyContentModel.fromJson(Map<String, dynamic> json) {
    return AcademyContentModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      fileType: AcademyFileType.fromString(json['file_type'] as String),
      mediaFileUrl: json['media_file_url'] as String?,
      pointsToEarn: json['points_to_earn'] as int? ?? 0,
      eventId: json['event_id'] as String?,
      assignmentDetails: json['assignment_details'] as Map<String, dynamic>?,
      isPublished: json['is_published'] as bool? ?? true,
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  AcademyContentModel copyWith({
    String? id,
    String? title,
    String? description,
    AcademyFileType? fileType,
    String? mediaFileUrl,
    int? pointsToEarn,
    String? eventId,
    Map<String, dynamic>? assignmentDetails,
    bool? isPublished,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AcademyContentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      fileType: fileType ?? this.fileType,
      mediaFileUrl: mediaFileUrl ?? this.mediaFileUrl,
      pointsToEarn: pointsToEarn ?? this.pointsToEarn,
      eventId: eventId ?? this.eventId,
      assignmentDetails: assignmentDetails ?? this.assignmentDetails,
      isPublished: isPublished ?? this.isPublished,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
