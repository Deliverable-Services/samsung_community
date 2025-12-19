import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../data/core/exceptions/app_exception.dart';
import '../../data/core/utils/result.dart';
import '../../data/models/user_model.dart';
import 'supabase_service.dart';

class UserService {
  Future<Result<bool>> checkUserExists(String phoneNumber) async {
    try {
      final normalizedPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');

      final response = await SupabaseService.client
          .from('users')
          .select('id')
          .eq('phone_number', normalizedPhone)
          .maybeSingle();

      return Success(response != null);
    } catch (e) {
      debugPrint('Error in checkUserExists: $e');
      return Failure(AppException.fromError(e).message);
    }
  }

  Future<Result<Map<String, dynamic>?>> getUserDetailsByPhone(
    String phoneNumber,
  ) async {
    try {
      final normalizedPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');

      final response = await SupabaseService.client
          .from('users')
          .select('id, status, role, device_model')
          .eq('phone_number', normalizedPhone)
          .maybeSingle();

      if (response == null) {
        return const Success(null);
      }

      return Success({
        'id': response['id'] as String?,
        'status': response['status'] as String?,
        'role': response['role'] as String?,
        'device_model': response['device_model'] as String?,
      });
    } catch (e) {
      debugPrint('Error in getUserDetailsByPhone: $e');
      return Failure(AppException.fromError(e).message);
    }
  }

  Future<Result<Map<String, dynamic>?>> checkUserForSignup(
    String phoneNumber,
  ) async {
    try {
      final normalizedPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');

      final userDetailsResult = await getUserDetailsByPhone(normalizedPhone);
      if (userDetailsResult.isFailure) {
        return Failure(userDetailsResult.errorOrNull ?? 'failedToCheckUser'.tr);
      }

      final userDetails = userDetailsResult.dataOrNull;

      if (userDetails != null) {
        final deviceModel = userDetails['device_model'] as String?;

        if (deviceModel != null && deviceModel.isNotEmpty) {
          return const Failure('USER_ALREADY_SIGNED_UP');
        }

        return Success(userDetails);
      }

      return const Success(null);
    } catch (e) {
      debugPrint('Error in checkUserForSignup: $e');
      return Failure(AppException.fromError(e).message);
    }
  }

  Future<Result<UserModel>> saveProfile({
    required String phoneNumber,
    required Map<String, dynamic> profileData,
  }) async {
    try {
      final normalizedPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');

      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };

      if (profileData.containsKey('fullName')) {
        updateData['full_name'] = profileData['fullName'];
      }
      if (profileData.containsKey('email')) {
        updateData['email'] = profileData['email'];
      }
      if (profileData.containsKey('companyName')) {
        updateData['company_name'] = profileData['companyName'];
      }
      if (profileData.containsKey('languagePreference')) {
        updateData['language_preference'] = profileData['languagePreference'];
      }
      if (profileData.containsKey('deviceModel')) {
        updateData['device_model'] = profileData['deviceModel'];
      }
      if (profileData.containsKey('birthday')) {
        updateData['birthday'] = profileData['birthday'];
      }
      if (profileData.containsKey('city')) {
        updateData['city'] = profileData['city'];
      }
      if (profileData.containsKey('gender')) {
        updateData['gender'] = profileData['gender'];
      }
      if (profileData.containsKey('profession')) {
        updateData['profession'] = profileData['profession'];
      }
      if (profileData.containsKey('bio')) {
        updateData['bio'] = profileData['bio'];
      }
      if (profileData.containsKey('college')) {
        updateData['college'] = profileData['college'];
      }
      if (profileData.containsKey('className')) {
        updateData['class_name'] = profileData['className'];
      }
      if (profileData.containsKey('socialMediaLinks')) {
        updateData['social_media_links'] = profileData['socialMediaLinks'];
      }
      if (profileData.containsKey('profilePictureUrl')) {
        updateData['profile_picture_url'] = profileData['profilePictureUrl'];
      }

      final response = await SupabaseService.client
          .from('users')
          .update(updateData)
          .eq('phone_number', normalizedPhone)
          .select()
          .single();

      final userModel = UserModel.fromJson(response);

      return Success(userModel);
    } catch (e) {
      debugPrint('Error in saveProfile: $e');
      return Failure(AppException.fromError(e).message);
    }
  }
}
