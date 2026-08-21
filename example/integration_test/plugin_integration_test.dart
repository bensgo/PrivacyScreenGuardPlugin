import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:privacy_screen_guard/privacy_screen_guard.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('reports whether screen protection is enabled', (
    WidgetTester tester,
  ) async {
    expect(await PrivacyScreenGuard.instance.isEnabled(), isFalse);
  }, skip: true);
}
