import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'privacy_screen_guard_method_channel.dart';
import 'src/screen_capture_status.dart';

abstract class PrivacyScreenGuardPlatform extends PlatformInterface {
  PrivacyScreenGuardPlatform() : super(token: _token);

  static final Object _token = Object();

  static PrivacyScreenGuardPlatform _instance =
      MethodChannelPrivacyScreenGuard();

  static PrivacyScreenGuardPlatform get instance => _instance;

  static set instance(PrivacyScreenGuardPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> enable() {
    throw UnimplementedError('enable() has not been implemented.');
  }

  Future<void> disable() {
    throw UnimplementedError('disable() has not been implemented.');
  }

  Future<bool> isEnabled() {
    throw UnimplementedError('isEnabled() has not been implemented.');
  }

  Stream<ScreenCaptureStatus> get captureStateChanges {
    throw UnimplementedError('captureStateChanges has not been implemented.');
  }
}
