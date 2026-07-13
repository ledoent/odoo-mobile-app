import '../../data/local/database.dart';
import '../../data/sync/op.dart';

sealed class ScanOutcome {
  const ScanOutcome();
}

class ScanApplied extends ScanOutcome {
  const ScanApplied({required this.productName, required this.newQuantity});

  final String productName;
  final double newQuantity;
}

class ScanUnknownBarcode extends ScanOutcome {
  const ScanUnknownBarcode(this.barcode);

  final String barcode;
}

/// Turns a scanned barcode into an optimistic local update plus a queued op.
/// Never talks to Odoo directly — the sync engine owns the network.
class ScanService {
  ScanService(this._db);

  final AppDatabase _db;

  Future<ScanOutcome> scanBarcode({
    required int pickingId,
    required String barcode,
  }) async {
    final product = await _db.productByBarcode(barcode.trim());
    if (product == null) {
      return ScanUnknownBarcode(barcode.trim());
    }

    final line = await _db.moveLineFor(pickingId, product.id);
    if (line != null && line.id > 0) {
      final newQty = line.quantity + 1;
      final op = SetQuantityOp(moveLineId: line.id, quantity: newQty);
      await _db.setLocalMoveLineQuantity(line.id, newQty);
      await _db.enqueueOp(
        uuid: op.uuid,
        kind: op.kind,
        payload: op.encodePayload(),
      );
      return ScanApplied(productName: product.name, newQuantity: newQty);
    }

    if (line != null) {
      // Line only exists locally (created by a previous offline scan of an
      // unreserved product): bump the mirror and queue an absolute-set op is
      // not possible yet (no server id), so re-queue a create with the total.
      final newQty = line.quantity + 1;
      await _db.setLocalMoveLineQuantity(line.id, newQty);
      final op = AddProductLineOp(
        pickingId: pickingId,
        productId: product.id,
        quantity: 1,
        localMoveLineId: line.id,
      );
      await _db.enqueueOp(
        uuid: op.uuid,
        kind: op.kind,
        payload: op.encodePayload(),
      );
      return ScanApplied(productName: product.name, newQuantity: newQty);
    }

    // Product not on the picking at all: create an optimistic local line.
    final localId = await _db.insertLocalMoveLine(
      pickingId: pickingId,
      productId: product.id,
      productName: product.name,
      quantity: 1,
    );
    final op = AddProductLineOp(
      pickingId: pickingId,
      productId: product.id,
      quantity: 1,
      localMoveLineId: localId,
    );
    await _db.enqueueOp(
      uuid: op.uuid,
      kind: op.kind,
      payload: op.encodePayload(),
    );
    return ScanApplied(productName: product.name, newQuantity: 1);
  }

  Future<void> validate({
    required int pickingId,
    bool createBackorder = true,
  }) async {
    final op = ValidatePickingOp(
      pickingId: pickingId,
      createBackorder: createBackorder,
    );
    await _db.setLocalPickingState(pickingId, 'done');
    await _db.enqueueOp(
      uuid: op.uuid,
      kind: op.kind,
      payload: op.encodePayload(),
    );
  }
}
