import 'package:flutter/material.dart';

import '../data/sync/sync_engine.dart';

/// One place that translates a [SyncResult] into user feedback, so every
/// screen reports offline vs. auth-failure vs. conflicts the same way.
void showSyncResultSnackBar(BuildContext context, SyncResult result) {
  final messenger = ScaffoldMessenger.of(context);
  switch (result) {
    case SyncOffline():
      messenger.showSnackBar(
        const SnackBar(content: Text('Offline — showing local data')),
      );
    case SyncAuthFailed():
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: const Text(
            'Authentication failed — check your API key (disconnect and '
            'reconnect to update it). Queued work is kept.',
          ),
        ),
      );
    case SyncSuccess(:final conflicts) when conflicts > 0:
      messenger.showSnackBar(
        SnackBar(content: Text('Sync finished with $conflicts issue(s)')),
      );
    case SyncSuccess():
      break;
  }
}

/// Shown when a record left the working set (validated/confirmed elsewhere,
/// reassigned, or replaced after its create op synced).
class RecordGoneScaffold extends StatelessWidget {
  const RecordGoneScaffold({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline, size: 48),
              const SizedBox(height: 16),
              Text(message, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
