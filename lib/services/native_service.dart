import 'package:flutter/services.dart';

class NativeService {
  static const _channel = MethodChannel('native/device');

  static Future<Map<String, dynamic>> getDeviceData() async {
    final result = await _channel.invokeMethod('getDeviceData');
    if (result == null) {
      return {};
    }
    return Map<String, dynamic>.from(result);
  }
}
