import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

/// Django backend base URL.
/// Android emulator: 10.0.2.2 maps to host machine localhost.
///
/// **Docker / web build:** pass `--dart-define=API_BASE_URL=http://127.0.0.1:8000/api/v1`
///
/// **Physical phone:** set [hostOverride] to your PC's Wi‑Fi IP (e.g. 192.168.1.5)
/// and run Django with: `python manage.py runserver 0.0.0.0:8000`
class ApiConfig {
  ApiConfig._();

  static const String _apiBaseFromEnv =
      String.fromEnvironment('API_BASE_URL', defaultValue: '');

  /// Uncomment and set when testing on a real phone on the same Wi‑Fi.
  static const String? hostOverride = null; // e.g. '192.168.1.5'

  static String get baseUrl {
    final fromEnv = _apiBaseFromEnv.trim();
    if (fromEnv.isNotEmpty) {
      return fromEnv.endsWith('/')
          ? fromEnv.substring(0, fromEnv.length - 1)
          : fromEnv;
    }
    if (hostOverride != null && hostOverride!.isNotEmpty) {
      return 'http://$hostOverride:8000/api/v1';
    }
    if (kIsWeb) return 'http://127.0.0.1:8000/api/v1';
    if (Platform.isAndroid) return 'http://10.0.2.2:8000/api/v1';
    return 'http://127.0.0.1:8000/api/v1';
  }

  static String get _apiHost {
    final fromEnv = _apiBaseFromEnv.trim();
    if (fromEnv.isNotEmpty) {
      return Uri.parse(fromEnv).host;
    }
    if (hostOverride != null && hostOverride!.isNotEmpty) {
      return hostOverride!;
    }
    if (kIsWeb) return '127.0.0.1';
    if (Platform.isAndroid) return '10.0.2.2';
    return '127.0.0.1';
  }

  /// Rewrites Django media URLs so images load on emulator / physical device.
  static String resolveMediaUrl(String url) {
    if (url.isEmpty) return url;
    final uri = Uri.tryParse(url);
    if (uri == null) return url;

    return uri.replace(host: _apiHost).toString();
  }
}
