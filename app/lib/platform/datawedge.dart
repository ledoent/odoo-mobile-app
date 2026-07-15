import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Zebra DataWedge integration. The Android side (MainActivity) registers a
/// BroadcastReceiver for DataWedge scan intents and forwards barcodes over
/// this EventChannel. On non-Zebra Android devices the stream simply never
/// emits; on other platforms (iOS) there is no handler at all, so we return
/// an empty stream instead of touching the channel.
class DataWedgeScanner {
  static const _channel = EventChannel('com.ledoweb.odoo_scanner/datawedge');

  static Stream<String>? _stream;

  static Stream<String> get stream =>
      _stream ??= (!kIsWeb && Platform.isAndroid)
      ? _channel.receiveBroadcastStream().map((event) => event.toString())
      : const Stream.empty();
}
