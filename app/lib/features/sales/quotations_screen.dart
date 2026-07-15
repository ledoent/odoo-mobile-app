import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/providers.dart';
import '../../core/router.dart';
import '../../data/local/database.dart';

final _ordersProvider = StreamProvider<List<SaleOrder>>(
  (ref) => ref.watch(databaseProvider).watchSaleOrders(),
);

/// My open quotations (draft/sent) from the local mirror.
@RoutePage()
class QuotationsScreen extends ConsumerWidget {
  const QuotationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(_ordersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Quotations')),
      body: orders.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (rows) => rows.isEmpty
            ? const Center(
                child: Text(
                  'No open quotations.\nSync from the home screen.',
                  textAlign: TextAlign.center,
                ),
              )
            : ListView.separated(
                itemCount: rows.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final order = rows[i];
                  return ListTile(
                    title: Text(
                      order.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(order.partnerName),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(order.amountTotal.toStringAsFixed(2)),
                        Text(
                          order.state == 'sale' ? 'confirmed' : order.state,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    onTap: () => AutoRouter.of(
                      context,
                    ).push(QuotationDetailRoute(orderId: order.id)),
                  );
                },
              ),
      ),
    );
  }
}
