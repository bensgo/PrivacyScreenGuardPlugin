enum ScreenCaptureStatus {
  captured,
  notCaptured,
  unsupported;

  bool? get isCaptured => switch (this) {
    ScreenCaptureStatus.captured => true,
    ScreenCaptureStatus.notCaptured => false,
    ScreenCaptureStatus.unsupported => null,
  };
}
