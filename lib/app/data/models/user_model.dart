/// User Model based on Supabase schema
///
/// This model represents the users table in the Supabase database.
/// It includes all fields and helper methods for OTP-based authentication.
library;

/// User status enum matching database enum
enum UserStatus {
  pending,
  approved,
  rejected,
  suspended;

  static UserStatus fromString(String value) {
    return UserStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => UserStatus.pending,
    );
  }

  String toJson() => name;
}

/// User role enum matching database enum
enum UserRole {
  user,
  creator,
  admin;

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (e) => e.name == value,
      orElse: () => UserRole.user,
    );
  }

  String toJson() => name;
}

/// Language preference enum matching database enum
enum LanguagePreference {
  en,
  he;

  static LanguagePreference fromString(String value) {
    return LanguagePreference.values.firstWhere(
      (e) => e.name == value,
      orElse: () => LanguagePreference.en,
    );
  }

  String toJson() => name;
}

/// Gender type enum matching database enum
enum GenderType {
  male,
  female,
  other,
  preferNotToSay;

  static GenderType fromString(String value) {
    switch (value) {
      case 'male':
        return GenderType.male;
      case 'female':
        return GenderType.female;
      case 'other':
        return GenderType.other;
      case 'prefer_not_to_say':
        return GenderType.preferNotToSay;
      default:
        return GenderType.preferNotToSay;
    }
  }

  String toJson() {
    switch (this) {
      case GenderType.preferNotToSay:
        return 'prefer_not_to_say';
      default:
        return name;
    }
  }
}

/// User model representing the users table
class UserModel {
  final String id;
  final String phoneNumber;
  final String? otpCode;
  final DateTime? otpCreatedAt;
  final String? fullName;
  final String? profilePictureUrl;
  final LanguagePreference languagePreference;
  final DateTime? birthday;
  final String? city;
  final GenderType? gender;
  final String? deviceModel;
  final Map<String, dynamic> socialMediaLinks;
  final String? profession;
  final String? bio;
  final String? description;
  final int pointsBalance;
  final UserStatus status;
  final UserRole role;
  final bool isOnline;
  final DateTime? lastSeenAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? approvedAt;
  final String? approvedBy;
  final String? authUserId;
  final String? email;

  UserModel({
    required this.id,
    required this.phoneNumber,
    this.otpCode,
    this.otpCreatedAt,
    this.fullName,
    this.profilePictureUrl,
    required this.languagePreference,
    this.birthday,
    this.city,
    this.gender,
    this.deviceModel,
    required this.socialMediaLinks,
    this.profession,
    this.bio,
    this.description,
    required this.pointsBalance,
    required this.status,
    required this.role,
    required this.isOnline,
    this.lastSeenAt,
    required this.createdAt,
    required this.updatedAt,
    this.approvedAt,
    this.approvedBy,
    this.authUserId,
    this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone_number': phoneNumber,
      'otp_code': otpCode,
      'otp_created_at': otpCreatedAt?.toIso8601String(),
      'full_name': fullName,
      'profile_picture_url': profilePictureUrl,
      'language_preference': languagePreference.toJson(),
      'birthday': birthday?.toIso8601String().split('T')[0],
      'city': city,
      'gender': gender?.toJson(),
      'device_model': deviceModel,
      'social_media_links': socialMediaLinks,
      'profession': profession,
      'bio': bio,
      'description': description,
      'points_balance': pointsBalance,
      'status': status.toJson(),
      'role': role.toJson(),
      'is_online': isOnline,
      'last_seen_at': lastSeenAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'approved_at': approvedAt?.toIso8601String(),
      'approved_by': approvedBy,
      'auth_user_id': authUserId,
      'email': email,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      phoneNumber: json['phone_number'] as String,
      otpCode: json['otp_code'] as String?,
      otpCreatedAt: json['otp_created_at'] != null
          ? DateTime.parse(json['otp_created_at'] as String)
          : null,
      fullName: json['full_name'] as String?,
      profilePictureUrl: json['profile_picture_url'] as String?,
      languagePreference: LanguagePreference.fromString(
        json['language_preference'] as String? ?? 'en',
      ),
      birthday: json['birthday'] != null
          ? DateTime.parse(json['birthday'] as String)
          : null,
      city: json['city'] as String?,
      gender: json['gender'] != null
          ? GenderType.fromString(json['gender'] as String)
          : null,
      deviceModel: json['device_model'] as String?,
      socialMediaLinks:
          json['social_media_links'] as Map<String, dynamic>? ??
          <String, dynamic>{},
      profession: json['profession'] as String?,
      bio: json['bio'] as String?,
      description: json['description'] as String?,
      pointsBalance: json['points_balance'] as int? ?? 0,
      status: UserStatus.fromString(json['status'] as String? ?? 'pending'),
      role: UserRole.fromString(json['role'] as String? ?? 'user'),
      isOnline: json['is_online'] as bool? ?? false,
      lastSeenAt: json['last_seen_at'] != null
          ? DateTime.parse(json['last_seen_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      approvedAt: json['approved_at'] != null
          ? DateTime.parse(json['approved_at'] as String)
          : null,
      approvedBy: json['approved_by'] as String?,
      authUserId: json['auth_user_id'] as String?,
      email: json['email'] as String?,
    );
  }

  UserModel copyWith({
    String? id,
    String? phoneNumber,
    String? otpCode,
    DateTime? otpCreatedAt,
    String? fullName,
    String? profilePictureUrl,
    LanguagePreference? languagePreference,
    DateTime? birthday,
    String? city,
    GenderType? gender,
    String? deviceModel,
    Map<String, dynamic>? socialMediaLinks,
    String? profession,
    String? bio,
    String? description,
    int? pointsBalance,
    UserStatus? status,
    UserRole? role,
    bool? isOnline,
    DateTime? lastSeenAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? approvedAt,
    String? approvedBy,
    String? authUserId,
    String? email,
  }) {
    return UserModel(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      otpCode: otpCode ?? this.otpCode,
      otpCreatedAt: otpCreatedAt ?? this.otpCreatedAt,
      fullName: fullName ?? this.fullName,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      languagePreference: languagePreference ?? this.languagePreference,
      birthday: birthday ?? this.birthday,
      city: city ?? this.city,
      gender: gender ?? this.gender,
      deviceModel: deviceModel ?? this.deviceModel,
      socialMediaLinks: socialMediaLinks ?? this.socialMediaLinks,
      profession: profession ?? this.profession,
      bio: bio ?? this.bio,
      description: description ?? this.description,
      pointsBalance: pointsBalance ?? this.pointsBalance,
      status: status ?? this.status,
      role: role ?? this.role,
      isOnline: isOnline ?? this.isOnline,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      approvedAt: approvedAt ?? this.approvedAt,
      approvedBy: approvedBy ?? this.approvedBy,
      authUserId: authUserId ?? this.authUserId,
      email: email ?? this.email,
    );
  }

  /// Check if OTP is valid (not expired)
  bool get isOtpValid {
    if (otpCode == null || otpCreatedAt == null) return false;
    final now = DateTime.now();
    final difference = now.difference(otpCreatedAt!);
    return difference.inMinutes < 10; // OTP valid for 10 minutes
  }

  /// Check if user is approved
  bool get isApproved => status == UserStatus.approved;

  /// Check if user can login
  bool get canLogin {
    return status != UserStatus.rejected && status != UserStatus.suspended;
  }
}
