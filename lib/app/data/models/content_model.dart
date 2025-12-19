/// Content Model based on Supabase schema
/// Represents VOD, Podcast, and Feed posts

enum ContentType {
  vod,
  podcast,
  feed;

  static ContentType fromString(String value) {
    return ContentType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ContentType.feed,
    );
  }

  String toJson() => name;
}

class ContentModel {
  final String id;
  final String? title;
  final String? description;
  final ContentType contentType;
  final String userId;
  final String? mediaFileUrl;
  final List<String>? mediaFiles;
  final String? thumbnailUrl;
  final String? category;
  final int pointsToEarn;
  final bool isFeatured;
  final bool isPublished;
  final bool isSharedToCommunity;
  final List<String>? externalSharePlatforms;
  final int viewCount;
  final int likesCount;
  final int commentsCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  ContentModel({
    required this.id,
    this.title,
    this.description,
    required this.contentType,
    required this.userId,
    this.mediaFileUrl,
    this.mediaFiles,
    this.thumbnailUrl,
    this.category,
    this.pointsToEarn = 0,
    required this.isFeatured,
    required this.isPublished,
    required this.isSharedToCommunity,
    this.externalSharePlatforms,
    required this.viewCount,
    required this.likesCount,
    required this.commentsCount,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'content_type': contentType.toJson(),
      'user_id': userId,
      'media_file_url': mediaFileUrl,
      'media_files': mediaFiles,
      'thumbnail_url': thumbnailUrl,
      'category': category,
      'points_to_earn': pointsToEarn,
      'is_featured': isFeatured,
      'is_published': isPublished,
      'is_shared_to_community': isSharedToCommunity,
      'external_share_platforms': externalSharePlatforms,
      'view_count': viewCount,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  factory ContentModel.fromJson(Map<String, dynamic> json) {
    return ContentModel(
      id: json['id'] as String,
      title: json['title'] as String?,
      description: json['description'] as String?,
      contentType: ContentType.fromString(json['content_type'] as String),
      userId: json['user_id'] as String,
      mediaFileUrl: json['media_file_url'] as String?,
      mediaFiles: json['media_files'] != null
          ? List<String>.from(json['media_files'] as List)
          : null,
      thumbnailUrl: json['thumbnail_url'] as String?,
      category: json['category'] as String?,
      pointsToEarn: json['points_to_earn'] as int? ?? 0,
      isFeatured: json['is_featured'] as bool? ?? false,
      isPublished: json['is_published'] as bool? ?? true,
      isSharedToCommunity: json['is_shared_to_community'] as bool? ?? true,
      externalSharePlatforms: json['external_share_platforms'] != null
          ? List<String>.from(json['external_share_platforms'] as List)
          : null,
      viewCount: json['view_count'] as int? ?? 0,
      likesCount: json['likes_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
    );
  }

  ContentModel copyWith({
    String? id,
    String? title,
    String? description,
    ContentType? contentType,
    String? userId,
    String? mediaFileUrl,
    List<String>? mediaFiles,
    String? thumbnailUrl,
    String? category,
    int? pointsToEarn,
    bool? isFeatured,
    bool? isPublished,
    bool? isSharedToCommunity,
    List<String>? externalSharePlatforms,
    int? viewCount,
    int? likesCount,
    int? commentsCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return ContentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      contentType: contentType ?? this.contentType,
      userId: userId ?? this.userId,
      mediaFileUrl: mediaFileUrl ?? this.mediaFileUrl,
      mediaFiles: mediaFiles ?? this.mediaFiles,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      category: category ?? this.category,
      pointsToEarn: pointsToEarn ?? this.pointsToEarn,
      isFeatured: isFeatured ?? this.isFeatured,
      isPublished: isPublished ?? this.isPublished,
      isSharedToCommunity: isSharedToCommunity ?? this.isSharedToCommunity,
      externalSharePlatforms:
          externalSharePlatforms ?? this.externalSharePlatforms,
      viewCount: viewCount ?? this.viewCount,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
