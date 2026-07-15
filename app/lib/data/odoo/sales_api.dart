import 'odoo_client.dart';
import 'sales_models.dart';

/// Typed façade for the Sales module flows.
abstract interface class SalesApi {
  /// Open quotations (draft/sent) assigned to the authenticated user.
  Future<List<RemoteSaleOrder>> fetchMyQuotations();
  Future<List<RemoteSaleOrderLine>> fetchOrderLines(List<int> orderIds);
  Future<void> confirmOrder({required int orderId});
}

class JsonRpcSalesApi implements SalesApi {
  JsonRpcSalesApi(this._client);

  final OdooClient _client;

  @override
  Future<List<RemoteSaleOrder>> fetchMyQuotations() async {
    final uid = _client.uid ?? await _client.authenticate();
    final rows = await _client.searchRead(
      'sale.order',
      [
        ['user_id', '=', uid],
        [
          'state',
          'in',
          ['draft', 'sent'],
        ],
      ],
      ['name', 'partner_id', 'state', 'amount_total', 'date_order'],
      order: 'date_order desc, id desc',
    );
    return rows.map(RemoteSaleOrder.fromJson).toList();
  }

  @override
  Future<List<RemoteSaleOrderLine>> fetchOrderLines(List<int> orderIds) async {
    if (orderIds.isEmpty) return [];
    final rows = await _client.searchRead(
      'sale.order.line',
      [
        ['order_id', 'in', orderIds],
        ['display_type', '=', false],
      ],
      ['order_id', 'name', 'product_uom_qty', 'price_subtotal'],
    );
    return rows.map(RemoteSaleOrderLine.fromJson).toList();
  }

  @override
  Future<void> confirmOrder({required int orderId}) async {
    // Replay tolerance: a retry after a lost response must not fail on an
    // order that the first attempt already confirmed.
    final rows = await _client.searchRead(
      'sale.order',
      [
        ['id', '=', orderId],
      ],
      ['state'],
      limit: 1,
    );
    final state = rows.isEmpty ? null : rows.first['state'] as String?;
    if (state == null || state == 'sale' || state == 'done') return;
    await _client.executeKw('sale.order', 'action_confirm', [
      [orderId],
    ]);
  }
}
