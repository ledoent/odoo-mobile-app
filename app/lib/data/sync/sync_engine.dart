import 'dart:async';

import 'package:dio/dio.dart';

import '../local/database.dart';
import '../odoo/crm_api.dart';
import '../odoo/odoo_client.dart';
import '../odoo/sales_api.dart';
import '../odoo/scanner_api.dart';
import 'op.dart';

sealed class SyncResult {
  const SyncResult();
}

class SyncSuccess extends SyncResult {
  const SyncSuccess({required this.applied, required this.conflicts});

  final int applied;
  final int conflicts;
}

class SyncOffline extends SyncResult {
  const SyncOffline();
}

/// Credentials were rejected (revoked/expired API key). Ops stay pending;
/// the user needs to re-authenticate, not retry.
class SyncAuthFailed extends SyncResult {
  const SyncAuthFailed();
}

/// Drains the outbound op queue in order, then refreshes the local mirrors
/// of every enabled module (warehouse, CRM, sales).
///
/// Failure policy (§6 of the plan):
/// - transport errors (no network, timeouts) stop the drain — ops stay
///   `pending` and are retried on the next connectivity event;
/// - auth errors stop everything and are reported as [SyncAuthFailed] —
///   ops stay pending; retrying can't help until the user re-authenticates;
/// - other server rejections mark the op `conflict` and keep draining — the
///   subsequent pull reloads the affected records so the operator re-checks
///   against fresh state instead of the app blindly overwriting.
class SyncEngine {
  SyncEngine({
    required this.db,
    required this.warehouseApi,
    required this.crmApi,
    required this.salesApi,
    this.pickingTypeCode = 'incoming',
  });

  final AppDatabase db;
  final ScannerApi warehouseApi;
  final CrmApi crmApi;
  final SalesApi salesApi;
  final String pickingTypeCode;

  bool _running = false;

  Future<SyncResult> sync() async {
    if (_running) return const SyncSuccess(applied: 0, conflicts: 0);
    _running = true;
    try {
      final drainResult = await _drainQueue();
      if (drainResult is! SyncSuccess) return drainResult;
      // A module the server doesn't have installed (e.g. no CRM) fails its
      // own pull with an RPC error; the other mirrors still refresh. Auth
      // failures are different: they abort the whole sync visibly.
      for (final pull in [_pullWarehouse, _pullCrm, _pullSales]) {
        try {
          await pull();
        } on OdooAuthException {
          rethrow;
        } on OdooRpcException {
          continue;
        }
      }
      return drainResult;
    } on OdooAuthException {
      return const SyncAuthFailed();
    } on DioException {
      return const SyncOffline();
    } finally {
      _running = false;
    }
  }

  Future<SyncResult> _drainQueue() async {
    var applied = 0;
    var conflicts = 0;
    for (final row in await db.pendingOps()) {
      final op = SyncOp.decode(row.kind, row.payload, row.uuid);
      try {
        await _apply(op);
        await db.markOpDone(row.id);
        applied++;
      } on OdooAuthException catch (e) {
        // Bad/expired credentials are a session problem, not an op problem:
        // keep everything pending and surface the real cause.
        await db.bumpOpAttempt(row.id, e.message);
        return const SyncAuthFailed();
      } on OdooRpcException catch (e) {
        // The server refused the op (record changed/deleted underneath us).
        // Surface it instead of overwriting: mark conflict, keep draining.
        await db.markOpConflict(row.id, e.message);
        conflicts++;
      } on DioException catch (e) {
        // Transport problem: keep the op pending and retry later.
        await db.bumpOpAttempt(row.id, e.message ?? e.type.name);
        return const SyncOffline();
      }
    }
    return SyncSuccess(applied: applied, conflicts: conflicts);
  }

  Future<void> _apply(SyncOp op) async {
    switch (op) {
      case SetQuantityOp(:final moveLineId, :final quantity):
        await warehouseApi.setMoveLineQuantity(
          moveLineId: moveLineId,
          quantity: quantity,
        );
      case AddProductLineOp(
        :final pickingId,
        :final productId,
        :final quantity,
        :final localMoveLineId,
      ):
        await warehouseApi.createMoveLine(
          pickingId: pickingId,
          productId: productId,
          quantity: quantity,
        );
        // The server row arrives with the next pull; drop the optimistic
        // local twin so it can't linger alongside it.
        await db.deleteLocalMoveLine(localMoveLineId);
      case ValidatePickingOp(:final pickingId, :final createBackorder):
        await warehouseApi.validatePicking(
          pickingId: pickingId,
          createBackorder: createBackorder,
        );
      case SetLeadStageOp(:final leadId, :final stageId):
        await crmApi.setLeadStage(leadId: leadId, stageId: stageId);
      case LogLeadNoteOp(:final leadId, :final body):
        await crmApi.logNote(leadId: leadId, body: body);
      case CreateLeadOp(
        :final name,
        :final contactName,
        :final phone,
        :final email,
        :final localLeadId,
      ):
        await crmApi.createLead(
          name: name,
          contactName: contactName,
          phone: phone,
          email: email,
        );
        await db.deleteLocalLead(localLeadId);
      case ConfirmSaleOrderOp(:final orderId):
        await salesApi.confirmOrder(orderId: orderId);
    }
  }

  Future<void> _pullWarehouse() async {
    final pickings = await warehouseApi.fetchOpenPickings(
      pickingTypeCode: pickingTypeCode,
    );
    final moveLines = await warehouseApi.fetchMoveLines(
      pickings.map((p) => p.id).toList(),
    );
    final productIds = moveLines.map((l) => l.productId).toSet().toList();
    final products = await warehouseApi.fetchProducts(productIds);
    await db.replaceWorkingSet(
      remotePickings: pickings,
      remoteMoveLines: moveLines,
      remoteProducts: products,
    );
  }

  Future<void> _pullCrm() async {
    final leads = await crmApi.fetchMyOpenLeads();
    final stages = await crmApi.fetchStages();
    await db.replaceCrmWorkingSet(remoteLeads: leads, remoteStages: stages);
  }

  Future<void> _pullSales() async {
    final orders = await salesApi.fetchMyQuotations();
    final lines = await salesApi.fetchOrderLines(
      orders.map((o) => o.id).toList(),
    );
    await db.replaceSalesWorkingSet(remoteOrders: orders, remoteLines: lines);
  }
}
