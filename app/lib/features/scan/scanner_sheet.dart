import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Camera scanner in a modal sheet (MLKit via mobile_scanner). Stays open so
/// the operator can scan repeatedly; barcodes are debounced per value.
Future<void> showScannerSheet(
  BuildContext context, {
  required ValueChanged<String> onBarcode,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.6,
      child: _ScannerView(onBarcode: onBarcode),
    ),
  );
}

class _ScannerView extends StatefulWidget {
  const _ScannerView({required this.onBarcode});

  final ValueChanged<String> onBarcode;

  @override
  State<_ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<_ScannerView> {
  final _controller = MobileScannerController();
  String? _lastValue;
  DateTime _lastAt = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    final value = capture.barcodes.firstOrNull?.rawValue;
    if (value == null || value.isEmpty) return;
    final now = DateTime.now();
    // Same code within 2s = the camera still pointing at one label, not a
    // second intentional scan.
    if (value == _lastValue &&
        now.difference(_lastAt) < const Duration(seconds: 2)) {
      return;
    }
    _lastValue = value;
    _lastAt = now;
    widget.onBarcode(value);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              const SizedBox(width: 48),
              const Expanded(
                child: Text('Scan barcode', textAlign: TextAlign.center),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
        Expanded(
          child: MobileScanner(controller: _controller, onDetect: _onDetect),
        ),
      ],
    );
  }
}
