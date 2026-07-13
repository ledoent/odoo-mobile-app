import 'package:flutter/services.dart';

/// Zebra DataWedge integration. The Android side (MainActivity) registers a
/// BroadcastReceiver for DataWedge scan intents and forwards barcodes over
/// this EventChannel. On non-Zebra devices the stream simply never emits —
/// the camera scanner and keyboard-wedge entry remain available.
class DataWedgeScanner {
  static const _channel = EventChannel('com.ledoweb.odoo_scanner/datawedge');

  static Stream<String>? _stream;

  static Stream<String> get stream => _stream ??= _channel
      .receiveBroadcastStream()
      .map((event) => event.toString());
}
