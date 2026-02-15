import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get/get_core/get_core.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
// import 'package:package_info_plus/package_info_plus.dart';
import 'package:samsung_community_mobile/app/repository/auth_repo/auth_repo.dart';

/// Sends event tracking payloads to the n8n webhook.
///
/// Required: [device_id], [event_type].
/// [user_id] can be null before login; must be set after authentication.
/// [event_timestamp] is not sent — the server generates it.
class EventTrackingService {
  EventTrackingService._();

  static String get _webhookUrl => dotenv.env['EVENTS_CAPTURE_URL'] ?? '';

  static const String _storageKeyDeviceId = 'event_tracking_device_id';
  static const String _storageKeyFirstOpen = 'event_tracking_first_open';
  static const String _storageKeyAppInstall = 'event_tracking_app_install';
  static const String _storageKeyInstallSource =
      'event_tracking_install_source';
  static const String _storageKeyUtmSource = 'event_tracking_utm_source';
  static const String _storageKeyUtmMedium = 'event_tracking_utm_medium';
  static const String _storageKeyUtmCampaign = 'event_tracking_utm_campaign';

  static final GetStorage _storage = GetStorage();
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  static Map<String, dynamic>? _cachedDeviceProperties;

  /// Sends a tracking event to the webhook.
  ///
  /// [eventType] must match one of the predefined event names.
  /// [userId] can be null before login/signup; must be set after auth.
  /// [userProperties] use {} when none; do not pass null.
  /// [eventProperties] use {} when none; do not pass null.
  static Future<void> trackEvent({
    required String eventType,
    String? userId,
    Map<String, dynamic>? userProperties,
    Map<String, dynamic>? eventProperties,
  }) async {
    try {
      final deviceId = await _getOrCreateDeviceId();
      final deviceProps = await _getDeviceProperties();
      final currentUser = Get.find<AuthRepo>().currentUser.value;
      if (currentUser?.id != null) {
        userId = currentUser?.id;
      }

      final body = <String, dynamic>{
        'device_id': deviceId,
        'user_id': userId,
        'event_type': eventType,
        'user_properties': userProperties ?? {},
        'device_properties': deviceProps,
        'event_properties': eventProperties ?? {},
      };

      final response = await http.post(
        Uri.parse(_webhookUrl),
        headers: {'Content-Type': 'application/json'},
        body: utf8.encode(jsonEncode(body)),
      );

      if (kDebugMode) {
        if (response.statusCode >= 200 && response.statusCode < 300) {
          debugPrint('EventTracking: webhook sent "$eventType"');
        } else {
          debugPrint(
            'EventTracking: webhook error ${response.statusCode} - ${response.body}',
          );
        }
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('EventTracking: failed to send "$eventType": $e');
        debugPrint('EventTracking: $stackTrace');
      }
    }
  }

  static Future<String> _getOrCreateDeviceId() async {
    var deviceId = _storage.read(_storageKeyDeviceId) as String?;
    if (deviceId != null && deviceId.isNotEmpty) return deviceId;

    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        deviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor;
      }
    } catch (_) {}

    if (deviceId == null || deviceId.isEmpty) {
      deviceId = '${DateTime.now().millisecondsSinceEpoch}_${_randomHex(8)}';
    }
    await _storage.write(_storageKeyDeviceId, deviceId);
    return deviceId;
  }

  static final Random _random = Random();

  static String _randomHex(int length) {
    return List.generate(
      length,
      (_) => _random.nextInt(16).toRadixString(16),
    ).join();
  }

  static Future<Map<String, dynamic>> _getDeviceProperties() async {
    if (_cachedDeviceProperties != null) return _cachedDeviceProperties!;

    await _ensureFirstOpenAndAppInstall();

    String platform = 'unknown';
    String osVersion = '';
    String appVersion = '1.0.0';
    String deviceManufacturer = '';
    String deviceModel = '';
    String deviceCategory = 'phone';

    try {
      if (Platform.isAndroid) {
        platform = 'android';
        final androidInfo = await _deviceInfo.androidInfo;
        osVersion = androidInfo.version.release;
        deviceManufacturer = androidInfo.manufacturer;
        deviceModel = androidInfo.model;
        deviceCategory = 'phone';
      } else if (Platform.isIOS) {
        platform = 'ios';
        final iosInfo = await _deviceInfo.iosInfo;
        osVersion = iosInfo.systemVersion;
        deviceManufacturer = 'Apple';
        deviceModel = iosInfo.utsname.machine;
        deviceCategory = iosInfo.model.toLowerCase().contains('ipad')
            ? 'tablet'
            : 'phone';
      }
    } catch (_) {}

    try {
      // final packageInfo = await PackageInfo.fromPl atform();
      // appVersion = packageInfo.version;
    } catch (_) {}

    final locale = Platform.localeName;
    final parts = locale.split('_');
    final language = parts.isNotEmpty ? parts[0].toLowerCase() : '';
    final country = parts.length > 1 ? parts[1].toUpperCase() : '';

    final firstOpen = _storage.read(_storageKeyFirstOpen) as String? ?? '';
    final appInstall = _storage.read(_storageKeyAppInstall) as String? ?? '';

    _cachedDeviceProperties = <String, dynamic>{
      'platform': platform,
      'os_version': osVersion,
      'app_version': appVersion,
      'device_manufacturer': deviceManufacturer,
      'device_model': deviceModel,
      'device_category': deviceCategory,
      'language': language,
      'country': country,
      'install_source':
          _storage.read(_storageKeyInstallSource) as String? ?? 'organic',
      'utm_source': _storage.read(_storageKeyUtmSource) as String? ?? '',
      'utm_medium': _storage.read(_storageKeyUtmMedium) as String? ?? '',
      'utm_campaign': _storage.read(_storageKeyUtmCampaign) as String? ?? '',
      'app_install': appInstall,
      'first_open': firstOpen,
    };
    return _cachedDeviceProperties!;
  }

  static Future<void> _ensureFirstOpenAndAppInstall() async {
    var firstOpen = _storage.read(_storageKeyFirstOpen) as String?;
    if (firstOpen == null || firstOpen.isEmpty) {
      firstOpen = DateTime.now().toUtc().toIso8601String();
      await _storage.write(_storageKeyFirstOpen, firstOpen);
    }
    var appInstall = _storage.read(_storageKeyAppInstall) as String?;
    if (appInstall == null || appInstall.isEmpty) {
      appInstall = firstOpen;
      await _storage.write(_storageKeyAppInstall, appInstall);
    }
  }

  /// Call when you have install/UTM data (e.g. from deep link). Keys in snake_case.
  static Future<void> setAcquisitionData({
    String? installSource,
    String? utmSource,
    String? utmMedium,
    String? utmCampaign,
  }) async {
    if (installSource != null) {
      await _storage.write(_storageKeyInstallSource, installSource);
    }
    if (utmSource != null) {
      await _storage.write(_storageKeyUtmSource, utmSource);
    }
    if (utmMedium != null) {
      await _storage.write(_storageKeyUtmMedium, utmMedium);
    }
    if (utmCampaign != null) {
      await _storage.write(_storageKeyUtmCampaign, utmCampaign);
    }
    _cachedDeviceProperties = null;
  }

  /// Clears cached device properties so next event refetches (e.g. after locale change).
  static void clearDevicePropertiesCache() {
    _cachedDeviceProperties = null;
  }
}
