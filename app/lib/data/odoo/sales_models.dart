/// DTOs for the Sales working set (my open quotations).
library;

import 'odoo_json.dart';

class RemoteSaleOrder {
  const RemoteSaleOrder({
    required this.id,
    required this.name,
    required this.state,
    this.partnerName = '',
    this.amountTotal = 0,
    this.dateOrder,
  });

  final int id;
  final String name;
  final String state;
  final String partnerName;
  final double amountTotal;
  final DateTime? dateOrder;

  factory RemoteSaleOrder.fromJson(Map<String, dynamic> json) {
    final date = json['date_order'];
    return RemoteSaleOrder(
      id: json['id'] as int,
      name: json['name'] as String,
      state: json['state'] as String,
      partnerName: relName(json['partner_id']),
      amountTotal: (json['amount_total'] as num? ?? 0).toDouble(),
      dateOrder: date is String ? DateTime.tryParse(date) : null,
    );
  }
}

class RemoteSaleOrderLine {
  const RemoteSaleOrderLine({
    required this.id,
    required this.orderId,
    required this.description,
    required this.quantity,
    required this.priceSubtotal,
  });

  final int id;
  final int orderId;
  final String description;
  final double quantity;
  final double priceSubtotal;

  factory RemoteSaleOrderLine.fromJson(Map<String, dynamic> json) =>
      RemoteSaleOrderLine(
        id: json['id'] as int,
        orderId: relId(json['order_id'])!,
        description: odooString(json['name']),
        quantity: (json['product_uom_qty'] as num? ?? 0).toDouble(),
        priceSubtotal: (json['price_subtotal'] as num? ?? 0).toDouble(),
      );
}
