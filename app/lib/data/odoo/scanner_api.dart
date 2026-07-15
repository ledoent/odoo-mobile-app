import 'models.dart';
import 'odoo_client.dart';

/// Typed façade over the Odoo transport for the scanner flows.
///
/// v0.1 speaks raw JSON-RPC ([JsonRpcScannerApi]); the same interface will be
/// backed by the `stock_barcode_api` REST endpoints once the server module is
/// deployed, without touching the sync engine or UI.
abstract interface class ScannerApi {
  Future<List<RemotePicking>> fetchOpenPickings({
    required String pickingTypeCode,
  });
  Future<List<RemoteMoveLine>> fetchMoveLines(List<int> pickingIds);
  Future<List<RemoteProduct>> fetchProducts(List<int> productIds);
  Future<RemoteProduct?> productByBarcode(String barcode);

  /// Sets the done quantity on a move line (Odoo 17+: `quantity` + `picked`).
  Future<void> setMoveLineQuantity({
    required int moveLineId,
    required double quantity,
  });

  /// Creates a move line on a picking for a product not yet reserved.
  Future<int> createMoveLine({
    required int pickingId,
    required int productId,
    required double quantity,
  });

  /// Validates a picking, resolving the backorder wizard if it appears.
  Future<void> validatePicking({
    required int pickingId,
    bool createBackorder = true,
  });
}

class JsonRpcScannerApi implements ScannerApi {
  JsonRpcScannerApi(this._client);

  final OdooClient _client;

  static const _pickingFields = [
    'name',
    'state',
    'partner_id',
    'picking_type_code',
    'scheduled_date',
  ];

  @override
  Future<List<RemotePicking>> fetchOpenPickings({
    required String pickingTypeCode,
  }) async {
    final rows = await _client.searchRead(
      'stock.picking',
      [
        [
          'state',
          'in',
          ['assigned', 'confirmed'],
        ],
        ['picking_type_code', '=', pickingTypeCode],
      ],
      _pickingFields,
      order: 'scheduled_date asc, id asc',
    );
    return rows.map(RemotePicking.fromJson).toList();
  }

  @override
  Future<List<RemoteMoveLine>> fetchMoveLines(List<int> pickingIds) async {
    if (pickingIds.isEmpty) return [];
    final rows = await _client.searchRead(
      'stock.move.line',
      [
        ['picking_id', 'in', pickingIds],
      ],
      ['picking_id', 'product_id', 'quantity', 'picked'],
    );
    return rows.map(RemoteMoveLine.fromJson).toList();
  }

  @override
  Future<List<RemoteProduct>> fetchProducts(List<int> productIds) async {
    if (productIds.isEmpty) return [];
    final rows = await _client.searchRead(
      'product.product',
      [
        ['id', 'in', productIds],
      ],
      ['name', 'barcode'],
    );
    return rows.map(RemoteProduct.fromJson).toList();
  }

  @override
  Future<RemoteProduct?> productByBarcode(String barcode) async {
    final rows = await _client.searchRead(
      'product.product',
      [
        ['barcode', '=', barcode],
      ],
      ['name', 'barcode'],
      limit: 1,
    );
    return rows.isEmpty ? null : RemoteProduct.fromJson(rows.first);
  }

  @override
  Future<void> setMoveLineQuantity({
    required int moveLineId,
    required double quantity,
  }) async {
    await _client.executeKw('stock.move.line', 'write', [
      [moveLineId],
      {'quantity': quantity, 'picked': true},
    ]);
  }

  @override
  Future<int> createMoveLine({
    required int pickingId,
    required int productId,
    required double quantity,
  }) async {
    final id = await _client.executeKw('stock.move.line', 'create', [
      {
        'picking_id': pickingId,
        'product_id': productId,
        'quantity': quantity,
        'picked': true,
      },
    ]);
    return id as int;
  }

  @override
  Future<void> validatePicking({
    required int pickingId,
    bool createBackorder = true,
  }) async {
    // Replay tolerance: skip if a previous (response-lost) attempt already
    // validated this picking.
    final rows = await _client.searchRead(
      'stock.picking',
      [
        ['id', '=', pickingId],
      ],
      ['state'],
      limit: 1,
    );
    final state = rows.isEmpty ? null : rows.first['state'] as String?;
    if (state == null || state == 'done' || state == 'cancel') return;
    final result = await _client.executeKw('stock.picking', 'button_validate', [
      [pickingId],
    ]);
    // button_validate returns True when done, or a wizard action when
    // confirmation is needed (e.g. stock.backorder.confirmation).
    if (result is Map &&
        result['res_model'] == 'stock.backorder.confirmation') {
      final context =
          (result['context'] as Map?)?.cast<String, dynamic>() ?? {};
      final wizardId = await _client.executeKw(
        'stock.backorder.confirmation',
        'create',
        [<String, dynamic>{}],
        {'context': context},
      );
      await _client.executeKw(
        'stock.backorder.confirmation',
        createBackorder ? 'process' : 'process_cancel_backorder',
        [
          [wizardId],
        ],
        {'context': context},
      );
    }
  }
}
