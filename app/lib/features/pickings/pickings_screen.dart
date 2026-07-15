import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/providers.dart';
import '../../core/sync_feedback.dart';
import '../../core/router.dart';
import '../../data/local/database.dart';

final _pickingsProvider = StreamProvider<List<Picking>>(
  (ref) => ref.watch(databaseProvider).watchPickings(),
);

/// Open receipts from the local mirror. Pull-to-refresh triggers a sync;
/// the list itself always renders from Drift so it works offline.
@RoutePage()
class PickingsScreen extends ConsumerWidget {
  const PickingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pickings = ref.watch(_pickingsProvider);
    final pendingOps = ref.watch(pendingOpCountProvider).value ?? 0;

    Future<void> refresh() async {
      final engine = ref.read(syncEngineProvider);
      if (engine == null) return;
      final result = await engine.sync();
      if (context.mounted) showSyncResultSnackBar(context, result);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipts'),
        actions: [
          if (pendingOps > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Badge(
                label: Text('$pendingOps'),
                child: const Icon(Icons.cloud_upload_outlined),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: refresh,
        child: pickings.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (rows) => rows.isEmpty
              ? ListView(
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        'No open receipts.\nPull down to sync.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                )
              : ListView.separated(
                  itemCount: rows.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final p = rows[i];
                    return ListTile(
                      title: Text(
                        p.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        [
                          if (p.partnerName.isNotEmpty) p.partnerName,
                          if (p.scheduledDate != null)
                            p.scheduledDate!
                                .toLocal()
                                .toString()
                                .split(' ')
                                .first,
                        ].join(' · '),
                      ),
                      trailing: _StateChip(state: p.state),
                      onTap: () => AutoRouter.of(
                        context,
                      ).push(PickingDetailRoute(pickingId: p.id)),
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class _StateChip extends StatelessWidget {
  const _StateChip({required this.state});

  final String state;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (label, color) = switch (state) {
      'assigned' => ('Ready', scheme.primaryContainer),
      'confirmed' => ('Waiting', scheme.tertiaryContainer),
      'done' => ('Done', scheme.secondaryContainer),
      _ => (state, scheme.surfaceContainerHighest),
    };
    return Chip(label: Text(label), backgroundColor: color);
  }
}
