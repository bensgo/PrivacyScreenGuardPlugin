import 'privacy_screen_guard_platform_interface.dart';
import 'src/screen_capture_status.dart';

export 'src/screen_capture_status.dart';

class PrivacyScreenGuard {
  PrivacyScreenGuard._();

  static final PrivacyScreenGuard instance = PrivacyScreenGuard._();

  Future<void> enable() => PrivacyScreenGuardPlatform.instance.enable();

  Future<void> disable() => PrivacyScreenGuardPlatform.instance.disable();

  Future<bool> isEnabled() => PrivacyScreenGuardPlatform.instance.isEnabled();

  Stream<ScreenCaptureStatus> get captureStateChanges =>
      PrivacyScreenGuardPlatform.instance.captureStateChanges;
}
