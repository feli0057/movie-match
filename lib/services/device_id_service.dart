import 'dart:io';
import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceIdService {
  static const String _deviceIdKey = 'device_id';
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  static const AndroidId _androidIdPlugin = AndroidId();

  static Future<String> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString(_deviceIdKey);

    if (deviceId != null) {
      return deviceId;
    }

    if (Platform.isAndroid) {
      deviceId = await _androidIdPlugin.getId() ?? '';
    } else if (Platform.isIOS) {
      final iosInfo = await _deviceInfo.iosInfo;
      deviceId = iosInfo.identifierForVendor ?? '';
    }

    if (deviceId != null && deviceId.isNotEmpty) {
      await prefs.setString(_deviceIdKey, deviceId);
    }

    return deviceId ?? '';
  }
}
