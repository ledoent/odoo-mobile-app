import 'dart:async';

import 'package:dio/dio.dart';

import '../local/database.dart';
import '../odoo/odoo_client.dart';
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

/// Drains the outbound op queue in order, then refreshes the local mirror.
///
/// Failure policy (§6 of the plan):
/// - transport errors (no network, timeouts) stop the drain — ops stay
///   `pending` and are retried on the next connectivity event;
/// - server rejections mark the op `conflict` and keep draining — the
///   subsequent pull reloads the affected records so the operator re-scans
///   against fresh state instead of the app blindly overwriting.
class SyncEngine {
  SyncEngine({
    required this.db,
    required this.api,
    this.pickingTypeCode = 'incoming',
  });

  final AppDatabase db;
  final ScannerApi api;
  final String pickingTypeCode;

  bool _running = false;

  Future<SyncResult> sync() async {
    if (_running) return const SyncSuccess(applied: 0, conflicts: 0);
    _running = true;
    try {
      final drainResult = await _drainQueue();
      if (drainResult is SyncOffline) return drainResult;
      await _pullWorkingSet();
      return drainResult;
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
      final op = ScanOp.decode(row.kind, row.payload, row.uuid);
      try {
        await _apply(op);
        await db.markOpDone(row.id);
        applied++;
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

  Future<void> _apply(ScanOp op) => switch (op) {
    SetQuantityOp(:final moveLineId, :final quantity) =>
      api.setMoveLineQuantity(moveLineId: moveLineId, quantity: quantity),
    AddProductLineOp(:final pickingId, :final productId, :final quantity) =>
      api.createMoveLine(
        pickingId: pickingId,
        productId: productId,
        quantity: quantity,
      ),
    ValidatePickingOp(:final pickingId, :final createBackorder) =>
      api.validatePicking(
        pickingId: pickingId,
        createBackorder: createBackorder,
      ),
  };

  Future<void> _pullWorkingSet() async {
    final pickings = await api.fetchOpenPickings(
      pickingTypeCode: pickingTypeCode,
    );
    final moveLines = await api.fetchMoveLines(
      pickings.map((p) => p.id).toList(),
    );
    final productIds = moveLines.map((l) => l.productId).toSet().toList();
    final products = await api.fetchProducts(productIds);
    await db.replaceWorkingSet(
      remotePickings: pickings,
      remoteMoveLines: moveLines,
      remoteProducts: products,
    );
  }
}
