import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class DeviceService {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  static bool? _isSamsungDevice;

  static Future<bool> isSamsungDevice() async {
    debugPrint('DeviceService: isSamsungDevice called');
    if (_isSamsungDevice != null) {
      debugPrint('DeviceService: Using cached value: $_isSamsungDevice');
      return _isSamsungDevice!;
    }

    try {
      debugPrint('DeviceService: Checking platform...');
      if (Platform.isAndroid) {
        debugPrint('DeviceService: Platform is Android, fetching device info...');
        final androidInfo = await _deviceInfo.androidInfo;
        debugPrint('DeviceService: Manufacturer: ${androidInfo.manufacturer}');
        _isSamsungDevice = androidInfo.manufacturer.toLowerCase().contains(
          'samsung',
        );
        debugPrint('DeviceService: Is Samsung: $_isSamsungDevice');
        return _isSamsungDevice!;
      } else {
        debugPrint('DeviceService: Platform is not Android, returning false');
        _isSamsungDevice = false;
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint('DeviceService: Error checking device: $e');
      debugPrint('DeviceService: Stack trace: $stackTrace');
      _isSamsungDevice = false;
      return false;
    }
  }
}
