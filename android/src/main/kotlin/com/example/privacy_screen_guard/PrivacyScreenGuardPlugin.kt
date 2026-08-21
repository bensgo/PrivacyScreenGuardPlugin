package com.example.privacy_screen_guard

import android.view.WindowManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.EventChannel

class PrivacyScreenGuardPlugin :
    FlutterPlugin,
    MethodCallHandler,
    ActivityAware,
    EventChannel.StreamHandler {
    private lateinit var channel: MethodChannel
    private lateinit var captureEventChannel: EventChannel
    private var windowController: SecureWindowController? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "privacy_screen_guard")
        channel.setMethodCallHandler(this)
        captureEventChannel = EventChannel(
            flutterPluginBinding.binaryMessenger,
            "privacy_screen_guard/capture_state"
        )
        captureEventChannel.setStreamHandler(this)
    }

    override fun onMethodCall(
        call: MethodCall,
        result: Result
    ) {
        when (call.method) {
            "enable" -> withWindowController(result) { controller ->
                controller.enable()
                result.success(null)
            }

            "disable" -> withWindowController(result) { controller ->
                controller.disable()
                result.success(null)
            }

            "isEnabled" -> withWindowController(result) { controller ->
                result.success(controller.isEnabled())
            }

            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        captureEventChannel.setStreamHandler(null)
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        events.success("unsupported")
    }

    override fun onCancel(arguments: Any?) = Unit

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        windowController = ActivitySecureWindowController(binding.activity.window)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        windowController = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        windowController = ActivitySecureWindowController(binding.activity.window)
    }

    override fun onDetachedFromActivity() {
        windowController = null
    }

    internal fun setWindowControllerForTesting(controller: SecureWindowController?) {
        windowController = controller
    }

    private inline fun withWindowController(
        result: Result,
        action: (SecureWindowController) -> Unit
    ) {
        val controller = windowController
        if (controller == null) {
            result.error(
                "activity_unavailable",
                "PrivacyScreenGuard requires a foreground Activity.",
                null
            )
            return
        }
        action(controller)
    }
}

internal interface SecureWindowController {
    fun enable()

    fun disable()

    fun isEnabled(): Boolean
}

private class ActivitySecureWindowController(
    private val window: android.view.Window
) : SecureWindowController {
    override fun enable() {
        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
    }

    override fun disable() {
        window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
    }

    override fun isEnabled(): Boolean {
        return window.attributes.flags and WindowManager.LayoutParams.FLAG_SECURE != 0
    }
}
