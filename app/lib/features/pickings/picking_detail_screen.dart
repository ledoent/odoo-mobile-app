import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/providers.dart';
import '../../data/local/database.dart';
import '../../platform/datawedge.dart';
import '../scan/scan_service.dart';
import '../scan/scanner_sheet.dart';

final _moveLinesProvider = StreamProvider.family<List<MoveLine>, int>(
  (ref, pickingId) => ref.watch(databaseProvider).watchMoveLines(pickingId),
);

/// One picking: its move lines, live scan input (DataWedge + camera +
/// keyboard wedge), and validation. All mutations go through the op queue.
@RoutePage()
class PickingDetailScreen extends HookConsumerWidget {
  const PickingDetailScreen({super.key, required this.pickingId});

  final int pickingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lines = ref.watch(_moveLinesProvider(pickingId));
    final manualController = useTextEditingController();

    Future<void> handleBarcode(String barcode) async {
      if (barcode.trim().isEmpty) return;
      final outcome = await ref
          .read(scanServiceProvider)
          .scanBarcode(pickingId: pickingId, barcode: barcode);
      // Fire the queued op immediately when we're online.
      unawaited(ref.read(syncEngineProvider)?.sync());
      if (!context.mounted) return;
      final messenger = ScaffoldMessenger.of(context)..clearSnackBars();
      switch (outcome) {
        case ScanApplied(:final productName, :final newQuantity):
          HapticFeedback.mediumImpact();
          messenger.showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 1),
              content: Text('$productName → ${newQuantity.toStringAsFixed(0)}'),
            ),
          );
        case ScanUnknownBarcode(:final barcode):
          HapticFeedback.vibrate();
          messenger.showSnackBar(
            SnackBar(
              backgroundColor: Theme.of(context).colorScheme.error,
              content: Text('Unknown barcode: $barcode'),
            ),
          );
      }
    }

    // Zebra DataWedge scans arrive over the platform channel.
    useEffect(() {
      final sub = DataWedgeScanner.stream.listen(handleBarcode);
      return sub.cancel;
    }, const []);

    Future<void> validate() async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Validate transfer?'),
          content: const Text('Unfinished quantities will go to a backorder.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Validate'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
      await ref.read(scanServiceProvider).validate(pickingId: pickingId);
      unawaited(ref.read(syncEngineProvider)?.sync());
      if (context.mounted) AutoRouter.of(context).maybePop();
    }

    return Scaffold(
      appBar: AppBar(title: Text('Receipt #$pickingId')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: manualController,
              autofocus: false,
              decoration: InputDecoration(
                labelText: 'Scan or type a barcode',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: () =>
                      showScannerSheet(context, onBarcode: handleBarcode),
                ),
              ),
              // Hardware keyboard-wedge scanners type + submit here.
              onSubmitted: (value) {
                handleBarcode(value);
                manualController.clear();
              },
            ),
          ),
          Expanded(
            child: lines.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (rows) => ListView.separated(
                itemCount: rows.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final line = rows[i];
                  return ListTile(
                    leading: Icon(
                      line.picked
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: line.picked ? Colors.green : null,
                    ),
                    title: Text(line.productName),
                    trailing: Text(
                      line.quantity.toStringAsFixed(0),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  );
                },
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton.icon(
                onPressed: validate,
                icon: const Icon(Icons.check),
                label: const Text('Validate'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
