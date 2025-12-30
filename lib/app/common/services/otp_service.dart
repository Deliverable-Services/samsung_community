import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../data/core/exceptions/app_exception.dart';
import '../../data/core/utils/result.dart';
import '../../data/models/user_model.dart';
import 'supabase_service.dart';
import 'user_service.dart';
import 'email_confirmation_service.dart';

class OtpService {
  final UserService _userService;
  final EmailConfirmationService _emailConfirmationService;

  OtpService({
    UserService? userService,
    EmailConfirmationService? emailConfirmationService,
  }) : _userService = userService ?? UserService(),
       _emailConfirmationService =
           emailConfirmationService ?? EmailConfirmationService();

  Future<Result<String>> generateOTPForLogin(String phoneNumber) async {
    try {
      final normalizedPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');

      final userDetailsResult = await _userService.getUserDetailsByPhone(
        normalizedPhone,
      );
      if (userDetailsResult.isFailure) {
        return Failure(userDetailsResult.errorOrNull ?? 'failedToCheckUser'.tr);
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
          debugPrint(
            'Error parsing OTP created_at: $e, value: $otpCreatedAtValue',
          );
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
        return Failure(verifyResult.errorOrNull ?? 'otpVerificationFailed'.tr);
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
          return Failure('userNotFound'.tr);
        }

        final userIdValue = userResponse['id'];
        if (userIdValue == null) {
          return Failure('userIdNotFound'.tr);
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
            final isConfirmed = await _emailConfirmationService
                .checkEmailConfirmedStatus(signedInUserId);
            if (!isConfirmed) {
              await _emailConfirmationService.confirmUserEmail(
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
              return Failure('failedToCreateAuthUser'.tr);
            }

            final authUserId = signUpResponse.user!.id;
            final signUpSession = signUpResponse.session;

            String? token = signUpSession?.accessToken;

            await _emailConfirmationService.confirmUserEmail(
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
                  '${'failedToSignInAfterEmailConfirmation'.tr}: ${AppException.fromError(finalError).message}',
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
                '${'failedToCreateOrSignIn'.tr}: ${AppException.fromError(createError).message}',
              );
            }
          }
        }

        if (authResponse == null || authResponse.session == null) {
          return Failure('failedToCreateSession'.tr);
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
}
