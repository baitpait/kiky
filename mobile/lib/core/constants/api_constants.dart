import 'package:flutter/foundation.dart';
import 'api_host_stub.dart'
    if (dart.library.html) 'api_host_web.dart' as api_host;

class ApiConstants {
  static String get baseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    if (kIsWeb) return 'http://${api_host.apiHost}:3000/api';
    return 'http://10.0.2.2:3000/api';
  }

  static String get wsBaseUrl {
    const fromEnv = String.fromEnvironment('WS_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    if (kIsWeb) return 'ws://${api_host.apiHost}:3000';
    return 'ws://10.0.2.2:3000';
  }

  static const Duration connectTimeout = Duration(seconds: 15);
}
