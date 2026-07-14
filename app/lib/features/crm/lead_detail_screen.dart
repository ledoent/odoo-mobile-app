import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/providers.dart';
import '../../data/local/database.dart';

final _leadProvider = FutureProvider.family<Lead?, int>(
  (ref, id) => ref.watch(databaseProvider).leadById(id),
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
    final lead = ref.watch(_leadProvider(leadId)).value;
    final stages = ref.watch(_stagesProvider).value ?? [];

    if (lead == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    Future<void> moveTo(CrmStage stage) async {
      await ref
          .read(crmServiceProvider)
          .setStage(leadId: leadId, stageId: stage.id, stageName: stage.name);
      ref.invalidate(_leadProvider(leadId));
      unawaited(ref.read(syncEngineProvider)?.sync());
    }

    return Scaffold(
      appBar: AppBar(title: Text(lead.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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
                  onSelected: (_) => moveTo(stage),
                ),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _logNote(context, ref),
            icon: const Icon(Icons.edit_note),
            label: const Text('Log a note'),
          ),
        ],
      ),
    );
  }
}
