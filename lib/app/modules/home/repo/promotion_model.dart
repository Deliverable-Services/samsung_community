enum PromotionFrequency {
  oneTime,
  interval,
}
extension PromotionFrequencyExtension on PromotionFrequency {
  static PromotionFrequency fromString(String value) {
    switch (value) {
      case 'one_time':
        return PromotionFrequency.oneTime;
      case 'interval':
        return PromotionFrequency.interval;
      default:
        throw Exception('Unknown PromotionFrequency: $value');
    }
  }
  String get name {
    switch (this) {
      case PromotionFrequency.oneTime:
        return 'one_time';
      case PromotionFrequency.interval:
        return 'interval';
    }
  }
}


class PromotionModel {
  final String id;
  final String title;
  final String? description;
  final String? backgroundImageUrl;
  final PromotionFrequency frequency;
  final int? intervalDurationMs;

  PromotionModel({
    required this.id,
    required this.title,
    this.description,
    this.backgroundImageUrl,
    required this.frequency,
    this.intervalDurationMs,
  });

  factory PromotionModel.fromJson(Map<String, dynamic> json) {
    return PromotionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      backgroundImageUrl: json['background_image_url'] as String?,
      frequency: PromotionFrequencyExtension.fromString(
        json['frequency'] as String,
      ),
      intervalDurationMs: json['interval_duration_ms'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'background_image_url': backgroundImageUrl,
      'frequency': frequency.name,
      'interval_duration_ms': intervalDurationMs,
    };
  }

  /// Helper: convert interval to Duration
  Duration? get intervalDuration =>
      intervalDurationMs != null
          ? Duration(milliseconds: intervalDurationMs!)
          : null;

  /// Helper: check frequency
  bool get isOneTime => frequency == PromotionFrequency.oneTime;
  bool get isInterval => frequency == PromotionFrequency.interval;
}