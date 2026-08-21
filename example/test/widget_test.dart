import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:privacy_screen_guard_example/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const methodChannel = MethodChannel('privacy_screen_guard');
  const eventChannel = MethodChannel('privacy_screen_guard/capture_state');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, (call) async {
          return call.method == 'isEnabled' ? false : null;
        });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(eventChannel, (call) async => null);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(eventChannel, null);
  });

  testWidgets('renders privacy controls', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.text('Protection enabled: false'), findsOneWidget);
    expect(
      find.widgetWithText(FilledButton, 'Enable protection'),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(OutlinedButton, 'Disable protection'),
      findsOneWidget,
    );
  });
}
