import 'dart:io';
import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceIdService {
  static const String deviceIDkey = 'device_id';
  static final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  static const AndroidId androidIDplugin = AndroidId();

  static Future<String> getDeviceID() async {
    final preferences = await SharedPreferences.getInstance();
    String? deviceID = preferences.getString(deviceIDkey);

    if (deviceID != null) {
      return deviceID;
    }

    if (Platform.isAndroid) {
      deviceID = await androidIDplugin.getId() ?? '';
    } else if (Platform.isIOS) {
      final iOSinfo = await deviceInfo.iosInfo;
      deviceID = iOSinfo.identifierForVendor ?? '';
    }

    if (deviceID != null && deviceID.isNotEmpty) {
      await preferences.setString(deviceIDkey, deviceID);
    }

    return deviceID ?? '';
  }
}
