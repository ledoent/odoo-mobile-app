import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/providers.dart';
import '../../core/router.dart';
import '../../data/sync/sync_engine.dart';
import 'sync_issues_sheet.dart';

/// Role-based entry point: one tile per module. Everything renders from the
/// local mirror, so every module works offline once synced.
@RoutePage()
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingOps = ref.watch(pendingOpCountProvider).value ?? 0;
    final conflicts = ref.watch(conflictOpsProvider).value ?? [];

    Future<void> refresh() async {
      final engine = ref.read(syncEngineProvider);
      if (engine == null) return;
      final result = await engine.sync();
      if (result is SyncOffline && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Offline — showing local data')),
        );
      }
    }

    Future<void> logout() async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Disconnect?'),
          content: const Text(
            'This removes the stored API key. Unsynced operations stay queued.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Disconnect'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
      await ref.read(sessionRepositoryProvider).clear();
      ref.invalidate(sessionProvider);
      if (context.mounted) {
        AutoRouter.of(context).replaceAll([const OnboardingRoute()]);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Odoo Mobile'),
        actions: [
          if (conflicts.isNotEmpty)
            IconButton(
              tooltip: 'Sync issues',
              onPressed: () => showSyncIssuesSheet(context),
              icon: Badge(
                label: Text('${conflicts.length}'),
                backgroundColor: Theme.of(context).colorScheme.error,
                child: const Icon(Icons.sync_problem),
              ),
            ),
          if (pendingOps > 0)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Badge(
                label: Text('$pendingOps'),
                child: const Icon(Icons.cloud_upload_outlined),
              ),
            ),
          IconButton(icon: const Icon(Icons.logout), onPressed: logout),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: refresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _ModuleTile(
              icon: Icons.warehouse_outlined,
              title: 'Warehouse',
              subtitle: 'Receive: scan products into open receipts',
              onTap: () => AutoRouter.of(context).push(const PickingsRoute()),
            ),
            _ModuleTile(
              icon: Icons.filter_alt_outlined,
              title: 'CRM',
              subtitle: 'My pipeline: leads, stages, notes',
              onTap: () =>
                  AutoRouter.of(context).push(const CrmPipelineRoute()),
            ),
            _ModuleTile(
              icon: Icons.request_quote_outlined,
              title: 'Sales',
              subtitle: 'My quotations: review and confirm',
              onTap: () => AutoRouter.of(context).push(const QuotationsRoute()),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModuleTile extends StatelessWidget {
  const _ModuleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        leading: Icon(icon, size: 40),
        title: Text(title, style: Theme.of(context).textTheme.titleLarge),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
