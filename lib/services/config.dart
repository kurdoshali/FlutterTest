import 'package:flutter/services.dart';

class AppConfig {
  static const MethodChannel _channel = MethodChannel('app.config');

  static Future<String> get mapsApiKey async {
    final key = await _channel.invokeMethod<String>('getMapsApiKey');
    return key ?? '';
  }
}
