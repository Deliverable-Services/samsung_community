import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../data/core/base/base_controller.dart';
import '../../data/core/utils/result.dart';
import '../../data/localization/get_prefs.dart';
import '../../data/models/user_model.dart';
import '../../routes/app_pages.dart';
import '../../common/services/app_lifecycle_service.dart';
import '../../common/services/auth_service.dart';
import '../../common/services/supabase_service.dart';
import '../../data/core/utils/common_snackbar.dart';

class AuthRepo extends BaseController {
  final AuthService _authService;

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isAuthenticated = false.obs;

  AuthRepo({AuthService? authService})
    : _authService = authService ?? AuthService();

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    final hasStoredSession = await checkSessionStatus();
    if (hasStoredSession) {
      if (currentUser.value == null) {
        await loadCurrentUser();
      }
      return;
    }

    isAuthenticated.value = _authService.isAuthenticated;
    if (isAuthenticated.value) {
      await loadCurrentUser();
    }
  }

  Future<void> loadCurrentUser() async {
    setLoading(true);

    final storedProfile = GetPrefs.getMap(GetPrefs.userProfile);
    if (storedProfile.isNotEmpty) {
      try {
        currentUser.value = UserModel.fromJson(storedProfile);
        setLoading(false);
        _fetchAndUpdateUserProfile();
        return;
      } catch (e) {
        debugPrint('Error parsing stored profile: $e');
      }
    }

    final result = await _authService.getCurrentUser();
    if (result.isSuccess) {
      currentUser.value = result.dataOrNull;
      if (result.dataOrNull != null) {
        GetPrefs.setMap(GetPrefs.userProfile, result.dataOrNull!.toJson());
        AppLifecycleService.instance.setCurrentUserId(result.dataOrNull!.id);
      }
    } else {
      final error = result.errorOrNull ?? 'Failed to load user';
      debugPrint('Error in loadCurrentUser: $error');
      handleError(error);
    }
    setLoading(false);
  }

  Future<void> _fetchAndUpdateUserProfile() async {
    try {
      final result = await _authService.getCurrentUser();
      if (result.isSuccess && result.dataOrNull != null) {
        currentUser.value = result.dataOrNull;
        GetPrefs.setMap(GetPrefs.userProfile, result.dataOrNull!.toJson());
        AppLifecycleService.instance.setCurrentUserId(result.dataOrNull!.id);
      } else {
        debugPrint('Failed to fetch user profile: ${result.errorOrNull}');
      }
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
    }
  }

  Future<bool> checkUserExists(String phoneNumber) async {
    setLoading(true);
    clearError();

    try {
      final result = await _authService.checkUserExists(phoneNumber);

      setLoading(false);

      if (result.isSuccess) {
        return result.dataOrNull ?? false;
      } else {
        final error = result.errorOrNull ?? 'Failed to check user';
        final isNetworkError =
            error.toString().contains('SocketException') ||
            error.toString().contains('Failed host lookup') ||
            error.toString().contains('Network is unreachable');

        if (isNetworkError) {
          debugPrint('Network error in checkUserExists: $error');
          handleError('noInternetConnection'.tr);
        } else {
          debugPrint('Error in checkUserExists: $error');
          handleError(error);
        }
        return false;
      }
    } catch (e) {
      setLoading(false);
      final isNetworkError =
          e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup') ||
          e.toString().contains('Network is unreachable');

      if (isNetworkError) {
        debugPrint('Network error in checkUserExists: $e');
        handleError('noInternetConnection'.tr);
      } else {
        debugPrint('Error in checkUserExists: $e');
        handleError('Failed to check user');
      }
      return false;
    }
  }

  Future<String?> generateOTPForLogin(String phoneNumber) async {
    setLoading(true);
    clearError();

    final result = await _authService.generateOTPForLogin(phoneNumber);
    final otp = result.dataOrNull;
    if (otp != null) {
      debugPrint('OTP for login: $otp');
      CommonSnackbar.success('OTP for login: $otp');
    }
    setLoading(false);

    if (result.isSuccess) {
      return result.dataOrNull;
    } else {
      final error = result.errorOrNull ?? 'Failed to generate OTP for login';
      debugPrint('Error in generateOTPForLogin: $error');

      if (error.toString().contains('USER_SUSPENDED')) {
        handleError('userSuspended'.tr);
        return null;
      }
      if (error.toString().contains('WAIT_FOR_APPROVAL')) {
        handleError('wait_for_approval'.tr);
        return null;
      }
      if (error.toString().contains('USER_REJECTED')) {
        handleError('userRejected'.tr);
        return null;
      }

      handleError(error);
      return null;
    }
  }

  Future<Map<String, dynamic>?> checkUserForSignup(String phoneNumber) async {
    setLoading(true);
    clearError();

    final result = await _authService.checkUserForSignup(phoneNumber);

    setLoading(false);

    if (result.isSuccess) {
      return result.dataOrNull;
    } else {
      final error = result.errorOrNull ?? 'Failed to check user';
      debugPrint('Error in checkUserForSignup: $error');
      handleError(error);
      return null;
    }
  }

  Future<String?> createOrGetAuthUser(String phoneNumber) async {
    setLoading(true);
    clearError();

    final result = await _authService.createOrGetAuthUser(phoneNumber);

    setLoading(false);

    if (result.isSuccess) {
      return result.dataOrNull;
    } else {
      final error = result.errorOrNull ?? 'Failed to create/get auth user';
      debugPrint('Error in createOrGetAuthUser: $error');
      handleError(error);
      return null;
    }
  }

  Future<bool> createOrUpdatePublicUser({
    required String phoneNumber,
    required String authUserId,
    Map<String, dynamic>? existingUserDetails,
  }) async {
    setLoading(true);
    clearError();

    final result = await _authService.createOrUpdatePublicUser(
      phoneNumber: phoneNumber,
      authUserId: authUserId,
      existingUserDetails: existingUserDetails,
    );

    setLoading(false);

    if (result.isSuccess) {
      return true;
    } else {
      final error = result.errorOrNull ?? 'Failed to create/update public user';
      debugPrint('Error in createOrUpdatePublicUser: $error');
      handleError(error);
      return false;
    }
  }

  Future<String?> generateOTP(String phoneNumber) async {
    setLoading(true);
    clearError();

    final result = await _authService.generateOTP(phoneNumber);
    final otp = result.dataOrNull;
    if (otp != null) {
      CommonSnackbar.success('OTP for signup: $otp');
    }
    setLoading(false);

    if (result.isSuccess) {
      return result.dataOrNull;
    } else {
      final error = result.errorOrNull ?? 'Failed to generate OTP';
      debugPrint('Error in generateOTP: $error');
      handleError(error);
      return null;
    }
  }

  Future<bool> verifyOTP({
    required String phoneNumber,
    required String otpCode,
  }) async {
    setLoading(true);
    clearError();

    final result = await _authService.verifyOTP(
      phoneNumber: phoneNumber,
      otpCode: otpCode,
    );

    setLoading(false);

    if (result.isSuccess) {
      return true;
    } else {
      final error = result.errorOrNull ?? 'OTP verification failed';
      debugPrint('Error in verifyOTP: $error');
      handleError(error);
      return false;
    }
  }

  Future<bool> verifyOTPAndSignIn({
    required String phoneNumber,
    required String otpCode,
  }) async {
    setLoading(true);
    clearError();

    final result = await _authService.verifyOTPAndSignIn(
      phoneNumber: phoneNumber,
      otpCode: otpCode,
    );

    setLoading(false);

    if (result.isSuccess) {
      final sessionData = result.dataOrNull;
      if (sessionData != null) {
        await _saveSession(sessionData);
        if (sessionData['user'] != null) {
          try {
            final userModel = UserModel.fromJson(sessionData['user']);
            currentUser.value = userModel;
            GetPrefs.setMap(GetPrefs.userProfile, userModel.toJson());
            AppLifecycleService.instance.setCurrentUserId(userModel.id);
          } catch (e) {
            debugPrint('Error parsing user profile: $e');
          }
        }
        isAuthenticated.value = true;
        return true;
      }
      return false;
    } else {
      final error = result.errorOrNull ?? 'OTP verification and sign in failed';
      debugPrint('Error in verifyOTPAndSignIn: $error');
      handleError(error);
      return false;
    }
  }

  Future<void> _saveSession(Map<String, dynamic> sessionData) async {
    final accessToken = sessionData['access_token'] as String?;
    final refreshToken = sessionData['refresh_token'] as String?;
    final expiresAt = sessionData['expires_at'] as int?;
    final user = sessionData['user'] as Map<String, dynamic>?;

    if (accessToken != null) {
      GetPrefs.setString(GetPrefs.accessToken, accessToken);
    }
    if (refreshToken != null) {
      GetPrefs.setString(GetPrefs.refreshToken, refreshToken);
    }
    if (expiresAt != null) {
      GetPrefs.setInt(GetPrefs.expiresAt, expiresAt);
    }
    if (user != null) {
      GetPrefs.setMap(GetPrefs.userProfile, user);
    }
    GetPrefs.setBool(GetPrefs.isLoggedIn, true);
  }

  Future<bool> checkSessionStatus() async {
    try {
      final hasSupabaseSession = await _authService.restoreSession();
      if (hasSupabaseSession) {
        final userProfile = GetPrefs.getMap(GetPrefs.userProfile);
        if (userProfile.isNotEmpty) {
          try {
            currentUser.value = UserModel.fromJson(userProfile);
          } catch (e) {
            debugPrint('Error parsing stored user profile: $e');
            await loadCurrentUser();
          }
        } else {
          await loadCurrentUser();
        }
        isAuthenticated.value = true;
        return true;
      }

      final accessToken = GetPrefs.getString(GetPrefs.accessToken);
      final expiresAt = GetPrefs.getInt(GetPrefs.expiresAt);

      if (accessToken.isEmpty || expiresAt == 0) {
        return false;
      }

      final expiresAtDateTime = DateTime.fromMillisecondsSinceEpoch(
        expiresAt * 1000,
      );
      final now = DateTime.now();

      if (now.isAfter(expiresAtDateTime)) {
        final refreshToken = GetPrefs.getString(GetPrefs.refreshToken);
        if (refreshToken.isNotEmpty) {
          try {
            final refreshed = await _authService.refreshSession();
            if (refreshed) {
              final currentSession = SupabaseService.client.auth.currentSession;
              if (currentSession != null) {
                final userProfile = GetPrefs.getMap(GetPrefs.userProfile);
                await _saveSession({
                  'access_token': currentSession.accessToken,
                  'refresh_token': currentSession.refreshToken,
                  'expires_at': currentSession.expiresAt,
                  'user': userProfile.isNotEmpty ? userProfile : null,
                });
                if (userProfile.isNotEmpty) {
                  try {
                    currentUser.value = UserModel.fromJson(userProfile);
                  } catch (e) {
                    debugPrint('Error parsing user profile after refresh: $e');
                  }
                }
              }
              isAuthenticated.value = true;
              return true;
            }
          } catch (e) {
            final errorStr = e.toString();
            final isNetworkError =
                errorStr.contains('SocketException') ||
                errorStr.contains('Failed host lookup') ||
                errorStr.contains('Network is unreachable');

            if (!isNetworkError) {
              debugPrint('Error refreshing session: $e');
            }
          }
        }
        await clearSession();
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('Error in checkSessionStatus: $e');
      return false;
    }
  }

  Future<void> clearSession() async {
    GetPrefs.remove(GetPrefs.accessToken);
    GetPrefs.remove(GetPrefs.refreshToken);
    GetPrefs.remove(GetPrefs.expiresAt);
    GetPrefs.remove(GetPrefs.userProfile);
    GetPrefs.setBool(GetPrefs.isLoggedIn, false);
    currentUser.value = null;
    isAuthenticated.value = false;
    await _authService.signOut();
  }

  Future<Map<String, dynamic>?> getUserDetailsByPhone(
    String phoneNumber,
  ) async {
    setLoading(true);
    clearError();

    final result = await _authService.getUserDetailsByPhone(phoneNumber);

    setLoading(false);

    if (result.isSuccess) {
      return result.dataOrNull;
    } else {
      final error = result.errorOrNull ?? 'Failed to get user details';
      debugPrint('Error in getUserDetailsByPhone: $error');
      handleError(error);
      return null;
    }
  }

  /// Save user profile data
  Future<bool> saveProfile({
    required String phoneNumber,
    required Map<String, dynamic> profileData,
  }) async {
    setLoading(true);
    clearError();

    final result = await _authService.saveProfile(
      phoneNumber: phoneNumber,
      profileData: profileData,
    );

    setLoading(false);

    if (result.isSuccess) {
      // Update current user if it matches
      if (currentUser.value?.phoneNumber == phoneNumber ||
          currentUser.value?.phoneNumber.replaceAll(RegExp(r'\D'), '') ==
              phoneNumber.replaceAll(RegExp(r'\D'), '')) {
        currentUser.value = result.dataOrNull;
        if (result.dataOrNull != null) {
          GetPrefs.setMap(GetPrefs.userProfile, result.dataOrNull!.toJson());
        }
      }
      return true;
    } else {
      final error = result.errorOrNull ?? 'Failed to save profile';
      debugPrint('Error in saveProfile: $error');
      handleError(error);
      return false;
    }
  }

  Future<void> signOut() async {
    setLoading(true);

    await clearSession();

    final result = await _authService.signOut();

    AppLifecycleService.instance.clearCurrentUserId();

    if (result.isSuccess) {
      currentUser.value = null;
      isAuthenticated.value = false;
    } else {
      final error = result.errorOrNull ?? 'Sign out failed';
      debugPrint('Error in signOut: $error');
      currentUser.value = null;
      isAuthenticated.value = false;
    }

    setLoading(false);

    Get.offAllNamed(Routes.LOGIN);
  }
}
