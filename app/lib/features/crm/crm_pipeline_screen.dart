import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/providers.dart';
import '../../core/router.dart';
import '../../data/local/database.dart';

final _leadsProvider = StreamProvider<List<Lead>>(
  (ref) => ref.watch(databaseProvider).watchLeads(),
);

/// My open opportunities, grouped by pipeline stage, from the local mirror.
@RoutePage()
class CrmPipelineScreen extends ConsumerWidget {
  const CrmPipelineScreen({super.key});

  Future<void> _quickAdd(BuildContext context, WidgetRef ref) async {
    final name = TextEditingController();
    final contact = TextEditingController();
    final phone = TextEditingController();
    final created = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New lead'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Opportunity *'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: contact,
              decoration: const InputDecoration(labelText: 'Contact'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          // Create stays disabled until the required name is filled, so a
          // mis-tap can never silently discard what was typed.
          ValueListenableBuilder(
            valueListenable: name,
            builder: (context, value, _) => FilledButton(
              onPressed: value.text.trim().isEmpty
                  ? null
                  : () => Navigator.pop(context, true),
              child: const Text('Create'),
            ),
          ),
        ],
      ),
    );
    if (created != true || name.text.trim().isEmpty) return;
    await ref
        .read(crmServiceProvider)
        .createLead(
          name: name.text.trim(),
          contactName: contact.text.trim(),
          phone: phone.text.trim(),
        );
    unawaited(ref.read(syncEngineProvider)?.sync());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leads = ref.watch(_leadsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Pipeline')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _quickAdd(context, ref),
        child: const Icon(Icons.add),
      ),
      body: leads.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (rows) {
          if (rows.isEmpty) {
            return const Center(
              child: Text(
                'No open opportunities.\nSync from the home screen.',
                textAlign: TextAlign.center,
              ),
            );
          }
          // Group by stage, preserving the stage-ordered query. Local
          // quick-adds (negative id) haven't reached the server yet.
          final sections = <String, List<Lead>>{};
          for (final lead in rows) {
            final section = lead.id < 0
                ? 'Pending sync'
                : (lead.stageName.isEmpty ? 'No stage' : lead.stageName);
            sections.putIfAbsent(section, () => []).add(lead);
          }
          return ListView(
            children: [
              for (final entry in sections.entries) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Text(
                    '${entry.key} (${entry.value.length})',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                for (final lead in entry.value)
                  ListTile(
                    title: Text(lead.name),
                    subtitle: Text(lead.partnerName),
                    leading: lead.id < 0
                        ? const Icon(Icons.cloud_upload_outlined)
                        : null,
                    trailing: lead.expectedRevenue > 0
                        ? Text(lead.expectedRevenue.toStringAsFixed(0))
                        : null,
                    onTap: () => AutoRouter.of(
                      context,
                    ).push(LeadDetailRoute(leadId: lead.id)),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}
