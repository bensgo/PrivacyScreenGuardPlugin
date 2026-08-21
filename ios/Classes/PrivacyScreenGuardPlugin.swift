import Flutter
import UIKit

public class PrivacyScreenGuardPlugin: NSObject {
  private var isProtectionEnabled = false

  private var captureEventSink: FlutterEventSink?

  private var isCaptureObserverRegistered = false

    private var applicationWindows: [UIWindow] {
      UIApplication.shared.connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .flatMap(\.windows)
    }
    
  public override init() {
    super.init()
  }
  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = PrivacyScreenGuardPlugin()
      
    let methodChannel = FlutterMethodChannel(
      name: "privacy_screen_guard", binaryMessenger: registrar.messenger())
      registrar.addMethodCallDelegate(instance, channel: methodChannel)

    let captureEventChannel = FlutterEventChannel(
        name: "privacy_screen_guard/capture_state",
        binaryMessenger: registrar.messenger())
    captureEventChannel.setStreamHandler(instance)
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }
}


extension PrivacyScreenGuardPlugin : FlutterPlugin {
      public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "enable":
          enableProtection()
        
          result(nil)
        case "disable":
          disableProtection()
          result(nil)
        case "isEnabled":
          result(isProtectionEnabled)
        default:
          result(FlutterMethodNotImplemented)
        }
      }
}

extension PrivacyScreenGuardPlugin : FlutterStreamHandler {
    
    public func onListen(
      withArguments arguments: Any?,
      eventSink events: @escaping FlutterEventSink
    ) -> FlutterError? {
        print("FlutterStreamHandler onListen")
      captureEventSink = events

      updateCaptureObservation()

      emitCaptureState()
      return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
      captureEventSink = nil
      updateCaptureObservation()
      return nil
    }
}

extension PrivacyScreenGuardPlugin {
    
    private func enableProtection() {
      guard !isProtectionEnabled else { return }
      isProtectionEnabled = true

      let notifications = NotificationCenter.default
      notifications.addObserver(
        self,
        selector: #selector(applicationWillResignActive),
        name: UIApplication.willResignActiveNotification,
        object: nil
      )
      notifications.addObserver(
        self,
        selector: #selector(applicationDidBecomeActive),
        name: UIApplication.didBecomeActiveNotification,
        object: nil
      )
      updateCaptureObservation()
      updateOverlayVisibility()
    }
    
    private func disableProtection() {
        guard isProtectionEnabled else { return }
        isProtectionEnabled = false
        let notifications = NotificationCenter.default
        notifications.removeObserver(
          self,
          name: UIApplication.willResignActiveNotification,
          object: nil
        )
        notifications.removeObserver(
          self,
          name: UIApplication.didBecomeActiveNotification,
          object: nil
        )
        updateCaptureObservation()
        removePrivacyOverlays()
      }

      @objc private func applicationWillResignActive() {
        guard isProtectionEnabled else { return }
        showPrivacyOverlays()
      }

      @objc private func applicationDidBecomeActive() {
        updateOverlayVisibility()
      }

      @objc private func screenCaptureDidChange() {
        updateOverlayVisibility()

        emitCaptureState()
      }

      private func updateCaptureObservation() {
        let shouldObserve = isProtectionEnabled || captureEventSink != nil
        guard shouldObserve != isCaptureObserverRegistered else { return }

        isCaptureObserverRegistered = shouldObserve
        if shouldObserve {
          NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenCaptureDidChange),
            name: UIScreen.capturedDidChangeNotification,
            object: nil
          )
        } else {
          NotificationCenter.default.removeObserver(
            self,
            name: UIScreen.capturedDidChangeNotification,
            object: nil
          )
        }
      }

      private func emitCaptureState() {
        captureEventSink?(UIScreen.main.isCaptured ? "captured" : "notCaptured")
      }

      private func updateOverlayVisibility() {
        let shouldHideContent =
          isProtectionEnabled
          && (UIApplication.shared.applicationState != .active || UIScreen.main.isCaptured)

        if shouldHideContent {
          showPrivacyOverlays()
        } else {
          removePrivacyOverlays()
        }
      }

      private func showPrivacyOverlays() {
        for window in applicationWindows {
          guard !window.subviews.contains(where: { $0 is PrivacyOverlayView }) else {
            continue
          }

          let overlay = PrivacyOverlayView(frame: window.bounds)
          window.addSubview(overlay)
        }
      }

      private func removePrivacyOverlays() {
        for window in applicationWindows {
          for overlay in window.subviews where overlay is PrivacyOverlayView {
            overlay.removeFromSuperview()
          }
        }
      }
}

private final class PrivacyOverlayView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let blurEffect = UIBlurEffect(style: .extraLight)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = self.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(blurView)
        self.isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
