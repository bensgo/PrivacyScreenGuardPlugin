import Flutter
import XCTest

@testable import privacy_screen_guard

// This demonstrates a simple unit test of the Swift portion of this plugin's implementation.
//
// See https://developer.apple.com/documentation/xctest for more information about using XCTest.

class RunnerTests: XCTestCase {
  private var plugin: PrivacyScreenGuardPlugin!

  override func setUp() {
    super.setUp()
    plugin = PrivacyScreenGuardPlugin()
  }

  override func tearDown() {
    _ = invoke("disable")
    plugin = nil
    super.tearDown()
  }

  func testEnableAndDisableProtection() {
    _ = invoke("enable")
    XCTAssertEqual(invoke("isEnabled") as? Bool, true)

    _ = invoke("disable")
    XCTAssertEqual(invoke("isEnabled") as? Bool, false)
  }

  func testCaptureStreamEmitsInitialState() {
    var emittedState: String?

    XCTAssertNil(
      plugin.onListen(withArguments: nil) { event in
        emittedState = event as? String
      }
    )

    XCTAssertTrue(emittedState == "captured" || emittedState == "notCaptured")
    XCTAssertNil(plugin.onCancel(withArguments: nil))
  }

  private func invoke(_ method: String) -> Any? {
    var returnedValue: Any?
    let resultExpectation = expectation(description: "\(method) returns a result")
    plugin.handle(FlutterMethodCall(methodName: method, arguments: nil)) { result in
      returnedValue = result
      resultExpectation.fulfill()
    }
    waitForExpectations(timeout: 1)
    return returnedValue
  }
}
