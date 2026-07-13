/// Plain DTOs for the working set pulled from Odoo.
///
/// Field names follow Odoo 17+ semantics: `stock.move.line` carries
/// `quantity` + `picked` (the old `qty_done` is gone).
library;

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
    final partner = json['partner_id'];
    final typeCode = json['picking_type_code'];
    final scheduled = json['scheduled_date'];
    return RemotePicking(
      id: json['id'] as int,
      name: json['name'] as String,
      state: json['state'] as String,
      pickingTypeCode: typeCode is String ? typeCode : '',
      partnerName: partner is List && partner.length > 1
          ? partner[1] as String
          : '',
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

  factory RemoteMoveLine.fromJson(Map<String, dynamic> json) {
    final picking = json['picking_id'];
    final product = json['product_id'];
    return RemoteMoveLine(
      id: json['id'] as int,
      pickingId: picking is List ? picking[0] as int : picking as int,
      productId: product is List ? product[0] as int : product as int,
      productName: product is List && product.length > 1
          ? product[1] as String
          : '',
      quantity: (json['quantity'] as num? ?? 0).toDouble(),
      picked: json['picked'] as bool? ?? false,
    );
  }
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
