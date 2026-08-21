# privacy_screen_guard

A Flutter plugin that protects sensitive app content from screenshots, screen
recording, AirPlay capture, and background task-switcher snapshots.

## Platform behavior

| Platform | Protection | Capture status stream |
| --- | --- | --- |
| Android | Applies `FLAG_SECURE` to the current activity window | Reports `unsupported` |
| iOS | Shows a privacy overlay while captured or inactive | Reports captured/not captured |

Platform behavior is constrained by operating-system capabilities. Android
blocks screenshots and recording at the window level. iOS cannot prevent every
capture mechanism, so the plugin obscures content while capture is detected and
while the app is transitioning to the background.

## Installation

```yaml
dependencies:
  privacy_screen_guard: ^0.0.1
```

## Usage

```dart
import 'package:privacy_screen_guard/privacy_screen_guard.dart';

await PrivacyScreenGuard.instance.enable();
final enabled = await PrivacyScreenGuard.instance.isEnabled();

PrivacyScreenGuard.instance.captureStateChanges.listen((status) {
  switch (status) {
    case ScreenCaptureStatus.captured:
      break;
    case ScreenCaptureStatus.notCaptured:
      break;
    case ScreenCaptureStatus.unsupported:
      break;
  }
});

await PrivacyScreenGuard.instance.disable();
```

Call `enable` while a Flutter activity is attached. Android returns an
`activity_unavailable` platform error if no foreground activity is available.

## Development

This repository uses FVM with Flutter 3.35.7.

```bash
fvm flutter pub get
fvm dart format --output=none --set-exit-if-changed .
fvm flutter analyze
fvm flutter test
fvm flutter pub publish --dry-run
```
