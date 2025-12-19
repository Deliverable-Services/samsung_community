import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../data/constants/app_consts.dart';
import '../../data/core/exceptions/app_exception.dart';
import '../../data/core/utils/result.dart';
import '../../data/models/user_model.dart';
import 'supabase_service.dart';

class AuthService {
  Future<Result<void>> signOut() async {
    try {
      await SupabaseService.signOut();
      return const Success(null);
    } catch (e) {
      debugPrint('Error in signOut: $e');
      return Failure(AppException.fromError(e).message);
    }
  }

  Future<bool> _confirmUserEmail(String userId, {String? accessToken}) async {
    String? token;
    String? edgeFunctionUrl;

    try {
      final isAlreadyConfirmed = await _checkEmailConfirmedStatus(userId);
      if (isAlreadyConfirmed) {
        return true;
      }

      token = accessToken;
      if (token == null) {
        final currentSession = SupabaseService.client.auth.currentSession;
        token = currentSession?.accessToken;
      }

      if (token == null) {
        final anonKey = AppConst.supabaseAnonKey;
        if (anonKey.isNotEmpty) {
          token = anonKey;
        } else {
          return false;
        }
      }

      final supabaseUrl = AppConst.supabaseUrl;
      if (supabaseUrl.isEmpty) {
        return false;
      }

      edgeFunctionUrl = '$supabaseUrl/functions/v1/auto-confirm-user';

      if (token.isEmpty) {
        return false;
      }

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'apikey': AppConst.supabaseAnonKey,
      };

      final body = jsonEncode({'user_id': userId});

      final response = await http
          .post(Uri.parse(edgeFunctionUrl), headers: headers, body: body)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception(
                'Edge Function request timed out after 10 seconds',
              );
            },
          );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        await Future.delayed(const Duration(milliseconds: 500));

        final isConfirmed = await _checkEmailConfirmedStatus(userId);
        if (isConfirmed) {
          return true;
        } else {
          return true;
        }
      } else {
        return false;
      }
    } catch (e) {
      debugPrint('Error in _confirmUserEmail: $e');
      return false;
    }
  }

  Future<bool> _checkEmailConfirmedStatus(String userId) async {
    try {
      final currentUser = SupabaseService.auth.currentUser;
      if (currentUser != null && currentUser.id == userId) {
        return currentUser.emailConfirmedAt != null;
      }
      return false;
    } catch (e) {
      debugPrint('Could not verify email confirmation status: $e');
      return false;
    }
  }

  Future<bool> refreshSession() async {
    try {
      final response = await SupabaseService.auth.refreshSession();
      if (response.session != null) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error in refreshSession: $e');
      return false;
    }
  }

  Future<bool> restoreSession() async {
    try {
      final currentSession = SupabaseService.client.auth.currentSession;
      if (currentSession != null) {
        final expiresAt = currentSession.expiresAt;
        if (expiresAt != null) {
          final expiresAtDateTime = DateTime.fromMillisecondsSinceEpoch(
            expiresAt * 1000,
          );
          if (DateTime.now().isAfter(expiresAtDateTime)) {
            try {
              await SupabaseService.auth.refreshSession();
              return true;
            } catch (e) {
              debugPrint('Error refreshing expired session: $e');
              return false;
            }
          }
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error in restoreSession: $e');
      return false;
    }
  }

  Future<Result<UserModel?>> getCurrentUser() async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) {
        return const Success(null);
      }

      final phoneNumber = user.phone;
      if (phoneNumber != null) {
        final normalizedPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');
        final response = await SupabaseService.client
            .from('users')
            .select()
            .eq('phone_number', normalizedPhone)
            .maybeSingle();

        if (response != null) {
          final userModel = UserModel.fromJson(response);
          return Success(userModel);
        }
      }

      final responseById = await SupabaseService.client
          .from('users')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (responseById != null) {
        final userModel = UserModel.fromJson(responseById);
        return Success(userModel);
      }

      DateTime parseDateTime(Object? value) {
        if (value == null) return DateTime.now();
        if (value is DateTime) return value;
        if (value is String) {
          try {
            return DateTime.parse(value);
          } catch (_) {
            return DateTime.now();
          }
        }
        return DateTime.now();
      }

      final createdAt = parseDateTime(user.createdAt);
      final updatedAt = parseDateTime(user.updatedAt);

      final userModel = UserModel(
        id: user.id,
        phoneNumber: user.phone ?? '',
        languagePreference: LanguagePreference.en,
        socialMediaLinks: {},
        pointsBalance: 0,
        status: UserStatus.pending,
        role: UserRole.user,
        isOnline: false,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      return Success(userModel);
    } catch (e) {
      debugPrint('Error in getCurrentUser: $e');
      return Failure(AppException.fromError(e).message);
    }
  }

  bool get isAuthenticated => SupabaseService.isAuthenticated;

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

  Future<Result<String>> generateOTPForLogin(String phoneNumber) async {
    try {
      final normalizedPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');

      final userDetailsResult = await getUserDetailsByPhone(normalizedPhone);
      if (userDetailsResult.isFailure) {
        return Failure(userDetailsResult.errorOrNull ?? 'Failed to check user');
      }

      final userDetails = userDetailsResult.dataOrNull;

      if (userDetails == null) {
        return const Failure('USER_NOT_FOUND');
      }

      final status = userDetails['status'] as String?;

      if (status != null && status == 'pending') {
        return const Failure('WAIT_FOR_APPROVAL');
      }
      if (status != null && status == 'suspended') {
        return const Failure('USER_SUSPENDED');
      }
      if (status != null && status == 'rejected') {
        return const Failure('USER_REJECTED');
      }

      final now = DateTime.now().toUtc().toIso8601String();
      final random = DateTime.now().millisecondsSinceEpoch;
      final otpCode = (100000 + (random % 900000)).toString();

      await SupabaseService.client
          .from('users')
          .update({
            'otp_code': otpCode,
            'otp_created_at': now,
            'updated_at': now,
          })
          .eq('phone_number', normalizedPhone);

      return Success(otpCode);
    } catch (e) {
      debugPrint('Error in generateOTPForLogin: $e');
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
        return Failure(userDetailsResult.errorOrNull ?? 'Failed to check user');
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
          return const Failure('Failed to create auth user');
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
            'Failed to create or find auth user: ${AppException.fromError(createError).message}',
          );
        }
        return Failure(
          'Failed to create auth user: ${AppException.fromError(createError).message}',
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
                'Failed to create public user: ${AppException.fromError(insertError).message}',
              );
            }
          }
        }
        return const Failure('Failed to create public user after retries');
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

  Future<Result<String>> generateOTP(String phoneNumber) async {
    try {
      final normalizedPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');
      final now = DateTime.now().toUtc().toIso8601String();

      final random = DateTime.now().millisecondsSinceEpoch;
      final otpCode = (100000 + (random % 900000)).toString();

      await SupabaseService.client
          .from('users')
          .update({
            'otp_code': otpCode,
            'otp_created_at': now,
            'updated_at': now,
          })
          .eq('phone_number', normalizedPhone);

      debugPrint('✅ Generated OTP for signup: $otpCode');
      return Success(otpCode);
    } catch (e) {
      debugPrint('Error in generateOTP: $e');
      return Failure(AppException.fromError(e).message);
    }
  }

  Future<Result<void>> verifyOTP({
    required String phoneNumber,
    required String otpCode,
  }) async {
    try {
      final normalizedPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');

      final response = await SupabaseService.client
          .from('users')
          .select('otp_code, otp_created_at')
          .eq('phone_number', normalizedPhone)
          .maybeSingle();

      if (response == null) {
        return const Failure('OTP_INCORRECT');
      }

      final storedOtp = response['otp_code'] as String?;
      final otpCreatedAtValue = response['otp_created_at'];

      if (otpCreatedAtValue != null) {
        try {
          DateTime otpCreatedAt;

          if (otpCreatedAtValue is DateTime) {
            otpCreatedAt = otpCreatedAtValue.toUtc();
          } else if (otpCreatedAtValue is String) {
            otpCreatedAt = DateTime.parse(otpCreatedAtValue).toUtc();
          } else {
            return const Failure('OTP_EXPIRED');
          }

          final now = DateTime.now().toUtc();
          final difference = now.difference(otpCreatedAt);

          if (difference.inMinutes >= 10) {
            return const Failure('OTP_EXPIRED');
          }
        } catch (e) {
          debugPrint('Error parsing OTP created_at: $e, value: $otpCreatedAtValue');
          return const Failure('OTP_EXPIRED');
        }
      } else {
        return const Failure('OTP_EXPIRED');
      }

      if (storedOtp == null || storedOtp != otpCode) {
        return const Failure('OTP_INCORRECT');
      }

      return const Success(null);
    } catch (e) {
      debugPrint('Error in verifyOTP: $e');
      return Failure(AppException.fromError(e).message);
    }
  }

  Future<Result<Map<String, dynamic>>> verifyOTPAndSignIn({
    required String phoneNumber,
    required String otpCode,
  }) async {
    try {
      final verifyResult = await verifyOTP(
        phoneNumber: phoneNumber,
        otpCode: otpCode,
      );

      if (verifyResult.isFailure) {
        return Failure(verifyResult.errorOrNull ?? 'OTP verification failed');
      }

      final normalizedPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');
      final authEmail = 'temp_$normalizedPhone@temp.com';
      final authPassword = authEmail;

      try {
        final userResponse = await SupabaseService.client
            .from('users')
            .select()
            .eq('phone_number', normalizedPhone)
            .maybeSingle();

        if (userResponse == null) {
          return const Failure('User not found in database');
        }

        final userIdValue = userResponse['id'];
        if (userIdValue == null) {
          return const Failure('User ID not found');
        }
        final userId = userIdValue as String;

        dynamic authResponse;
        try {
          authResponse = await SupabaseService.auth.signInWithPassword(
            email: authEmail,
            password: authPassword,
          );

          final signedInUserId = authResponse.user?.id;
          final session = authResponse.session;
          if (signedInUserId != null && session != null) {
            final isConfirmed = await _checkEmailConfirmedStatus(
              signedInUserId,
            );
            if (!isConfirmed) {
              await _confirmUserEmail(
                signedInUserId,
                accessToken: session.accessToken,
              );
            }
          }
        } catch (signInError) {
          try {
            final signUpResponse = await SupabaseService.auth.signUp(
              email: authEmail,
              password: authPassword,
              data: {'phone': normalizedPhone},
            );

            if (signUpResponse.user == null) {
              return const Failure('Failed to create auth user');
            }

            final authUserId = signUpResponse.user!.id;
            final signUpSession = signUpResponse.session;

            String? token = signUpSession?.accessToken;

            await _confirmUserEmail(
              authUserId,
              accessToken: token,
            );

            await Future.delayed(const Duration(milliseconds: 1000));

            try {
              authResponse = await SupabaseService.auth.signInWithPassword(
                email: authEmail,
                password: authPassword,
              );
            } catch (retryError) {
              await Future.delayed(const Duration(milliseconds: 2000));
              try {
                authResponse = await SupabaseService.auth.signInWithPassword(
                  email: authEmail,
                  password: authPassword,
                );
              } catch (finalError) {
                return Failure(
                  'Failed to sign in after email confirmation: ${AppException.fromError(finalError).message}',
                );
              }
            }
          } catch (createError) {
            if (createError.toString().contains('already registered') ||
                createError.toString().contains('User already registered')) {
              authResponse = await SupabaseService.auth.signInWithPassword(
                email: authEmail,
                password: authPassword,
              );
            } else {
              return Failure(
                'Failed to create or sign in: ${AppException.fromError(createError).message}',
              );
            }
          }
        }

        if (authResponse == null || authResponse.session == null) {
          return const Failure('Failed to create session');
        }

        final session = authResponse.session!;
        final authUserId = authResponse.user?.id ?? userId;

        UserModel? userProfile;
        final finalUserResponse = await SupabaseService.client
            .from('users')
            .select()
            .eq('id', authUserId)
            .maybeSingle();

        if (finalUserResponse != null) {
          userProfile = UserModel.fromJson(finalUserResponse);
        }

        return Success({
          'access_token': session.accessToken,
          'refresh_token': session.refreshToken,
          'expires_at': session.expiresAt,
          'user': userProfile?.toJson(),
        });
      } catch (e) {
        debugPrint('Error signing in after OTP verification: $e');
        return Failure(AppException.fromError(e).message);
      }
    } catch (e) {
      debugPrint('Error in verifyOTPAndSignIn: $e');
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

      // Map profile data to database column names
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
