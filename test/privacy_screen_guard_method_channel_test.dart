import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:privacy_screen_guard/privacy_screen_guard_method_channel.dart';
import 'package:privacy_screen_guard/privacy_screen_guard.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final platform = MethodChannelPrivacyScreenGuard();
  const MethodChannel channel = MethodChannel('privacy_screen_guard');
  final calls = <MethodCall>[];

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          calls.add(methodCall);
          return methodCall.method == 'isEnabled' ? true : null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('enable invokes the enable platform method', () async {
    await platform.enable();

    expect(calls, hasLength(1));
    expect(calls.single.method, 'enable');
  });

  test('disable invokes the disable platform method', () async {
    await platform.disable();

    expect(calls, hasLength(1));
    expect(calls.single.method, 'disable');
  });

  test('isEnabled returns the platform state', () async {
    expect(await platform.isEnabled(), isTrue);
    expect(calls.single.method, 'isEnabled');
  });

  test('decodes native screen capture states', () {
    expect(decodeScreenCaptureStatus('captured'), ScreenCaptureStatus.captured);
    expect(
      decodeScreenCaptureStatus('notCaptured'),
      ScreenCaptureStatus.notCaptured,
    );
    expect(
      decodeScreenCaptureStatus('unexpected'),
      ScreenCaptureStatus.unsupported,
    );
  });
}
