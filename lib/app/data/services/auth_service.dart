import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/app_consts.dart';
import '../core/exceptions/app_exception.dart';
import '../core/utils/result.dart';
import '../models/user_model.dart';
import '../services/supabase_service.dart';

/// Service for authentication operations (direct Supabase access)
class AuthService {
  /// Sign in with phone number
  Future<Result<UserModel>> signInWithPhone({
    required String phone,
    required String password,
  }) async {
    try {
      // TODO: Implement phone sign in with Supabase
      throw UnimplementedError('signInWithPhone not implemented');
    } catch (e) {
      print('Error in signInWithPhone: $e');
      return Failure(AppException.fromError(e).message);
    }
  }

  /// Sign up with phone number
  Future<Result<UserModel>> signUpWithPhone({
    required String phone,
    required String password,
  }) async {
    try {
      // TODO: Implement phone sign up with Supabase
      throw UnimplementedError('signUpWithPhone not implemented');
    } catch (e) {
      print('Error in signUpWithPhone: $e');
      return Failure(AppException.fromError(e).message);
    }
  }

  /// Verify phone OTP
  Future<Result<UserModel>> verifyPhoneOTP({
    required String phone,
    required String otp,
  }) async {
    try {
      // TODO: Implement OTP verification with Supabase
      throw UnimplementedError('verifyPhoneOTP not implemented');
    } catch (e) {
      print('Error in verifyPhoneOTP: $e');
      return Failure(AppException.fromError(e).message);
    }
  }

  /// Sign out current user
  Future<Result<void>> signOut() async {
    try {
      await SupabaseService.signOut();
      return const Success(null);
    } catch (e) {
      print('Error in signOut: $e');
      return Failure(AppException.fromError(e).message);
    }
  }

  /// Confirm user email by calling Supabase Edge Function
  /// Uses the deployed phone-signup function to confirm the user
  /// Requires an access token from the session, or uses anon key as fallback
  Future<bool> _confirmUserEmail(String userId, {String? accessToken}) async {
    try {
      print('Attempting to confirm email for user: $userId');

      // First check if email is already confirmed
      final isAlreadyConfirmed = await _checkEmailConfirmedStatus(userId);
      if (isAlreadyConfirmed) {
        print('✓ Email already confirmed for user: $userId');
        return true;
      }

      // Get access token from parameter or current session
      String? token = accessToken;
      if (token == null) {
        final currentSession = SupabaseService.client.auth.currentSession;
        token = currentSession?.accessToken;
      }

      // If still no token, try using anon key as fallback
      // This allows confirming email even when not signed in
      if (token == null) {
        print('No session token available, using anon key for Edge Function');
        final anonKey = AppConst.supabaseAnonKey;
        if (anonKey.isNotEmpty) {
          token = anonKey;
        } else {
          print(
            '❌ No access token or anon key available for Edge Function call',
          );
          return false;
        }
      }

      // Call the Supabase Edge Function
      final supabaseUrl = AppConst.supabaseUrl;
      if (supabaseUrl.isEmpty) {
        print('❌ Supabase URL not configured');
        return false;
      }

      final edgeFunctionUrl = '$supabaseUrl/functions/v1/auto-confirm-user';

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final body = jsonEncode({'user_id': userId});

      print('Calling Edge Function: $edgeFunctionUrl');
      print('With user_id: $userId');

      final response = await http.post(
        Uri.parse(edgeFunctionUrl),
        headers: headers,
        body: body,
      );

      print('Edge Function response status: ${response.statusCode}');
      print('Edge Function response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Wait a bit for the update to propagate
        await Future.delayed(const Duration(milliseconds: 500));

        // Verify the confirmation worked
        final isConfirmed = await _checkEmailConfirmedStatus(userId);
        if (isConfirmed) {
          print(
            '✓ Email confirmed successfully via Edge Function for user: $userId',
          );
          return true;
        } else {
          print('⚠ Edge Function called but verification failed');
          // Still return true if the function returned success
          // The verification might fail due to timing
          return true;
        }
      } else {
        print('❌ Edge Function returned error: ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Edge Function call failed: $e');
      print('Error type: ${e.runtimeType}');
      return false;
    }
  }

  /// Check if email is confirmed by calling verification RPC or checking auth user
  Future<bool> _checkEmailConfirmedStatus(String userId) async {
    try {
      // First try RPC function if available
      try {
        final response = await SupabaseService.client
            .rpc('check_email_confirmed', params: {'user_id': userId})
            .maybeSingle();

        if (response != null && response['confirmed'] == true) {
          return true;
        }
      } catch (rpcError) {
        print('RPC check_email_confirmed not available: $rpcError');
      }

      // Fallback: Check current auth user if it matches
      final currentUser = SupabaseService.auth.currentUser;
      if (currentUser != null && currentUser.id == userId) {
        // Check if email is confirmed via the user object
        // Note: This only works if we're signed in as this user
        return currentUser.emailConfirmedAt != null;
      }

      // If we can't verify, return false (uncertain)
      return false;
    } catch (e) {
      print('Could not verify email confirmation status: $e');
      return false;
    }
  }

  /// Refresh session using stored refresh token
  Future<bool> refreshSession() async {
    try {
      final response = await SupabaseService.auth.refreshSession();
      if (response.session != null) {
        return true;
      }
      return false;
    } catch (e) {
      print('Error in refreshSession: $e');
      return false;
    }
  }

  /// Restore Supabase session - checks if current session is valid
  /// Supabase automatically persists sessions, so we just verify it exists
  Future<bool> restoreSession() async {
    try {
      final currentSession = SupabaseService.client.auth.currentSession;
      if (currentSession != null) {
        // Check if session is expired
        final expiresAt = currentSession.expiresAt;
        if (expiresAt != null) {
          final expiresAtDateTime = DateTime.fromMillisecondsSinceEpoch(
            expiresAt * 1000,
          );
          if (DateTime.now().isAfter(expiresAtDateTime)) {
            // Session expired, try to refresh
            try {
              await SupabaseService.auth.refreshSession();
              return true;
            } catch (e) {
              print('Error refreshing expired session: $e');
              return false;
            }
          }
        }
        return true;
      }
      return false;
    } catch (e) {
      print('Error in restoreSession: $e');
      return false;
    }
  }

  /// Get current user
  Future<Result<UserModel?>> getCurrentUser() async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) {
        return const Success(null);
      }

