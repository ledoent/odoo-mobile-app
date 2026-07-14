import 'package:dio/dio.dart';
import 'package:odoo_scanner/data/odoo/crm_api.dart';
import 'package:odoo_scanner/data/odoo/crm_models.dart';
import 'package:odoo_scanner/data/odoo/models.dart';
import 'package:odoo_scanner/data/odoo/sales_api.dart';
import 'package:odoo_scanner/data/odoo/sales_models.dart';
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

/// In-memory fake CRM backend.
class FakeCrmApi implements CrmApi {
  final List<String> applied = [];

  List<RemoteLead> leads = [];
  List<RemoteCrmStage> stages = [];

  Object? nextError;
  int _createdId = 5000;

  void _maybeThrow() {
    final error = nextError;
    if (error != null) {
      nextError = null;
      throw error;
    }
  }

  @override
  Future<List<RemoteLead>> fetchMyOpenLeads() async => leads;

  @override
  Future<List<RemoteCrmStage>> fetchStages() async => stages;

  @override
  Future<void> setLeadStage({required int leadId, required int stageId}) async {
    _maybeThrow();
    applied.add('stage:$leadId->$stageId');
  }

  @override
  Future<void> logNote({required int leadId, required String body}) async {
    _maybeThrow();
    applied.add('note:$leadId:$body');
  }

  @override
  Future<int> createLead({
    required String name,
    String contactName = '',
    String phone = '',
    String email = '',
  }) async {
    _maybeThrow();
    applied.add('lead:$name');
    return ++_createdId;
  }
}

/// In-memory fake Sales backend.
class FakeSalesApi implements SalesApi {
  final List<String> applied = [];

  List<RemoteSaleOrder> orders = [];
  List<RemoteSaleOrderLine> lines = [];

  Object? nextError;

  @override
  Future<List<RemoteSaleOrder>> fetchMyQuotations() async => orders;

  @override
  Future<List<RemoteSaleOrderLine>> fetchOrderLines(List<int> orderIds) async =>
      lines.where((l) => orderIds.contains(l.orderId)).toList();

  @override
  Future<void> confirmOrder({required int orderId}) async {
    final error = nextError;
    if (error != null) {
      nextError = null;
      throw error;
    }
    applied.add('confirm:$orderId');
  }
}
