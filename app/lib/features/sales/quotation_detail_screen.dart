import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/providers.dart';
import '../../core/sync_feedback.dart';
import '../../data/local/database.dart';

final _orderProvider = StreamProvider.family<SaleOrder?, int>(
  (ref, id) => ref
      .watch(databaseProvider)
      .watchSaleOrders()
      .map((rows) => rows.where((o) => o.id == id).firstOrNull),
);

final _linesProvider = StreamProvider.family<List<SaleOrderLine>, int>(
  (ref, id) => ref.watch(databaseProvider).watchSaleOrderLines(id),
);

/// One quotation: lines + offline-queued confirmation.
@RoutePage()
class QuotationDetailScreen extends ConsumerWidget {
  const QuotationDetailScreen({super.key, required this.orderId});

  final int orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(_orderProvider(orderId));
    final lines = ref.watch(_linesProvider(orderId)).value ?? [];

    if (orderAsync.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final order = orderAsync.value;
    if (order == null) {
      // Confirmed orders leave the draft/sent working set on the next pull.
      return const RecordGoneScaffold(
        message:
            'This quotation left your open list — it was confirmed or '
            'reassigned. Pull to refresh on the list for current data.',
      );
    }

    Future<void> confirm() async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Confirm ${order.name}?'),
          content: Text(
            'Turns the quotation into a sales order '
            '(${order.amountTotal.toStringAsFixed(2)}).',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirm order'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
      await ref.read(salesServiceProvider).confirmOrder(orderId: orderId);
      unawaited(ref.read(syncEngineProvider)?.sync());
    }

    final isOpen = order.state == 'draft' || order.state == 'sent';

    return Scaffold(
      appBar: AppBar(title: Text(order.name)),
      body: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.business_outlined),
            title: Text(order.partnerName),
            subtitle: Text(
              order.dateOrder?.toLocal().toString().split(' ').first ?? '',
            ),
            trailing: Text(
              order.amountTotal.toStringAsFixed(2),
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              itemCount: lines.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final line = lines[i];
                return ListTile(
                  title: Text(line.description),
                  subtitle: Text('× ${line.quantity.toStringAsFixed(0)}'),
                  trailing: Text(line.priceSubtotal.toStringAsFixed(2)),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton.icon(
                onPressed: isOpen ? confirm : null,
                icon: const Icon(Icons.check),
                label: Text(isOpen ? 'Confirm order' : 'Confirmed'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
