import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/providers.dart';
import '../../core/sync_feedback.dart';
import '../../data/local/database.dart';

final _leadProvider = StreamProvider.family<Lead?, int>(
  (ref, id) => ref
      .watch(databaseProvider)
      .watchLeads()
      .map((rows) => rows.where((l) => l.id == id).firstOrNull),
);

final _stagesProvider = StreamProvider<List<CrmStage>>(
  (ref) => ref.watch(databaseProvider).watchCrmStages(),
);

/// One opportunity: stage move + log-a-note, both offline-queued.
@RoutePage()
class LeadDetailScreen extends ConsumerWidget {
  const LeadDetailScreen({super.key, required this.leadId});

  final int leadId;

  Future<void> _logNote(BuildContext context, WidgetRef ref) async {
    final note = TextEditingController();
    final send = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log a note'),
        content: TextField(
          controller: note,
          autofocus: true,
          maxLines: 4,
          decoration: const InputDecoration(hintText: 'Called them, they…'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log'),
          ),
        ],
      ),
    );
    if (send != true || note.text.trim().isEmpty) return;
    await ref
        .read(crmServiceProvider)
        .logNote(leadId: leadId, body: note.text.trim());
    unawaited(ref.read(syncEngineProvider)?.sync());
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Note queued')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leadAsync = ref.watch(_leadProvider(leadId));
    final stages = ref.watch(_stagesProvider).value ?? [];

    if (leadAsync.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final lead = leadAsync.value;
    if (lead == null) {
      // A pending quick-add's -1 row is replaced by the server row after its
      // create op syncs; won/reassigned leads also leave the working set.
      return const RecordGoneScaffold(
        message:
            'This lead is no longer in your open pipeline — it synced, was '
            'won, or was reassigned. Check the pipeline list for it.',
      );
    }

    // Quick-added locally, not on the server yet: read-only until the op
    // syncs (stage moves and notes need a real server id).
    final pendingSync = leadId < 0;

    Future<void> moveTo(CrmStage stage) async {
      await ref
          .read(crmServiceProvider)
          .setStage(leadId: leadId, stageId: stage.id, stageName: stage.name);
      unawaited(ref.read(syncEngineProvider)?.sync());
    }

    return Scaffold(
      appBar: AppBar(title: Text(lead.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (pendingSync)
            Card(
              color: Theme.of(context).colorScheme.tertiaryContainer,
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.cloud_upload_outlined),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Waiting to sync — stage moves and notes unlock '
                        'once this lead reaches the server.',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (lead.partnerName.isNotEmpty)
            ListTile(
              leading: const Icon(Icons.business_outlined),
              title: Text(lead.partnerName),
            ),
          if (lead.phone.isNotEmpty)
            ListTile(
              leading: const Icon(Icons.phone_outlined),
              title: Text(lead.phone),
            ),
          if (lead.email.isNotEmpty)
            ListTile(
              leading: const Icon(Icons.mail_outlined),
              title: Text(lead.email),
            ),
          if (lead.expectedRevenue > 0)
            ListTile(
              leading: const Icon(Icons.payments_outlined),
              title: Text(lead.expectedRevenue.toStringAsFixed(0)),
              subtitle: const Text('Expected revenue'),
            ),
          const SizedBox(height: 8),
          Text('Stage', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final stage in stages)
                ChoiceChip(
                  label: Text(stage.name),
                  selected: stage.id == lead.stageId,
                  onSelected: pendingSync ? null : (_) => moveTo(stage),
                ),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: pendingSync ? null : () => _logNote(context, ref),
            icon: const Icon(Icons.edit_note),
            label: const Text('Log a note'),
          ),
        ],
      ),
    );
  }
}
