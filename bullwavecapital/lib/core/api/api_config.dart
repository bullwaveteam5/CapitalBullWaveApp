import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

/// Django backend base URL.
/// Android emulator: 10.0.2.2 maps to host machine localhost.
///
/// **Physical phone:** set [hostOverride] to your PC's Wi‑Fi IP (e.g. 192.168.1.5)
/// and run Django with: `python manage.py runserver 0.0.0.0:8000`
class ApiConfig {
  ApiConfig._();

  /// Uncomment and set when testing on a real phone on the same Wi‑Fi.
  static const String? hostOverride = null; // e.g. '192.168.1.5'

  static String get baseUrl {
    if (hostOverride != null && hostOverride!.isNotEmpty) {
      return 'http://$hostOverride:8000/api/v1';
    }
    if (kIsWeb) return 'http://127.0.0.1:8000/api/v1';
    if (Platform.isAndroid) return 'http://10.0.2.2:8000/api/v1';
    return 'http://127.0.0.1:8000/api/v1';
  }

  /// Rewrites Django media URLs so images load on emulator / physical device.
  static String resolveMediaUrl(String url) {
    if (url.isEmpty) return url;
    final uri = Uri.tryParse(url);
    if (uri == null) return url;

    String host;
    if (hostOverride != null && hostOverride!.isNotEmpty) {
      host = hostOverride!;
    } else if (kIsWeb) {
      host = '127.0.0.1';
    } else if (Platform.isAndroid) {
      host = '10.0.2.2';
    } else {
      host = '127.0.0.1';
    }

    return uri.replace(host: host).toString();
  }
}
