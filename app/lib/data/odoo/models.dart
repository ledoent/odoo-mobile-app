/// Plain DTOs for the working set pulled from Odoo.
///
/// Field names follow Odoo 17+ semantics: `stock.move.line` carries
/// `quantity` + `picked` (the old `qty_done` is gone).
library;

import 'odoo_json.dart';

class RemotePicking {
  const RemotePicking({
    required this.id,
    required this.name,
    required this.state,
    required this.pickingTypeCode,
    this.partnerName = '',
    this.scheduledDate,
  });

  final int id;
  final String name;
  final String state;
  final String pickingTypeCode;
  final String partnerName;
  final DateTime? scheduledDate;

  factory RemotePicking.fromJson(Map<String, dynamic> json) {
    final scheduled = json['scheduled_date'];
    return RemotePicking(
      id: json['id'] as int,
      name: json['name'] as String,
      state: json['state'] as String,
      pickingTypeCode: odooString(json['picking_type_code']),
      partnerName: relName(json['partner_id']),
      scheduledDate: scheduled is String ? DateTime.tryParse(scheduled) : null,
    );
  }
}

class RemoteMoveLine {
  const RemoteMoveLine({
    required this.id,
    required this.pickingId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.picked,
  });

  final int id;
  final int pickingId;
  final int productId;
  final String productName;
  final double quantity;
  final bool picked;

  factory RemoteMoveLine.fromJson(Map<String, dynamic> json) => RemoteMoveLine(
    id: json['id'] as int,
    pickingId: relId(json['picking_id'])!,
    productId: relId(json['product_id'])!,
    productName: relName(json['product_id']),
    quantity: (json['quantity'] as num? ?? 0).toDouble(),
    picked: json['picked'] as bool? ?? false,
  );
}

class RemoteProduct {
  const RemoteProduct({required this.id, required this.name, this.barcode});

  final int id;
  final String name;
  final String? barcode;

  factory RemoteProduct.fromJson(Map<String, dynamic> json) {
    final barcode = json['barcode'];
    return RemoteProduct(
      id: json['id'] as int,
      name: json['name'] as String,
      barcode: barcode is String && barcode.isNotEmpty ? barcode : null,
    );
  }
}
