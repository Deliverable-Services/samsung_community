import 'dart:convert';

enum RiddleSolutionType {
  text,
  audio,
  mcq;

  static RiddleSolutionType fromString(String value) {
    final normalizedValue = value.toLowerCase().trim();
    return RiddleSolutionType.values.firstWhere(
      (e) => e.name == normalizedValue,
      orElse: () => RiddleSolutionType.text,
    );
  }

  String toJson() => name;
}

enum AssignmentCardType { riddle, assignment }

class WeeklyRiddleModel {
  final String id;
  final String title;
  final String? description;
  final String? rules;
  final RiddleSolutionType solutionType;
  final dynamic question;
  final String? answer;
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
    this.question,
    this.answer,
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
      'type': solutionType.toJson(),
      'question': question,
      'answer': answer,
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
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      rules: json['rules']?.toString(),
      solutionType: RiddleSolutionType.fromString(
        (json['riddle_solution_type'] ?? json['type'])?.toString() ?? 'text',
      ),
      question: _parseJsonField(json['question']),
      answer: json['answer']?.toString(),
      pointsToEarn: (json['points_to_earn'] as num?)?.toInt() ?? 0,
      adminVodUrl: json['admin_vod_url']?.toString(),
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'].toString())
          : DateTime.now(),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'].toString())
          : DateTime.now(),
      isActive: json['is_active'] as bool? ?? true,
      createdBy: json['created_by']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : DateTime.now(),
    );
  }

  static dynamic _parseJsonField(dynamic value) {
    if (value == null) return null;
    if (value is Map<String, dynamic> || value is List) {
      return value;
    }
    if (value is String) {
      if (value.trim().isEmpty) return null;
      try {
        final decoded = jsonDecode(value);
        return decoded;
      } catch (e) {
        return null;
      }
    }
    return value;
  }

  WeeklyRiddleModel copyWith({
    String? id,
    String? title,
    String? description,
    String? rules,
    RiddleSolutionType? solutionType,
    dynamic question,
    String? answer,
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
      question: question ?? this.question,
      answer: answer ?? this.answer,
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
