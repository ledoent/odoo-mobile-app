import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/providers.dart';

/// Conflicted operations: the server refused them (record changed or gone).
/// The operator decides per op — retry against fresh state, or discard.
Future<void> showSyncIssuesSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => const _SyncIssuesList(),
  );
}

class _SyncIssuesList extends ConsumerWidget {
  const _SyncIssuesList();

  static const _labels = {
    'set_quantity': 'Set quantity',
    'add_product_line': 'Add product line',
    'validate_picking': 'Validate transfer',
    'set_lead_stage': 'Move lead stage',
    'log_lead_note': 'Log note',
    'create_lead': 'Create lead',
    'confirm_sale_order': 'Confirm order',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conflicts = ref.watch(conflictOpsProvider).value ?? [];
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sync issues', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            const Text(
              'The server rejected these operations. Retry after checking '
              'the record, or discard.',
            ),
            const SizedBox(height: 8),
            if (conflicts.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: Text('No sync issues.')),
              ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final op in conflicts)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(_labels[op.kind] ?? op.kind),
                      subtitle: Text(
                        op.lastError ?? 'Rejected by the server',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Retry',
                            icon: const Icon(Icons.refresh),
                            onPressed: () async {
                              final db = ref.read(databaseProvider);
                              await db.retryOp(op.id);
                              unawaited(ref.read(syncEngineProvider)?.sync());
                            },
                          ),
                          IconButton(
                            tooltip: 'Discard',
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () async {
                              await ref.read(databaseProvider).discardOp(op.id);
                              // Re-pull so optimistic mirror changes from
                              // the dropped op revert to server truth.
                              unawaited(ref.read(syncEngineProvider)?.sync());
                            },
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
