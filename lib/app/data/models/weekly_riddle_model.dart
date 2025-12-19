/// Weekly Riddle Model based on Supabase schema

enum RiddleSolutionType {
  text,
  voice,
  video;

  static RiddleSolutionType fromString(String value) {
    return RiddleSolutionType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => RiddleSolutionType.text,
    );
  }

  String toJson() => name;
}

class WeeklyRiddleModel {
  final String id;
  final String title;
  final String? description;
  final String? rules;
  final RiddleSolutionType solutionType;
  final Map<String, dynamic>? textSolutions;
  final int pointsToEarn;
  final String? adminVodUrl;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  WeeklyRiddleModel({
    required this.id,
    required this.title,
    this.description,
    this.rules,
    required this.solutionType,
    this.textSolutions,
    required this.pointsToEarn,
    this.adminVodUrl,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'rules': rules,
      'solution_type': solutionType.toJson(),
      'text_solutions': textSolutions,
      'points_to_earn': pointsToEarn,
      'admin_vod_url': adminVodUrl,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'is_active': isActive,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory WeeklyRiddleModel.fromJson(Map<String, dynamic> json) {
    return WeeklyRiddleModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      rules: json['rules'] as String?,
      solutionType: RiddleSolutionType.fromString(json['solution_type'] as String),
      textSolutions: json['text_solutions'] as Map<String, dynamic>?,
      pointsToEarn: json['points_to_earn'] as int,
      adminVodUrl: json['admin_vod_url'] as String?,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      isActive: json['is_active'] as bool? ?? true,
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  WeeklyRiddleModel copyWith({
    String? id,
    String? title,
    String? description,
    String? rules,
    RiddleSolutionType? solutionType,
    Map<String, dynamic>? textSolutions,
    int? pointsToEarn,
    String? adminVodUrl,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WeeklyRiddleModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      rules: rules ?? this.rules,
      solutionType: solutionType ?? this.solutionType,
      textSolutions: textSolutions ?? this.textSolutions,
      pointsToEarn: pointsToEarn ?? this.pointsToEarn,
      adminVodUrl: adminVodUrl ?? this.adminVodUrl,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

