/// Registers FCM device token with backend when available.
/// Web uses bell polling; native push needs Firebase setup (docs/FCM_SETUP.md).
class PushRegistrationService {
  const PushRegistrationService();

  /// No-op until Firebase is configured on mobile builds.
  Future<void> registerIfAvailable() async {
    // FCM token registration is enabled after `flutterfire configure`.
    // Backend endpoint: POST /devices/register
    // See docs/FCM_SETUP.md for production setup.
  }
}
