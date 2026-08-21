import 'package:flutter_test/flutter_test.dart';
import 'package:privacy_screen_guard/privacy_screen_guard.dart';
import 'package:privacy_screen_guard/privacy_screen_guard_platform_interface.dart';
import 'package:privacy_screen_guard/privacy_screen_guard_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPrivacyScreenGuardPlatform
    with MockPlatformInterfaceMixin
    implements PrivacyScreenGuardPlatform {
  bool enabled = false;

  @override
  Future<void> enable() async {
    enabled = true;
  }

  @override
  Future<void> disable() async {
    enabled = false;
  }

  @override
  Future<bool> isEnabled() async => enabled;

  @override
  Stream<ScreenCaptureStatus> get captureStateChanges =>
      Stream<ScreenCaptureStatus>.value(ScreenCaptureStatus.captured);
}

void main() {
  final initialPlatform = PrivacyScreenGuardPlatform.instance;

  tearDown(() {
    PrivacyScreenGuardPlatform.instance = initialPlatform;
  });

  test('$MethodChannelPrivacyScreenGuard is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelPrivacyScreenGuard>());
  });

  test('enable activates screen protection', () async {
    final fakePlatform = MockPrivacyScreenGuardPlatform();
    PrivacyScreenGuardPlatform.instance = fakePlatform;

    await PrivacyScreenGuard.instance.enable();

    expect(await PrivacyScreenGuard.instance.isEnabled(), isTrue);
  });

  test('disable deactivates screen protection', () async {
    final fakePlatform = MockPrivacyScreenGuardPlatform()..enabled = true;
    PrivacyScreenGuardPlatform.instance = fakePlatform;

    await PrivacyScreenGuard.instance.disable();

    expect(await PrivacyScreenGuard.instance.isEnabled(), isFalse);
  });

  test('forwards screen capture state changes', () async {
    PrivacyScreenGuardPlatform.instance = MockPrivacyScreenGuardPlatform();

    expect(
      await PrivacyScreenGuard.instance.captureStateChanges.first,
      ScreenCaptureStatus.captured,
    );
  });
}
