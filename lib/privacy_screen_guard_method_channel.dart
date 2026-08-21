import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'privacy_screen_guard_platform_interface.dart';
import 'src/screen_capture_status.dart';

class MethodChannelPrivacyScreenGuard extends PrivacyScreenGuardPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('privacy_screen_guard');

  @visibleForTesting
  final eventChannel = const EventChannel('privacy_screen_guard/capture_state');

  @override
  late final Stream<ScreenCaptureStatus> captureStateChanges = eventChannel
      .receiveBroadcastStream()
      .map(decodeScreenCaptureStatus);

  @override
  Future<void> enable() => methodChannel.invokeMethod<void>('enable');

  @override
  Future<void> disable() => methodChannel.invokeMethod<void>('disable');

  @override
  Future<bool> isEnabled() async {
    return await methodChannel.invokeMethod<bool>('isEnabled') ?? false;
  }
}

@visibleForTesting
ScreenCaptureStatus decodeScreenCaptureStatus(Object? value) {
  return switch (value) {
    'captured' => ScreenCaptureStatus.captured,
    'notCaptured' => ScreenCaptureStatus.notCaptured,
    _ => ScreenCaptureStatus.unsupported,
  };
}