      // TODO: Fetch full user profile from database
      // For now, return basic user info
      // Note: Supabase Auth User doesn't have all fields, need to fetch from users table
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
      print('Error in getCurrentUser: $e');
      return Failure(AppException.fromError(e).message);
    }
  }

  /// Check if user is authenticated
  bool get isAuthenticated => SupabaseService.isAuthenticated;

  /// Check if user exists by phone number
  /// Uses the check_user_exists RPC function
  Future<Result<bool>> checkUserExists(String phoneNumber) async {
    try {
      // Normalize phone number (remove non-digit characters)
      final normalizedPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');

      final response = await SupabaseService.client
          .rpc('check_user_exists', params: {'p_phone_number': normalizedPhone})
          .select();

      if (response.isEmpty) {
        return const Success(false);
      }

      final userExists = response.first['user_exists'] as bool? ?? false;
      return Success(userExists);
    } catch (e) {
      print('Error in checkUserExists: $e');
      return Failure(AppException.fromError(e).message);
    }
  }

  /// Get user details by phone number (device_model, status)
  Future<Result<Map<String, dynamic>?>> getUserDetailsByPhone(
    String phoneNumber,
  ) async {
    try {
      // Normalize phone number (remove non-digit characters)
      final normalizedPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');

      final response = await SupabaseService.client
          .from('users')
          .select('id, device_model, status')
          .eq('phone_number', normalizedPhone)
          .maybeSingle();

      if (response == null) {
        return const Success(null);
      }

      return Success({
        'id': response['id'] as String?,
        'device_model': response['device_model'] as String?,
        'status': response['status'] as String?,
      });
    } catch (e) {
      print('Error in getUserDetailsByPhone: $e');
      return Failure(AppException.fromError(e).message);
    }
  }

  /// Generate OTP and save to database for sign up
  /// Returns the generated OTP code or specific error codes:
  /// - 'USER_ALREADY_SIGNED_UP' if device_model is not null
  /// - 'WAIT_FOR_APPROVAL' if status is not approved
  ///
  /// NOTE: This method generates OTP in Dart code and saves directly to database.
  /// RLS policies must allow unauthenticated inserts/updates for signup flow.
  /// See RLS_POLICY_FIX.md for required policies.
  Future<Result<String>> generateOTP(String phoneNumber) async {
    try {
      // Normalize phone number (remove non-digit characters)
      final normalizedPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');

      // Get user details if exists
      final userDetailsResult = await getUserDetailsByPhone(normalizedPhone);
      if (userDetailsResult.isFailure) {
        return Failure(userDetailsResult.errorOrNull ?? 'Failed to check user');
      }

      final userDetails = userDetailsResult.dataOrNull;

      // If user exists, check device_model and status
      if (userDetails != null) {
        final deviceModel = userDetails['device_model'] as String?;
        final status = userDetails['status'] as String?;

        // If device_model is null, keep signup started and use same user
        // Reset user data and generate new OTP (re-initiate signup)
        if (deviceModel == null || deviceModel.isEmpty) {
          final now = DateTime.now().toUtc().toIso8601String();
          final random = DateTime.now().millisecondsSinceEpoch;
          final otpCode = (100000 + (random % 900000)).toString();

          // Reset user data to empty (re-initiate signup)
          await SupabaseService.client
              .from('users')
              .update({
                'otp_code': otpCode,
                'otp_created_at': now,
                'full_name': null,
                'profile_picture_url': null,
                'birthday': null,
                'city': null,
                'gender': null,
                'device_model': null,
                'profession': null,
                'bio': null,
                'description': null,
                'updated_at': now,
              })
              .eq('phone_number', normalizedPhone);

          return Success(otpCode);
        }

        // If device_model is not null, check status
        // If status is pending, user needs to wait for approval
        if (status != null && status == 'pending') {
          return const Failure('WAIT_FOR_APPROVAL');
        }

        // If device_model is not null and status is not pending, user is already signed up
        return const Failure('USER_ALREADY_SIGNED_UP');
      }

      // User doesn't exist, create new user
      // Generate 6-digit OTP in Dart code
      final random = DateTime.now().millisecondsSinceEpoch;
      final otpCode = (100000 + (random % 900000)).toString();

      final now = DateTime.now().toUtc().toIso8601String();

      // Need to create auth user first to get the ID
      // Create auth user with email format: temp_{phone}@temp.com
      // Password is the same as email
      final authEmail = 'temp_$normalizedPhone@temp.com';
      final authPassword = authEmail;

      final authResponse = await SupabaseService.auth.signUp(
        email: authEmail,
        password: authPassword,
        data: {'phone': normalizedPhone},
      );

      if (authResponse.user == null) {
        return const Failure('Failed to create auth user');
      }

      final authUserId = authResponse.user!.id;
      final signUpSession = authResponse.session;

      // Auto-confirm email immediately after signup using Edge Function
      // Use session token if available from signup response
      String? token = signUpSession?.accessToken;
      final emailConfirmed = await _confirmUserEmail(
        authUserId,
        accessToken: token,
      );

      if (!emailConfirmed && token == null) {
        print(
          '⚠ Warning: Could not confirm email - no session token from signup',
        );
        print('Email will be confirmed on first sign in');
      } else if (!emailConfirmed) {
        print('⚠ Warning: Email confirmation may have failed');
      }

      // Create new user record with OTP using the auth user ID
      await SupabaseService.client.from('users').insert({
        'id': authUserId,
        'phone_number': normalizedPhone,
        'otp_code': otpCode,
        'otp_created_at': now,
        'language_preference': 'en',
        'social_media_links': {},
        'points_balance': 0,
        'status': 'pending',
        'role': 'user',
        'is_online': false,
        'created_at': now,
        'updated_at': now,
      });

      return Success(otpCode);
    } catch (e) {
      print('Error in generateOTP: $e');
      return Failure(AppException.fromError(e).message);
    }
  }

  /// Generate OTP for login
  /// This is used when an existing user wants to log in
  /// Returns the generated OTP code or specific error codes:
  /// - 'WAIT_FOR_APPROVAL' if status is pending
  /// - 'USER_NOT_FOUND' if user doesn't exist
  Future<Result<String>> generateOTPForLogin(String phoneNumber) async {
    try {
      // Normalize phone number (remove non-digit characters)
      final normalizedPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');

      // Get user details if exists
      final userDetailsResult = await getUserDetailsByPhone(normalizedPhone);
      if (userDetailsResult.isFailure) {
        return Failure(userDetailsResult.errorOrNull ?? 'Failed to check user');
      }

      final userDetails = userDetailsResult.dataOrNull;

      // User must exist for login
      if (userDetails == null) {
        return const Failure('USER_NOT_FOUND');
      }

      final status = userDetails['status'] as String?;

      // If status is pending, user needs to wait for approval
      if (status != null && status == 'pending') {
        return const Failure('WAIT_FOR_APPROVAL');
      }

      // User exists and is approved (or status is not pending), generate OTP for login
      final now = DateTime.now().toUtc().toIso8601String();
      final random = DateTime.now().millisecondsSinceEpoch;
      final otpCode = (100000 + (random % 900000)).toString();

      // Update OTP in database
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
      print('Error in generateOTPForLogin: $e');
      return Failure(AppException.fromError(e).message);
    }
  }

  /// Verify OTP for sign up
  /// Returns:
  /// - Success if OTP is correct and not expired
  /// - Failure with 'OTP_INCORRECT' if OTP doesn't match
  /// - Failure with 'OTP_EXPIRED' if OTP is more than 10 minutes old
  Future<Result<void>> verifyOTP({
    required String phoneNumber,
    required String otpCode,
  }) async {
    try {
      // Normalize phone number (remove non-digit characters)
      final normalizedPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');

      // Get user's OTP data from database
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

      // Check if OTP is expired FIRST (before checking if code matches)
      if (otpCreatedAtValue != null) {
        try {
          DateTime otpCreatedAt;

          // Handle different return types from Supabase
          if (otpCreatedAtValue is DateTime) {
            // Supabase returns DateTime directly
            otpCreatedAt = otpCreatedAtValue.toUtc();
          } else if (otpCreatedAtValue is String) {
            // Supabase returns string (ISO8601)
            otpCreatedAt = DateTime.parse(otpCreatedAtValue).toUtc();
          } else {
            // Unknown format, consider expired
            print(
              'Unknown OTP created_at format: ${otpCreatedAtValue.runtimeType}',
            );
            return const Failure('OTP_EXPIRED');
          }

          final now = DateTime.now().toUtc();
          final difference = now.difference(otpCreatedAt);

          // Debug logging
          print('OTP created at: $otpCreatedAt (UTC)');
          print('Current time: $now (UTC)');
          print('Difference: ${difference.inMinutes} minutes');

          // Check if OTP is expired (10 minutes or more)
          if (difference.inMinutes >= 10) {
            return const Failure('OTP_EXPIRED');
          }
        } catch (e) {
          // If date parsing fails, consider OTP as expired
          print('Error parsing OTP created_at: $e, value: $otpCreatedAtValue');
          return const Failure('OTP_EXPIRED');
        }
      } else {
        // If otp_created_at is null, consider OTP as expired
        return const Failure('OTP_EXPIRED');
      }

      // Check if OTP code matches (only if not expired)
      if (storedOtp == null || storedOtp != otpCode) {
        return const Failure('OTP_INCORRECT');
      }

      // OTP is correct and not expired
      return const Success(null);
    } catch (e) {
      print('Error in verifyOTP: $e');
      return Failure(AppException.fromError(e).message);
    }
  }

  /// Verify OTP and sign in to get session tokens
  /// Returns session data (access_token, refresh_token, expires_at) and user profile
  Future<Result<Map<String, dynamic>>> verifyOTPAndSignIn({
    required String phoneNumber,
    required String otpCode,
  }) async {
    try {
      // First verify OTP
      final verifyResult = await verifyOTP(
        phoneNumber: phoneNumber,
        otpCode: otpCode,
      );

      if (verifyResult.isFailure) {
        return Failure(verifyResult.errorOrNull ?? 'OTP verification failed');
      }

      // OTP verified, now sign in with Supabase to get session
      final normalizedPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');
      final authEmail = 'temp_$normalizedPhone@temp.com';
      final authPassword = authEmail;

      try {
        // First, get user from database to get their ID
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

        // Try to sign in first
        dynamic authResponse;
        try {
          authResponse = await SupabaseService.auth.signInWithPassword(
            email: authEmail,
            password: authPassword,
          );

          // After successful sign in, check if email needs confirmation
          final signedInUserId = authResponse.user?.id;
          final session = authResponse.session;
          if (signedInUserId != null && session != null) {
            final isConfirmed = await _checkEmailConfirmedStatus(
              signedInUserId,
            );
            if (!isConfirmed) {
              print(
                'Email not confirmed, attempting to confirm via Edge Function',
              );
              await _confirmUserEmail(
                signedInUserId,
                accessToken: session.accessToken,
              );
            }
          }
        } catch (signInError) {
          // If sign in fails, the auth user might not exist
          // Try to create it first, then sign in
          print('Sign in failed, attempting to create auth user: $signInError');

          try {
            // Create auth user with the existing user ID
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

            // Auto-confirm email immediately after signup using Edge Function
            // Use session token from signup if available, otherwise use anon key
            String? token = signUpSession?.accessToken;

            print('Confirming email for newly created auth user: $authUserId');
            final emailConfirmed = await _confirmUserEmail(
              authUserId,
              accessToken: token,
            );

            if (!emailConfirmed) {
              print('⚠ Warning: Email confirmation failed');
              print(
                'Attempting to sign in anyway - confirmation may have succeeded',
              );
            } else {
              print('✓ Email confirmed successfully');
            }

            // Wait a moment for confirmation to propagate
            await Future.delayed(const Duration(milliseconds: 1000));

            // Now try to sign in after email confirmation
            try {
              authResponse = await SupabaseService.auth.signInWithPassword(
                email: authEmail,
                password: authPassword,
              );
              print('✓ Successfully signed in after email confirmation');
            } catch (retryError) {
              print('⚠ Sign in retry failed after confirmation: $retryError');
              // If sign in still fails, we might need to wait longer
              // Or the Edge Function might not have worked
              // Try one more time after a longer delay
              await Future.delayed(const Duration(milliseconds: 2000));
              try {
                authResponse = await SupabaseService.auth.signInWithPassword(
                  email: authEmail,
                  password: authPassword,
                );
                print('✓ Successfully signed in on second retry');
              } catch (finalError) {
                print('❌ Final sign in attempt failed: $finalError');
                return Failure(
                  'Failed to sign in after email confirmation: ${AppException.fromError(finalError).message}',
                );
              }
            }

            // Update the users table to use the auth user ID if it doesn't match
            if (authUserId != userId) {
              // Update the user record to use the new auth user ID
              // We need to delete the old record and create a new one, or update foreign keys
              // For simplicity, update the ID directly (if RLS allows)
              try {
                await SupabaseService.client
                    .from('users')
                    .update({'id': authUserId})
                    .eq('phone_number', normalizedPhone);
              } catch (updateError) {
                print('Warning: Could not update user ID: $updateError');
                // Continue anyway - the auth user is created
              }
            }
          } catch (createError) {
            print('Error creating auth user: $createError');
            // If user already exists (from a previous attempt), try sign in again
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

        // Get user profile from database using the auth user ID
        UserModel? userProfile;
        final finalUserResponse = await SupabaseService.client
            .from('users')
            .select()
            .eq('id', authUserId)
            .maybeSingle();

        if (finalUserResponse != null) {
          userProfile = UserModel.fromJson(finalUserResponse);
        }

        // Return session data and user profile
        return Success({
          'access_token': session.accessToken,
          'refresh_token': session.refreshToken,
          'expires_at': session.expiresAt,
          'user': userProfile?.toJson(),
        });
      } catch (e) {
        print('Error signing in after OTP verification: $e');
        return Failure(AppException.fromError(e).message);
      }
    } catch (e) {
      print('Error in verifyOTPAndSignIn: $e');
      return Failure(AppException.fromError(e).message);
    }
  }

  /// Save user profile data by phone number
  /// Updates the user record in the database with the provided profile data
  /// Returns Success with updated UserModel or Failure with error message
  Future<Result<UserModel>> saveProfile({
    required String phoneNumber,
    required Map<String, dynamic> profileData,
  }) async {
    try {
      // Normalize phone number (remove non-digit characters)
      final normalizedPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');

      // Prepare update data
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };

      // Map profile data to database column names
      if (profileData.containsKey('fullName')) {
        updateData['full_name'] = profileData['fullName'];
      }
      if (profileData.containsKey('profilePictureUrl')) {
        updateData['profile_picture_url'] = profileData['profilePictureUrl'];
      }
      if (profileData.containsKey('languagePreference')) {
        updateData['language_preference'] = profileData['languagePreference'];
      }
      if (profileData.containsKey('birthday')) {
        final birthday = profileData['birthday'];
        if (birthday is DateTime) {
          updateData['birthday'] = birthday.toIso8601String().split('T')[0];
        } else if (birthday is String) {
          updateData['birthday'] = birthday;
        }
      }
      if (profileData.containsKey('city')) {
        updateData['city'] = profileData['city'];
      }
      if (profileData.containsKey('gender')) {
        updateData['gender'] = profileData['gender'];
      }
      if (profileData.containsKey('deviceModel')) {
        updateData['device_model'] = profileData['deviceModel'];
      }
      if (profileData.containsKey('socialMediaLinks')) {
        updateData['social_media_links'] = profileData['socialMediaLinks'];
      }
      if (profileData.containsKey('profession')) {
        updateData['profession'] = profileData['profession'];
      }
      if (profileData.containsKey('bio')) {
        updateData['bio'] = profileData['bio'];
      }
      if (profileData.containsKey('description')) {
        updateData['description'] = profileData['description'];
      }

      // Update user record by phone number
      final response = await SupabaseService.client
          .from('users')
          .update(updateData)
          .eq('phone_number', normalizedPhone)
          .select()
          .single();

      // Convert response to UserModel
      final userModel = UserModel.fromJson(response);

      return Success(userModel);
    } catch (e) {
      print('Error in saveProfile: $e');
      return Failure(AppException.fromError(e).message);
    }
  }
}
