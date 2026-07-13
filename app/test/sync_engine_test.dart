import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odoo_scanner/data/local/database.dart';
import 'package:odoo_scanner/data/odoo/models.dart';
import 'package:odoo_scanner/data/sync/op.dart';
import 'package:odoo_scanner/data/sync/sync_engine.dart';

import 'fakes.dart';

void main() {
  late AppDatabase db;
  late FakeScannerApi api;
  late SyncEngine engine;

  setUp(() {
    db = AppDatabase(DatabaseConnection(NativeDatabase.memory()));
    api = FakeScannerApi();
    engine = SyncEngine(db: db, api: api);
  });

  tearDown(() => db.close());

  Future<void> enqueue(ScanOp op) =>
      db.enqueueOp(uuid: op.uuid, kind: op.kind, payload: op.encodePayload());

  test('drains queued ops in order and marks them done', () async {
    await enqueue(SetQuantityOp(moveLineId: 11, quantity: 3));
    await enqueue(SetQuantityOp(moveLineId: 11, quantity: 4));
    await enqueue(ValidatePickingOp(pickingId: 5));

    final result = await engine.sync();

    expect(result, isA<SyncSuccess>().having((r) => r.applied, 'applied', 3));
    expect(api.applied, [
      'set:11=3.0',
      'set:11=4.0',
      'validate:5(backorder=true)',
    ]);
    expect(await db.pendingOps(), isEmpty);
  });

  test('transport error keeps op pending for retry (offline-safe)', () async {
    await enqueue(SetQuantityOp(moveLineId: 11, quantity: 3));
    api.nextError = FakeScannerApi.offline();

    final result = await engine.sync();

    expect(result, isA<SyncOffline>());
    final pending = await db.pendingOps();
    expect(pending, hasLength(1));
    expect(pending.single.attempts, 1);

    // Connectivity returns: the same op (same UUID) applies exactly once.
    final retry = await engine.sync();
    expect(retry, isA<SyncSuccess>().having((r) => r.applied, 'applied', 1));
    expect(api.applied, ['set:11=3.0']);
  });

  test(
    'server rejection marks conflict and keeps draining later ops',
    () async {
      await enqueue(SetQuantityOp(moveLineId: 11, quantity: 3));
      await enqueue(SetQuantityOp(moveLineId: 12, quantity: 1));
      api.nextError = FakeScannerApi.conflict('Record was deleted');

      final result = await engine.sync();

      expect(
        result,
        isA<SyncSuccess>()
            .having((r) => r.applied, 'applied', 1)
            .having((r) => r.conflicts, 'conflicts', 1),
      );
      // Second op still went through; first is surfaced, not silently retried.
      expect(api.applied, ['set:12=1.0']);
      expect(await db.pendingOps(), isEmpty);
    },
  );

  test('pull replaces the mirror with the server working set', () async {
    api.pickings = [
      const RemotePicking(
        id: 1,
        name: 'WH/IN/00001',
        state: 'assigned',
        pickingTypeCode: 'incoming',
        partnerName: 'MEAS Instruments',
      ),
    ];
    api.moveLines = [
      const RemoteMoveLine(
        id: 10,
        pickingId: 1,
        productId: 100,
        productName: 'Widget',
        quantity: 2,
        picked: false,
      ),
    ];
    api.products = [
      const RemoteProduct(id: 100, name: 'Widget', barcode: '123456789'),
    ];

    await engine.sync();

    final pickings = await db.watchPickings().first;
    expect(pickings.single.name, 'WH/IN/00001');
    final lines = await db.watchMoveLines(1).first;
    expect(lines.single.quantity, 2);
    expect((await db.productByBarcode('123456789'))?.name, 'Widget');

    // A picking closed on the server disappears from the mirror on next pull.
    api.pickings = [];
    api.moveLines = [];
    await engine.sync();
    expect(await db.watchPickings().first, isEmpty);
  });

  test('op payloads round-trip through the queue encoding', () async {
    final op = AddProductLineOp(
      pickingId: 3,
      productId: 9,
      quantity: 1,
      localMoveLineId: -2,
    );
    final decoded = ScanOp.decode(op.kind, op.encodePayload(), op.uuid);
    expect(decoded, isA<AddProductLineOp>());
    expect((decoded as AddProductLineOp).localMoveLineId, -2);
    expect(decoded.uuid, op.uuid);
  });
}
