package com.ledoweb.odoo_scanner

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

/**
 * Forwards Zebra DataWedge scan intents to Flutter over an EventChannel.
 *
 * DataWedge must be configured (profile for this app) with an Intent output
 * whose action is [SCAN_ACTION] and delivery "Broadcast intent". On non-Zebra
 * devices nothing registers a sender, so the channel just stays quiet.
 */
class MainActivity : FlutterActivity() {
    companion object {
        const val SCAN_ACTION = "com.ledoweb.odoo_scanner.SCAN"
        const val CHANNEL = "com.ledoweb.odoo_scanner/datawedge"
        // DataWedge intent extra (Zebra-documented key).
        const val DATA_STRING = "com.symbol.datawedge.data_string"
    }

    private var scanReceiver: BroadcastReceiver? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    val receiver = object : BroadcastReceiver() {
                        override fun onReceive(context: Context?, intent: Intent?) {
                            val barcode = intent?.getStringExtra(DATA_STRING) ?: return
                            events?.success(barcode)
                        }
                    }
                    val filter = IntentFilter(SCAN_ACTION)
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        registerReceiver(receiver, filter, Context.RECEIVER_EXPORTED)
                    } else {
                        @Suppress("UnspecifiedRegisterReceiverFlag")
                        registerReceiver(receiver, filter)
                    }
                    scanReceiver = receiver
                }

                override fun onCancel(arguments: Any?) {
                    scanReceiver?.let { unregisterReceiver(it) }
                    scanReceiver = null
                }
            },
        )
    }

    override fun onDestroy() {
        scanReceiver?.let { unregisterReceiver(it) }
        scanReceiver = null
        super.onDestroy()
    }
}
