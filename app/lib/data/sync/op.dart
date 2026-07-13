import 'dart:convert';

import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Typed outbound operations. Each op carries a client-generated UUID so a
/// retry after a dropped response can never double-apply (the server module
/// dedupes on it; the JSON-RPC path relies on absolute-set semantics).
sealed class ScanOp {
  ScanOp({String? uuid}) : uuid = uuid ?? _uuid.v4();

  final String uuid;

  String get kind;
  Map<String, dynamic> toPayload();
  String encodePayload() => jsonEncode(toPayload());

  static ScanOp decode(String kind, String payload, String uuid) {
    final map = jsonDecode(payload) as Map<String, dynamic>;
    return switch (kind) {
      SetQuantityOp.opKind => SetQuantityOp(
        moveLineId: map['moveLineId'] as int,
        quantity: (map['quantity'] as num).toDouble(),
        uuid: uuid,
      ),
      AddProductLineOp.opKind => AddProductLineOp(
        pickingId: map['pickingId'] as int,
        productId: map['productId'] as int,
        quantity: (map['quantity'] as num).toDouble(),
        localMoveLineId: map['localMoveLineId'] as int,
        uuid: uuid,
      ),
      ValidatePickingOp.opKind => ValidatePickingOp(
        pickingId: map['pickingId'] as int,
        createBackorder: map['createBackorder'] as bool? ?? true,
        uuid: uuid,
      ),
      _ => throw ArgumentError('Unknown op kind: $kind'),
    };
  }
}

class SetQuantityOp extends ScanOp {
  SetQuantityOp({required this.moveLineId, required this.quantity, super.uuid});

  static const opKind = 'set_quantity';

  final int moveLineId;
  final double quantity;

  @override
  String get kind => opKind;

  @override
  Map<String, dynamic> toPayload() => {
    'moveLineId': moveLineId,
    'quantity': quantity,
  };
}

class AddProductLineOp extends ScanOp {
  AddProductLineOp({
    required this.pickingId,
    required this.productId,
    required this.quantity,
    required this.localMoveLineId,
    super.uuid,
  });

  static const opKind = 'add_product_line';

  final int pickingId;
  final int productId;
  final double quantity;

  /// Negative id of the optimistic local mirror row this op created.
  final int localMoveLineId;

  @override
  String get kind => opKind;

  @override
  Map<String, dynamic> toPayload() => {
    'pickingId': pickingId,
    'productId': productId,
    'quantity': quantity,
    'localMoveLineId': localMoveLineId,
  };
}

class ValidatePickingOp extends ScanOp {
  ValidatePickingOp({
    required this.pickingId,
    this.createBackorder = true,
    super.uuid,
  });

  static const opKind = 'validate_picking';

  final int pickingId;
  final bool createBackorder;

  @override
  String get kind => opKind;

  @override
  Map<String, dynamic> toPayload() => {
    'pickingId': pickingId,
    'createBackorder': createBackorder,
  };
}
