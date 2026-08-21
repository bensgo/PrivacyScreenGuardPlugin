import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:privacy_screen_guard/privacy_screen_guard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool? _isEnabled;
  ScreenCaptureStatus _captureStatus = ScreenCaptureStatus.unsupported;
  StreamSubscription<ScreenCaptureStatus>? _captureSubscription;

  @override
  void initState() {
    super.initState();
    _refreshState();
    _captureSubscription = PrivacyScreenGuard.instance.captureStateChanges
        .listen(
          (status) {
            if (!mounted) return;
            setState(() => _captureStatus = status);
          },
          onError: (_) {
            if (!mounted) return;
            setState(() => _captureStatus = ScreenCaptureStatus.unsupported);
          },
        );
  }

  @override
  void dispose() {
    _captureSubscription?.cancel();
    super.dispose();
  }

  Future<void> _refreshState() async {
    bool? isEnabled;
    try {
      isEnabled = await PrivacyScreenGuard.instance.isEnabled();
    } on PlatformException {
      isEnabled = null;
    }

    if (!mounted) return;

    setState(() {
      _isEnabled = isEnabled;
    });
  }

  Future<void> _setProtection(bool enabled) async {
    try {
      if (enabled) {
        await PrivacyScreenGuard.instance.enable();
      } else {
        await PrivacyScreenGuard.instance.disable();
      }
      await _refreshState();
    } on PlatformException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message ?? error.code)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Protection enabled: ${_isEnabled ?? 'unknown'}'),
              Text('Capture status: ${_captureStatus.name}'),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => _setProtection(true),
                child: const Text('Enable protection'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => _setProtection(false),
                child: const Text('Disable protection'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
