import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../data/core/exceptions/app_exception.dart';
import '../../data/core/utils/result.dart';
import 'supabase_service.dart';

class SignupService {
  Future<Result<String>> createOrGetAuthUser(String phoneNumber) async {
    try {
      final normalizedPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');
      final authEmail = 'temp_$normalizedPhone@temp.com';
      final authPassword = authEmail;

      try {
        final authUserCheck = await SupabaseService.client.rpc(
          'check_auth_user_by_phone',
          params: {'phone_number': normalizedPhone},
        );

        if (authUserCheck != null) {
          String? authUserId;
          if (authUserCheck is Map) {
            authUserId = authUserCheck['id'] as String?;
          } else if (authUserCheck is String) {
            authUserId = authUserCheck;
          } else if (authUserCheck is List && authUserCheck.isNotEmpty) {
            final firstResult = authUserCheck[0];
            if (firstResult is Map) {
              authUserId = firstResult['id'] as String?;
            }
          }

          if (authUserId != null && authUserId.isNotEmpty) {
            return Success(authUserId);
          }
        }
      } catch (rpcError) {
        final userResponse = await SupabaseService.client
            .from('users')
            .select('auth_user_id, id')
            .eq('phone_number', normalizedPhone)
            .maybeSingle();

        if (userResponse != null) {
          final authUserId =
              userResponse['auth_user_id'] as String? ??
              userResponse['id'] as String?;
          if (authUserId != null && authUserId.isNotEmpty) {
            return Success(authUserId);
          }
        }
      }

      try {
        final signUpResponse = await SupabaseService.auth.signUp(
          email: authEmail,
          password: authPassword,
          data: {'phone': normalizedPhone},
        );

        if (signUpResponse.user == null) {
          return Failure('failedToCreateAuthUser'.tr);
        }

        final authUserId = signUpResponse.user!.id;

        await Future.delayed(const Duration(milliseconds: 2000));
        return Success(authUserId);
      } catch (createError) {
        final errorString = createError.toString();
        if (errorString.contains('already registered') ||
            errorString.contains('User already registered')) {
          final retryUserResponse = await SupabaseService.client
              .from('users')
              .select('auth_user_id, id')
              .eq('phone_number', normalizedPhone)
              .maybeSingle();

          if (retryUserResponse != null) {
            final authUserId =
                retryUserResponse['auth_user_id'] as String? ??
                retryUserResponse['id'] as String?;
            if (authUserId != null && authUserId.isNotEmpty) {
              return Success(authUserId);
            }
          }
          return Failure(
            '${'failedToCreateOrFindAuthUser'.tr}: ${AppException.fromError(createError).message}',
          );
        }
        return Failure(
          '${'failedToCreateAuthUser'.tr}: ${AppException.fromError(createError).message}',
        );
      }
    } catch (e) {
      debugPrint('Error in createOrGetAuthUser: $e');
      return Failure(AppException.fromError(e).message);
    }
  }

  Future<Result<void>> createOrUpdatePublicUser({
    required String phoneNumber,
    required String authUserId,
    Map<String, dynamic>? existingUserDetails,
  }) async {
    try {
      final normalizedPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');
      final now = DateTime.now().toUtc().toIso8601String();

      if (existingUserDetails == null) {
        final insertData = {
          'id': authUserId,
          'phone_number': normalizedPhone,
          'role': 'user',
          'status': 'pending',
          'language_preference': 'en',
          'social_media_links': {},
          'points_balance': 0,
          'is_online': false,
          'created_at': now,
          'updated_at': now,
          'auth_user_id': authUserId,
        };

        int retryCount = 0;
        const maxRetries = 5;
        while (retryCount < maxRetries) {
          try {
            await SupabaseService.client
                .from('users')
                .insert(insertData)
                .select()
                .single();
            return const Success(null);
          } catch (insertError) {
            final errorString = insertError.toString();
            if (errorString.contains('23503') && retryCount < maxRetries - 1) {
              retryCount++;
              final delayMs = 1000 * (1 << retryCount);
              await Future.delayed(Duration(milliseconds: delayMs));
            } else {
              final existingUser = await SupabaseService.client
                  .from('users')
                  .select()
                  .eq('phone_number', normalizedPhone)
                  .maybeSingle();

              if (existingUser != null) {
                return const Success(null);
              }

              return Failure(
                '${'failedToCreatePublicUser'.tr}: ${AppException.fromError(insertError).message}',
              );
            }
          }
        }
        return Failure('failedToCreatePublicUserAfterRetries'.tr);
      } else {
        try {
          await SupabaseService.client
              .from('users')
              .update({
                'auth_user_id': authUserId,
                'status': 'pending',
                'updated_at': now,
              })
              .eq('phone_number', normalizedPhone);
          return const Success(null);
        } catch (updateError) {
          return const Success(null);
        }
      }
    } catch (e) {
      debugPrint('Error in createOrUpdatePublicUser: $e');
      return Failure(AppException.fromError(e).message);
    }
  }
}
