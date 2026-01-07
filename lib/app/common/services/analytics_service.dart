import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Service for logging Firebase Analytics events
///
/// Based on Firebase Analytics documentation:
/// https://firebase.google.com/docs/analytics/screenviews
class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Get the FirebaseAnalytics instance
  static FirebaseAnalytics get analytics => _analytics;

  /// Log a screen view event
  ///
  /// Automatically tracks screen transitions and attaches information
  /// about the current screen to events.
  ///
  /// Example:
  /// ```dart
  /// AnalyticsService.logScreenView(
  ///   screenName: 'Main Screen',
  ///   screenClass: 'MainScreen',
  /// );
  /// ```
  static Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
      );
      if (kDebugMode) {
        debugPrint('Analytics: Screen view logged - $screenName');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error logging screen view: $e');
      }
    }
  }

  /// Helper function to log screen view when widget builds
  ///
  /// Call this in your widget's build method to automatically track screen views.
  /// This wraps the addPostFrameCallback pattern for convenience.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// Widget build(BuildContext context) {
  ///   AnalyticsService.trackScreenView(
  ///     screenName: 'Login Screen',
  ///     screenClass: 'LoginView',
  ///   );
  ///   return Scaffold(...);
  /// }
  /// ```
  static void trackScreenView({
    required String screenName,
    String? screenClass,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      logScreenView(screenName: screenName, screenClass: screenClass);
    });
  }

  /// Log a button click event on a screen
  ///
  /// Logs when user clicks buttons on screens with screen_name and button_name parameters.
  ///
  /// Example:
  /// ```dart
  /// AnalyticsService.logButtonClick(
  ///   screenName: 'Main Screen',
  ///   buttonName: 'Login signup',
  /// );
  /// ```
  static Future<void> logButtonClick({
    required String screenName,
    required String buttonName,
    String? eventName,
    Map<String, dynamic>? additionalParams,
  }) async {
    try {
      // Default event name if not provided
      final event =
          eventName ?? '${screenName.toLowerCase().replaceAll(' ', '_')}_click';

      final parameters = <String, Object>{
        'screen_name': screenName,
        'button_name': buttonName,
        if (additionalParams != null)
          ...additionalParams.map(
            (key, value) => MapEntry(key, value as Object),
          ),
      };

      await _analytics.logEvent(name: event, parameters: parameters);

      if (kDebugMode) {
        debugPrint(
          'Analytics: Button click logged - $event on $screenName: $buttonName',
        );
        debugPrint('Analytics: Parameters - $parameters');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Error logging button click: $e');
        debugPrint('Stack trace: $stackTrace');
      }
    }
  }

  /// Log a custom event with parameters
  ///
  /// Generic function to log any custom event with parameters.
  ///
  /// Example:
  /// ```dart
  /// AnalyticsService.logEvent(
  ///   eventName: 'main_screen_click',
  ///   parameters: {
  ///     'screen_name': 'Main screen',
  ///     'button_name': 'Login signup',
  ///   },
  /// );
  /// ```
  static Future<void> logEvent({
    required String eventName,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      final convertedParams = parameters?.map(
        (key, value) => MapEntry(key, value as Object),
      );
      await _analytics.logEvent(name: eventName, parameters: convertedParams);
      if (kDebugMode) {
        debugPrint('Analytics: Event logged - $eventName');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error logging event: $e');
      }
    }
  }

  /// Set user property
  ///
  /// Sets a user property to the current user.
  ///
  /// Example:
  /// ```dart
  /// AnalyticsService.setUserProperty(
  ///   name: 'user_type',
  ///   value: 'premium',
  /// );
  /// ```
  static Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
      if (kDebugMode) {
        debugPrint('Analytics: User property set - $name: $value');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error setting user property: $e');
      }
    }
  }

  /// Set user ID
  ///
  /// Sets the user ID for analytics.
  ///
  /// Example:
  /// ```dart
  /// AnalyticsService.setUserId(userId: 'user123');
  /// ```
  static Future<void> setUserId({required String? userId}) async {
    try {
      await _analytics.setUserId(id: userId);
      if (kDebugMode) {
        debugPrint('Analytics: User ID set - $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error setting user ID: $e');
      }
    }
  }
}
