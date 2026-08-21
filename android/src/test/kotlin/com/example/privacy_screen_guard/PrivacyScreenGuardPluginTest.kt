package com.example.privacy_screen_guard

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNull
import kotlin.test.assertTrue

internal class PrivacyScreenGuardPluginTest {
    @Test
    fun enable_addsSecureWindowFlag() {
        val plugin = PrivacyScreenGuardPlugin()
        val controller = FakeSecureWindowController()
        plugin.setWindowControllerForTesting(controller)

        val result = RecordingResult()
        plugin.onMethodCall(MethodCall("enable", null), result)

        assertTrue(controller.enabled)
        assertTrue(result.completedSuccessfully)
        assertNull(result.successValue)
    }

    @Test
    fun disable_clearsSecureWindowFlag() {
        val plugin = PrivacyScreenGuardPlugin()
        val controller = FakeSecureWindowController(enabled = true)
        plugin.setWindowControllerForTesting(controller)

        val result = RecordingResult()
        plugin.onMethodCall(MethodCall("disable", null), result)

        assertFalse(controller.enabled)
        assertTrue(result.completedSuccessfully)
    }

    @Test
    fun isEnabled_returnsWhetherSecureWindowFlagIsSet() {
        val plugin = PrivacyScreenGuardPlugin()
        plugin.setWindowControllerForTesting(FakeSecureWindowController(enabled = true))

        val result = RecordingResult()
        plugin.onMethodCall(MethodCall("isEnabled", null), result)

        assertEquals(true, result.successValue)
    }

    @Test
    fun methodCall_withoutActivity_returnsStructuredError() {
        val plugin = PrivacyScreenGuardPlugin()
        val result = RecordingResult()

        plugin.onMethodCall(MethodCall("enable", null), result)

        assertEquals("activity_unavailable", result.errorCode)
        assertEquals(
            "PrivacyScreenGuard requires a foreground Activity.",
            result.errorMessage
        )
        assertNull(result.errorDetails)
    }

    @Test
    fun captureState_reportsUnsupported() {
        val plugin = PrivacyScreenGuardPlugin()
        val events = RecordingEventSink()

        plugin.onListen(null, events)

        assertEquals(listOf<Any?>("unsupported"), events.values)
    }
}

private class FakeSecureWindowController(
    var enabled: Boolean = false
) : SecureWindowController {
    override fun enable() {
        enabled = true
    }

    override fun disable() {
        enabled = false
    }

    override fun isEnabled(): Boolean = enabled
}

private class RecordingResult : MethodChannel.Result {
    var completedSuccessfully = false
    var successValue: Any? = null
    var errorCode: String? = null
    var errorMessage: String? = null
    var errorDetails: Any? = null
    var notImplemented = false

    override fun success(result: Any?) {
        completedSuccessfully = true
        successValue = result
    }

    override fun error(
        errorCode: String,
        errorMessage: String?,
        errorDetails: Any?
    ) {
        this.errorCode = errorCode
        this.errorMessage = errorMessage
        this.errorDetails = errorDetails
    }

    override fun notImplemented() {
        notImplemented = true
    }
}

private class RecordingEventSink : EventChannel.EventSink {
    val values = mutableListOf<Any?>()

    override fun success(event: Any?) {
        values.add(event)
    }

    override fun error(
        errorCode: String,
        errorMessage: String?,
        errorDetails: Any?
    ) = Unit

    override fun endOfStream() = Unit
}
