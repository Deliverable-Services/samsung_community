import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../data/core/exceptions/app_exception.dart';
import '../../data/core/utils/result.dart';
import '../../data/models/user_model.dart';
import 'supabase_service.dart';
import 'user_service.dart';
import 'otp_service.dart';
import 'signup_service.dart';

class AuthService {
  final UserService _userService;
  final OtpService _otpService;
  final SignupService _signupService;

  AuthService({
    UserService? userService,
    OtpService? otpService,
    SignupService? signupService,
  }) : _userService = userService ?? UserService(),
       _otpService = otpService ?? OtpService(),
       _signupService = signupService ?? SignupService();

  Future<Result<void>> signOut() async {
    try {
      await SupabaseService.signOut();
      return const Success(null);
    } catch (e) {
      debugPrint('Error in signOut: $e');
      return Failure(AppException.fromError(e).message);
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
      final errorStr = e.toString();
      final isNetworkError = errorStr.contains('SocketException') ||
          errorStr.contains('Failed host lookup') ||
          errorStr.contains('Network is unreachable');
      
      if (!isNetworkError) {
        debugPrint('Error in refreshSession: $e');
      }
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
              final errorStr = e.toString();
              final isNetworkError = errorStr.contains('SocketException') ||
                  errorStr.contains('Failed host lookup') ||
                  errorStr.contains('Network is unreachable');
              
              if (!isNetworkError) {
                debugPrint('Error refreshing expired session: $e');
              }
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
            .isFilter('deleted_at', null)
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
          .isFilter('deleted_at', null)
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
    return _userService.checkUserExists(phoneNumber);
  }

  Future<Result<Map<String, dynamic>?>> getUserDetailsByPhone(
    String phoneNumber,
  ) async {
    return _userService.getUserDetailsByPhone(phoneNumber);
  }

  Future<Result<String>> generateOTPForLogin(String phoneNumber) async {
    return _otpService.generateOTPForLogin(phoneNumber);
  }

  Future<Result<String>> signupWithPhone(String phoneNumber) async {
    try {
      final response = await SupabaseService.client.functions.invoke(
        'signup',
        body: {'phoneNumber': phoneNumber},
      );

      final rawData = response.data;
      debugPrint('EDGE RAW RESPONSE: $rawData');

      if (rawData == null) {
        return const Failure('Empty server response');
      }

      Map<String, dynamic> data;

      // ✅ Case 1: Map
      if (rawData is Map<String, dynamic>) {
        data = rawData;
      }
      // ✅ Case 2: JSON String
      else if (rawData is String) {
        data = jsonDecode(rawData) as Map<String, dynamic>;
      }
      else {
        return const Failure('Invalid server response format');
      }

      if (data['error'] != null) {
        return Failure(data['error'].toString());
      }

      final otp = data['otp'];
      if (otp == null) {
        return const Failure('OTP not received');
      }

      return Success(otp.toString());
    } catch (e, stack) {
      debugPrint('Signup Edge exception: $e');
      debugPrint('$stack');
      return Failure(e.toString());
    }
  }


  Future<Result<Map<String, dynamic>?>> checkUserForSignup(
    String phoneNumber,
  ) async {
    return _userService.checkUserForSignup(phoneNumber);
  }

  Future<Result<String>> createOrGetAuthUser(String phoneNumber) async {
    return _signupService.createOrGetAuthUser(phoneNumber);
  }

  Future<Result<void>> createOrUpdatePublicUser({
    required String phoneNumber,
    required String authUserId,
    Map<String, dynamic>? existingUserDetails,
  }) async {
    return _signupService.createOrUpdatePublicUser(
      phoneNumber: phoneNumber,
      authUserId: authUserId,
      existingUserDetails: existingUserDetails,
    );
  }

  Future<Result<String>> generateOTP(String phoneNumber) async {
    return _otpService.generateOTP(phoneNumber);
  }

  Future<Result<void>> verifyOTP({
    required String phoneNumber,
    required String otpCode,
  }) async {
    return _otpService.verifyOTP(phoneNumber: phoneNumber, otpCode: otpCode);
  }

  Future<Result<Map<String, dynamic>>> verifyOTPAndSignIn({
    required String phoneNumber,
    required String otpCode,
  }) async {
    return _otpService.verifyOTPAndSignIn(
      phoneNumber: phoneNumber,
      otpCode: otpCode,
    );
  }

  Future<Result<UserModel>> saveProfile({
    required String phoneNumber,
    required Map<String, dynamic> profileData,
  }) async {
    return _userService.saveProfile(
      phoneNumber: phoneNumber,
      profileData: profileData,
    );
  }
}
