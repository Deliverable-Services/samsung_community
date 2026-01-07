import 'package:flutter/foundation.dart';

/// Academy Content Model based on Supabase schema

enum AcademyFileType {
  video,
  zoomWorkshop,
  assignment,
  reel;

  // static AcademyFileType fromString(String value) {
  //   return AcademyFileType.values.firstWhere(
  //     (e) => e.name == value.replaceAll('_', ''),
  //     orElse: () => AcademyFileType.video,
  //   );
  // }
  static AcademyFileType fromString(String value) {
    return AcademyFileType.values.firstWhere(
      (e) => e.toJson() == value,
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
/*
class AcademyContentModel {
  final String id;
  final String? assignmentId;
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
    this.assignmentId,
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
      'assignment_id': assignmentId ??'',
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
      assignmentId: json['assignment_id'] ??'',
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
    String? assignmentId,
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
      assignmentId: assignmentId ?? this.assignmentId ??'',
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
*/

class AcademyContentModel {
  /// ---------------------------
  /// Academy Content
  /// ---------------------------
  final String academyContentId;
  final String title;
  final String? description;
  final AcademyFileType fileType;
  final String? mediaFileUrl;
  final int pointsToEarn;
  final bool isPublished;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// ---------------------------
  /// Creator User Profile
  /// ---------------------------
  final String? creatorUserId;
  final String? creatorFullName;
  final String? creatorPhoneNumber;
  final String? creatorProfilePictureUrl;
  final String? creatorRole;
  final String? creatorStatus;

  /// ---------------------------
  /// Zoom Workshop (Events)
  /// ---------------------------
  final String? eventId;
  final DateTime? eventDate;
  final int? durationMinutes;
  final String? zoomLink;
  final String? imageUrl;

  /// ---------------------------
  /// Assignment / Mission Challenge
  /// ---------------------------
  final String? assignmentId;
  final String? taskName;
  final String? taskType;
  final String? assignmentDescription;
  final DateTime? taskStartDate;
  final DateTime? taskEndDate;
  final String? taskEndTime;
  final int? totalPointsToWin;
  final List<dynamic>? answers;
  final String? assignmentCreatorUserId;
  final String? answer;
  final DateTime? assignmentCreatedAt;
  final DateTime? assignmentUpdatedAt;

  /// ---------------------------
  /// Assignment Submissions
  /// ---------------------------
  final List<String>? submissionUserIds;

  AcademyContentModel({
    required this.academyContentId,
    required this.title,
    required this.fileType,
    required this.pointsToEarn,
    required this.isPublished,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.mediaFileUrl,
    this.createdBy,

    // Creator
    this.creatorUserId,
    this.creatorFullName,
    this.creatorPhoneNumber,
    this.creatorProfilePictureUrl,
    this.creatorRole,
    this.creatorStatus,

    // Zoom
    this.eventId,
    this.eventDate,
    this.durationMinutes,
    this.zoomLink,
    this.imageUrl,

    // Assignment
    this.assignmentId,
    this.taskName,
    this.taskType,
    this.assignmentDescription,
    this.taskStartDate,
    this.taskEndDate,
    this.taskEndTime,
    this.totalPointsToWin,
    this.answers,
    this.assignmentCreatorUserId,
    this.answer,
    this.assignmentCreatedAt,
    this.assignmentUpdatedAt,

    // Submissions
    this.submissionUserIds,
  });

  /// ---------------------------
  /// From JSON
  /// ---------------------------
  factory AcademyContentModel.fromJson(Map<String, dynamic> json) {
    // Debug: Print all keys and image_url value
    if (json['file_type'] == 'zoom_workshop') {
      debugPrint('🔍 [AcademyContentModel] Parsing zoomWorkshop');
      debugPrint('🔍 [AcademyContentModel] JSON keys: ${json.keys.toList()}');
      debugPrint(
        '🔍 [AcademyContentModel] image_url value: ${json['image_url']}',
      );
      debugPrint(
        '🔍 [AcademyContentModel] image_url type: ${json['image_url'].runtimeType}',
      );
      debugPrint('🔍 [AcademyContentModel] event_id: ${json['event_id']}');
    }

    return AcademyContentModel(
      academyContentId: json['academy_content_id'],
      title: json['title'] ?? '',
      description: json['description'],
      fileType: AcademyFileType.fromString(json['file_type'] as String),
      mediaFileUrl: json['media_file_url'],
      pointsToEarn: json['points_to_earn'] ?? 0,
      isPublished: json['is_published'] ?? true,
      createdBy: json['created_by'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),

      // Creator
      creatorUserId: json['creator_user_id'],
      creatorFullName: json['creator_full_name'],
      creatorPhoneNumber: json['creator_phone_number'],
      creatorProfilePictureUrl: json['creator_profile_picture_url'],
      creatorRole: json['creator_role'],
      creatorStatus: json['creator_status'],

      // Zoom
      eventId: json['event_id'],
      eventDate: json['event_date'] != null
          ? DateTime.parse(json['event_date'])
          : null,
      durationMinutes: json['duration_minutes'],
      zoomLink: json['zoom_link'],
      imageUrl: json['image_url'],

      // Assignment
      assignmentId: json['assignment_id'],
      taskName: json['task_name'],
      taskType: json['task_type'],
      assignmentDescription: json['assignment_description'],
      taskStartDate: json['task_start_date'] != null
          ? DateTime.parse(json['task_start_date'])
          : null,
      taskEndDate: json['task_end_date'] != null
          ? DateTime.parse(json['task_end_date'])
          : null,
      taskEndTime: json['task_end_time'],
      totalPointsToWin: json['total_points_to_win'],
      answers: json['answers'],
      assignmentCreatorUserId: json['assignment_creator_user_id'],
      answer: json['answer'],
      assignmentCreatedAt: json['assignment_created_at'] != null
          ? DateTime.parse(json['assignment_created_at'])
          : null,
      assignmentUpdatedAt: json['assignment_updated_at'] != null
          ? DateTime.parse(json['assignment_updated_at'])
          : null,

      // Submissions
      submissionUserIds: json['submission_user_ids'] != null
          ? List<String>.from(json['submission_user_ids'])
          : [],
    );
  }

  /// ---------------------------
  /// To JSON
  /// ---------------------------
  Map<String, dynamic> toJson() {
    return {
      'academy_content_id': academyContentId,
      'title': title,
      'description': description,
      'file_type': fileType.toJson(),
      'media_file_url': mediaFileUrl,
      'points_to_earn': pointsToEarn,
      'is_published': isPublished,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),

      // Creator
      'creator_user_id': creatorUserId,
      'creator_full_name': creatorFullName,
      'creator_phone_number': creatorPhoneNumber,
      'creator_profile_picture_url': creatorProfilePictureUrl,
      'creator_role': creatorRole,
      'creator_status': creatorStatus,

      // Zoom
      'event_id': eventId,
      'event_date': eventDate?.toIso8601String(),
      'duration_minutes': durationMinutes,
      'zoom_link': zoomLink,
      'image_url': imageUrl,

      // Assignment
      'assignment_id': assignmentId,
      'task_name': taskName,
      'task_type': taskType,
      'assignment_description': assignmentDescription,
      'task_start_date': taskStartDate?.toIso8601String(),
      'task_end_date': taskEndDate?.toIso8601String(),
      'task_end_time': taskEndTime,
      'total_points_to_win': totalPointsToWin,
      'answers': answers,
      'assignment_creator_user_id': assignmentCreatorUserId,
      'assignment_created_at': assignmentCreatedAt?.toIso8601String(),
      'assignment_updated_at': assignmentUpdatedAt?.toIso8601String(),

      // Submissions
      'answer': answer,
      'submission_user_ids': submissionUserIds,
    };
  }
}
