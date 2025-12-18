import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

class DeviceService {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  static bool? _isSamsungDevice;

  static Future<bool> isSamsungDevice() async {
    if (_isSamsungDevice != null) {
      return _isSamsungDevice!;
    }

    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        _isSamsungDevice = androidInfo.manufacturer.toLowerCase().contains(
          'samsung',
        );
        return _isSamsungDevice!;
      } else {
        _isSamsungDevice = false;
        return false;
      }
    } catch (e) {
      _isSamsungDevice = false;
      return false;
    }
  }
}
