import 'package:dio/dio.dart';
import 'package:odoo_scanner/data/odoo/models.dart';
import 'package:odoo_scanner/data/odoo/odoo_client.dart';
import 'package:odoo_scanner/data/odoo/scanner_api.dart';

/// In-memory fake Odoo. Records applied ops; can be scripted to fail with
/// transport errors (offline) or RPC errors (server-side conflicts).
class FakeScannerApi implements ScannerApi {
  final List<String> applied = [];

  List<RemotePicking> pickings = [];
  List<RemoteMoveLine> moveLines = [];
  List<RemoteProduct> products = [];

  /// When set, the next write throws this and it resets to null.
  Object? nextError;
  int _createdId = 1000;

  void _maybeThrow() {
    final error = nextError;
    if (error != null) {
      nextError = null;
      throw error;
    }
  }

  static DioException offline() => DioException(
    requestOptions: RequestOptions(path: '/jsonrpc'),
    type: DioExceptionType.connectionError,
  );

  static OdooRpcException conflict(String message) => OdooRpcException(message);

  @override
  Future<List<RemotePicking>> fetchOpenPickings({
    required String pickingTypeCode,
  }) async =>
      pickings.where((p) => p.pickingTypeCode == pickingTypeCode).toList();

  @override
  Future<List<RemoteMoveLine>> fetchMoveLines(List<int> pickingIds) async =>
      moveLines.where((l) => pickingIds.contains(l.pickingId)).toList();

  @override
  Future<List<RemoteProduct>> fetchProducts(List<int> productIds) async =>
      products.where((p) => productIds.contains(p.id)).toList();

  @override
  Future<RemoteProduct?> productByBarcode(String barcode) async =>
      products.where((p) => p.barcode == barcode).firstOrNull;

  @override
  Future<void> setMoveLineQuantity({
    required int moveLineId,
    required double quantity,
  }) async {
    _maybeThrow();
    applied.add('set:$moveLineId=$quantity');
  }

  @override
  Future<int> createMoveLine({
    required int pickingId,
    required int productId,
    required double quantity,
  }) async {
    _maybeThrow();
    applied.add('create:$pickingId/$productId=$quantity');
    return ++_createdId;
  }

  @override
  Future<void> validatePicking({
    required int pickingId,
    bool createBackorder = true,
  }) async {
    _maybeThrow();
    applied.add('validate:$pickingId(backorder=$createBackorder)');
  }
}
