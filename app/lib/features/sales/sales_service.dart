import '../../data/local/database.dart';
import '../../data/sync/op.dart';

/// Sales mutations: optimistic local update + queued op.
class SalesService {
  SalesService(this._db);

  final AppDatabase _db;

  Future<void> confirmOrder({required int orderId}) async {
    final op = ConfirmSaleOrderOp(orderId: orderId);
    await _db.setLocalSaleOrderState(orderId, 'sale');
    await _db.enqueueOp(
      uuid: op.uuid,
      kind: op.kind,
      payload: op.encodePayload(),
    );
  }
}
