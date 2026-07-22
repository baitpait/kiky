import '../../core/api/api_client.dart';

/// Registers FCM device token with backend when available.
/// Web uses bell polling; native push needs Firebase setup (docs/FCM_SETUP.md).
class PushRegistrationService {
  PushRegistrationService(this._api);

  final ApiClient _api;

  /// No-op until Firebase is configured on mobile builds.
  Future<void> registerIfAvailable() async {
    // FCM token registration is enabled after `flutterfire configure`.
    // Backend endpoint: POST /notifications/devices/register
    // See docs/FCM_SETUP.md for production setup.
  }
}
