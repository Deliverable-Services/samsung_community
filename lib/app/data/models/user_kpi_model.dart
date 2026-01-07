/// User KPI Model based on Supabase schema
library;

class UserKpiModel {
  final String userId;
  final int postsPublishedCount;
  final int followersCount;
  final int followingCount;
  final DateTime updatedAt;

  UserKpiModel({
    required this.userId,
    required this.postsPublishedCount,
    required this.followersCount,
    required this.followingCount,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'posts_published_count': postsPublishedCount,
      'followers_count': followersCount,
      'following_count': followingCount,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory UserKpiModel.fromJson(Map<String, dynamic> json) {
    return UserKpiModel(
      userId: json['user_id'] as String,
      postsPublishedCount: json['posts_published_count'] as int? ?? 0,
      followersCount: json['followers_count'] as int? ?? 0,
      followingCount: json['following_count'] as int? ?? 0,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  UserKpiModel copyWith({
    String? userId,
    int? postsPublishedCount,
    int? followersCount,
    int? followingCount,
    DateTime? updatedAt,
  }) {
    return UserKpiModel(
      userId: userId ?? this.userId,
      postsPublishedCount: postsPublishedCount ?? this.postsPublishedCount,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
