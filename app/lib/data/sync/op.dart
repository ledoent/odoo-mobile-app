import 'dart:convert';

import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Typed outbound operations. Each op carries a client-generated UUID so a
/// retry after a dropped response can never double-apply (the server module
/// dedupes on it; the JSON-RPC path relies on absolute-set semantics).
sealed class SyncOp {
  SyncOp({String? uuid}) : uuid = uuid ?? _uuid.v4();

  final String uuid;

  String get kind;
  Map<String, dynamic> toPayload();
  String encodePayload() => jsonEncode(toPayload());

  static SyncOp decode(String kind, String payload, String uuid) {
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
      SetLeadStageOp.opKind => SetLeadStageOp(
        leadId: map['leadId'] as int,
        stageId: map['stageId'] as int,
        uuid: uuid,
      ),
      LogLeadNoteOp.opKind => LogLeadNoteOp(
        leadId: map['leadId'] as int,
        body: map['body'] as String,
        uuid: uuid,
      ),
      CreateLeadOp.opKind => CreateLeadOp(
        name: map['name'] as String,
        contactName: map['contactName'] as String? ?? '',
        phone: map['phone'] as String? ?? '',
        email: map['email'] as String? ?? '',
        localLeadId: map['localLeadId'] as int,
        uuid: uuid,
      ),
      ConfirmSaleOrderOp.opKind => ConfirmSaleOrderOp(
        orderId: map['orderId'] as int,
        uuid: uuid,
      ),
      _ => throw ArgumentError('Unknown op kind: $kind'),
    };
  }
}

class SetQuantityOp extends SyncOp {
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

class AddProductLineOp extends SyncOp {
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

class ValidatePickingOp extends SyncOp {
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

// ---- CRM ops ----

class SetLeadStageOp extends SyncOp {
  SetLeadStageOp({required this.leadId, required this.stageId, super.uuid});

  static const opKind = 'set_lead_stage';

  final int leadId;
  final int stageId;

  @override
  String get kind => opKind;

  @override
  Map<String, dynamic> toPayload() => {'leadId': leadId, 'stageId': stageId};
}

class LogLeadNoteOp extends SyncOp {
  LogLeadNoteOp({required this.leadId, required this.body, super.uuid});

  static const opKind = 'log_lead_note';

  final int leadId;
  final String body;

  @override
  String get kind => opKind;

  @override
  Map<String, dynamic> toPayload() => {'leadId': leadId, 'body': body};
}

class CreateLeadOp extends SyncOp {
  CreateLeadOp({
    required this.name,
    this.contactName = '',
    this.phone = '',
    this.email = '',
    required this.localLeadId,
    super.uuid,
  });

  static const opKind = 'create_lead';

  final String name;
  final String contactName;
  final String phone;
  final String email;

  /// Negative id of the optimistic local mirror row this op created.
  final int localLeadId;

  @override
  String get kind => opKind;

  @override
  Map<String, dynamic> toPayload() => {
    'name': name,
    'contactName': contactName,
    'phone': phone,
    'email': email,
    'localLeadId': localLeadId,
  };
}

// ---- Sales ops ----

class ConfirmSaleOrderOp extends SyncOp {
  ConfirmSaleOrderOp({required this.orderId, super.uuid});

  static const opKind = 'confirm_sale_order';

  final int orderId;

  @override
  String get kind => opKind;

  @override
  Map<String, dynamic> toPayload() => {'orderId': orderId};
}
