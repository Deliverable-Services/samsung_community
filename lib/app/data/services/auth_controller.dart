import 'package:get/get.dart';

import '../core/base/base_controller.dart';
import '../core/utils/result.dart';
import '../localization/get_prefs.dart';
import '../models/user_model.dart';
import 'auth_service.dart';
import 'supabase_service.dart';

/// Controller for authentication state management
class AuthController extends BaseController {
  final AuthService _authService;

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isAuthenticated = false.obs;

  AuthController({AuthService? authService})
    : _authService = authService ?? AuthService();

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }

  /// Check authentication status
  /// Called on app startup to determine initial route
  Future<void> checkAuthStatus() async {
    // First check if we have a stored session
    final hasStoredSession = await checkSessionStatus();
    if (hasStoredSession) {
      // If we have a session but no profile, fetch it
      if (currentUser.value == null) {
        await loadCurrentUser();
      }
      return;
    }

    // Fallback to Supabase auth check
    isAuthenticated.value = _authService.isAuthenticated;
    if (isAuthenticated.value) {
      await loadCurrentUser();
    }
  }

  /// Load current user data from database
  Future<void> loadCurrentUser() async {
    setLoading(true);

    // First try to get user from stored profile
    final storedProfile = GetPrefs.getMap(GetPrefs.userProfile);
    if (storedProfile.isNotEmpty) {
      try {
        currentUser.value = UserModel.fromJson(storedProfile);
        setLoading(false);
        // Still fetch from server to ensure it's up to date
        _fetchAndUpdateUserProfile();
        return;
      } catch (e) {
        print('Error parsing stored profile: $e');
      }
    }

    // If no stored profile, fetch from database
    final result = await _authService.getCurrentUser();
    if (result.isSuccess) {
      currentUser.value = result.dataOrNull;
      // Save profile to storage
      if (result.dataOrNull != null) {
        GetPrefs.setMap(GetPrefs.userProfile, result.dataOrNull!.toJson());
      }
    } else {
      final error = result.errorOrNull ?? 'Failed to load user';
      print('Error in loadCurrentUser: $error');
      handleError(error);
    }
    setLoading(false);
  }

  /// Fetch user profile from database and update stored profile
  Future<void> _fetchAndUpdateUserProfile() async {
    try {
      final result = await _authService.getCurrentUser();
      if (result.isSuccess && result.dataOrNull != null) {
        currentUser.value = result.dataOrNull;
        GetPrefs.setMap(GetPrefs.userProfile, result.dataOrNull!.toJson());
      }
    } catch (e) {
      print('Error fetching user profile: $e');
    }
  }

  /// Sign in with phone
  Future<void> signInWithPhone({
    required String phone,
    required String password,
  }) async {
    setLoading(true);
    clearError();

    final result = await _authService.signInWithPhone(
      phone: phone,
      password: password,
    );

    if (result.isSuccess) {
      currentUser.value = result.dataOrNull;
      isAuthenticated.value = true;
    } else {
      final error = result.errorOrNull ?? 'Sign in failed';
      print('Error in signInWithPhone: $error');
      handleError(error);
    }

    setLoading(false);
  }

  /// Sign up with phone
  Future<void> signUpWithPhone({
    required String phone,
    required String password,
  }) async {
    setLoading(true);
    clearError();

    final result = await _authService.signUpWithPhone(
      phone: phone,
      password: password,
    );

    if (result.isSuccess) {
      currentUser.value = result.dataOrNull;
      isAuthenticated.value = true;
    } else {
      final error = result.errorOrNull ?? 'Sign up failed';
      print('Error in signUpWithPhone: $error');
      handleError(error);
    }

    setLoading(false);
  }

  /// Verify phone OTP
  Future<void> verifyPhoneOTP({
    required String phone,
    required String otp,
  }) async {
    setLoading(true);
    clearError();

    final result = await _authService.verifyPhoneOTP(phone: phone, otp: otp);

    if (result.isSuccess) {
      currentUser.value = result.dataOrNull;
      isAuthenticated.value = true;
    } else {
      final error = result.errorOrNull ?? 'OTP verification failed';
      print('Error in verifyPhoneOTP: $error');
      handleError(error);
    }

    setLoading(false);
  }

  /// Sign out
  Future<void> signOut() async {
    setLoading(true);

    // Clear session and profile
    await clearSession();

    // Also call service sign out
    final result = await _authService.signOut();

    if (result.isSuccess) {
      currentUser.value = null;
      isAuthenticated.value = false;
    } else {
      final error = result.errorOrNull ?? 'Sign out failed';
      print('Error in signOut: $error');
      // Still clear local state even if service call fails
      currentUser.value = null;
      isAuthenticated.value = false;
    }

    setLoading(false);
  }

  /// Check if user exists by phone number
  Future<bool> checkUserExists(String phoneNumber) async {
    setLoading(true);
    clearError();

    final result = await _authService.checkUserExists(phoneNumber);

    setLoading(false);

    if (result.isSuccess) {
      return result.dataOrNull ?? false;
    } else {
      final error = result.errorOrNull ?? 'Failed to check user';
      print('Error in checkUserExists: $error');
      handleError(error);
      return false;
    }
  }

  /// Generate OTP for sign up
  Future<String?> generateOTP(String phoneNumber) async {
    setLoading(true);
    clearError();

    final result = await _authService.generateOTP(phoneNumber);

    setLoading(false);

    if (result.isSuccess) {
      return result.dataOrNull;
    } else {
      final error = result.errorOrNull ?? 'Failed to generate OTP';
      print('Error in generateOTP: $error');
      handleError(error);
      return null;
    }
  }

  /// Generate OTP for login (existing users)
  Future<String?> generateOTPForLogin(String phoneNumber) async {
    setLoading(true);
    clearError();

    final result = await _authService.generateOTPForLogin(phoneNumber);

    setLoading(false);

    if (result.isSuccess) {
      return result.dataOrNull;
    } else {
      final error = result.errorOrNull ?? 'Failed to generate OTP for login';
      print('Error in generateOTPForLogin: $error');
      handleError(error);
      return null;
    }
  }

  /// Verify OTP for sign up
  /// Returns true if OTP is valid, false otherwise
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
      print('Error in verifyOTP: $error');
      handleError(error);
      return false;
    }
  }

  /// Verify OTP and sign in to get session tokens
  /// Returns true if successful, false otherwise
  /// Saves session tokens and user profile to storage
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
        // Save session tokens and profile
        await _saveSession(sessionData);
        // Update current user
        if (sessionData['user'] != null) {
          try {
            final userModel = UserModel.fromJson(sessionData['user']);
            currentUser.value = userModel;
            // Ensure profile is saved to storage
            GetPrefs.setMap(GetPrefs.userProfile, userModel.toJson());
          } catch (e) {
            print('Error parsing user profile: $e');
          }
        }
        isAuthenticated.value = true;
        return true;
      }
      return false;
    } else {
      final error = result.errorOrNull ?? 'OTP verification and sign in failed';
      print('Error in verifyOTPAndSignIn: $error');
      handleError(error);
      return false;
    }
  }

  /// Save session tokens and user profile to storage
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

  /// Check if user is authenticated by verifying stored session
  /// Returns true if session is valid, false otherwise
  Future<bool> checkSessionStatus() async {
    try {
      // First check if Supabase has a valid session (auto-persisted)
      final hasSupabaseSession = await _authService.restoreSession();
      if (hasSupabaseSession) {
        // Load user profile from storage
        final userProfile = GetPrefs.getMap(GetPrefs.userProfile);
        if (userProfile.isNotEmpty) {
          try {
            currentUser.value = UserModel.fromJson(userProfile);
          } catch (e) {
            print('Error parsing stored user profile: $e');
            // If stored profile is invalid, fetch from database
            await loadCurrentUser();
          }
        } else {
          // No stored profile, fetch from database
          await loadCurrentUser();
        }
        isAuthenticated.value = true;
        return true;
      }

      // No Supabase session, check stored tokens
      final accessToken = GetPrefs.getString(GetPrefs.accessToken);
      final expiresAt = GetPrefs.getInt(GetPrefs.expiresAt);

      if (accessToken.isEmpty || expiresAt == 0) {
        return false;
      }

      // Check if token is expired
      final expiresAtDateTime = DateTime.fromMillisecondsSinceEpoch(
        expiresAt * 1000,
      );
      final now = DateTime.now();

      if (now.isAfter(expiresAtDateTime)) {
        // Token expired, try to refresh
        final refreshToken = GetPrefs.getString(GetPrefs.refreshToken);
        if (refreshToken.isNotEmpty) {
          try {
            final refreshed = await _authService.refreshSession();
            if (refreshed) {
              // Update stored tokens after refresh
              final currentSession = SupabaseService.client.auth.currentSession;
              if (currentSession != null) {
                // Get user profile from storage to preserve it
                final userProfile = GetPrefs.getMap(GetPrefs.userProfile);
                await _saveSession({
                  'access_token': currentSession.accessToken,
                  'refresh_token': currentSession.refreshToken,
                  'expires_at': currentSession.expiresAt,
                  'user': userProfile.isNotEmpty ? userProfile : null,
                });
                // Reload user profile
                if (userProfile.isNotEmpty) {
                  try {
                    currentUser.value = UserModel.fromJson(userProfile);
                  } catch (e) {
                    print('Error parsing user profile after refresh: $e');
                  }
                }
              }
              isAuthenticated.value = true;
              return true;
            }
          } catch (e) {
            print('Error refreshing session: $e');
          }
        }
        // Refresh failed, clear session
        await clearSession();
        return false;
      }

      // Token is still valid but Supabase session is missing
      // Try to sign in again with stored credentials
      // Note: We can't directly restore from token, need to re-authenticate
      // For now, return false and let user login again
      return false;
    } catch (e) {
      print('Error in checkSessionStatus: $e');
      return false;
    }
  }

  /// Clear session data
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

  /// Get user details by phone number (returns status, device_model, etc.)
  /// Returns Map with user details or null if user not found
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
      print('Error in getUserDetailsByPhone: $error');
      handleError(error);
      return null;
    }
  }

  /// Save user profile data
  /// Updates the user profile in the database by matching phone number
  /// Returns true if successful, false otherwise
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
      }
      return true;
    } else {
      final error = result.errorOrNull ?? 'Failed to save profile';
      print('Error in saveProfile: $error');
      handleError(error);
      return false;
    }
  }
}
