import 'package:dio/dio.dart';
import 'package:odoo_scanner/data/odoo/crm_api.dart';
import 'package:odoo_scanner/data/odoo/crm_models.dart';
import 'package:odoo_scanner/data/odoo/models.dart';
import 'package:odoo_scanner/data/odoo/odoo_client.dart';
import 'package:odoo_scanner/data/odoo/sales_api.dart';
import 'package:odoo_scanner/data/odoo/sales_models.dart';
import 'package:odoo_scanner/data/odoo/scanner_api.dart';

/// Scriptable one-shot failure: set [nextError] and the next write throws it.
mixin ThrowOnce {
  Object? nextError;

  void maybeThrow() {
    final error = nextError;
    if (error != null) {
      nextError = null;
      throw error;
    }
  }
}

/// In-memory fake Odoo. Records applied ops; can be scripted to fail with
/// transport errors (offline), RPC errors (conflicts), or auth errors.
class FakeScannerApi with ThrowOnce implements ScannerApi {
  final List<String> applied = [];

  List<RemotePicking> pickings = [];
  List<RemoteMoveLine> moveLines = [];
  List<RemoteProduct> products = [];

  int _createdId = 1000;

  static DioException offline() => DioException(
    requestOptions: RequestOptions(path: '/jsonrpc'),
    type: DioExceptionType.connectionError,
  );

  static OdooRpcException conflict(String message) => OdooRpcException(message);

  static OdooAuthException authFailure() => OdooAuthException('Access Denied');

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
    maybeThrow();
    applied.add('set:$moveLineId=$quantity');
  }

  @override
  Future<int> createMoveLine({
    required int pickingId,
    required int productId,
    required double quantity,
  }) async {
    maybeThrow();
    applied.add('create:$pickingId/$productId=$quantity');
    return ++_createdId;
  }

  @override
  Future<void> validatePicking({
    required int pickingId,
    bool createBackorder = true,
  }) async {
    maybeThrow();
    applied.add('validate:$pickingId(backorder=$createBackorder)');
  }
}

/// In-memory fake CRM backend.
class FakeCrmApi with ThrowOnce implements CrmApi {
  final List<String> applied = [];

  List<RemoteLead> leads = [];
  List<RemoteCrmStage> stages = [];

  int _createdId = 5000;

  @override
  Future<List<RemoteLead>> fetchMyOpenLeads() async => leads;

  @override
  Future<List<RemoteCrmStage>> fetchStages() async => stages;

  @override
  Future<void> setLeadStage({required int leadId, required int stageId}) async {
    maybeThrow();
    applied.add('stage:$leadId->$stageId');
  }

  @override
  Future<void> logNote({required int leadId, required String body}) async {
    maybeThrow();
    applied.add('note:$leadId:$body');
  }

  @override
  Future<int> createLead({
    required String name,
    String contactName = '',
    String phone = '',
    String email = '',
  }) async {
    maybeThrow();
    applied.add('lead:$name');
    return ++_createdId;
  }
}

/// In-memory fake Sales backend.
class FakeSalesApi with ThrowOnce implements SalesApi {
  final List<String> applied = [];

  List<RemoteSaleOrder> orders = [];
  List<RemoteSaleOrderLine> lines = [];

  @override
  Future<List<RemoteSaleOrder>> fetchMyQuotations() async => orders;

  @override
  Future<List<RemoteSaleOrderLine>> fetchOrderLines(List<int> orderIds) async =>
      lines.where((l) => orderIds.contains(l.orderId)).toList();

  @override
  Future<void> confirmOrder({required int orderId}) async {
    maybeThrow();
    applied.add('confirm:$orderId');
  }
}
