import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odoo_scanner/data/local/database.dart';
import 'package:odoo_scanner/data/odoo/models.dart';
import 'package:odoo_scanner/features/scan/scan_service.dart';

void main() {
  late AppDatabase db;
  late ScanService service;

  setUp(() async {
    db = AppDatabase(DatabaseConnection(NativeDatabase.memory()));
    service = ScanService(db);
    await db.replaceWorkingSet(
      remotePickings: [
        const RemotePicking(
          id: 1,
          name: 'WH/IN/00001',
          state: 'assigned',
          pickingTypeCode: 'incoming',
        ),
      ],
      remoteMoveLines: [
        const RemoteMoveLine(
          id: 10,
          pickingId: 1,
          productId: 100,
          productName: 'Widget',
          quantity: 0,
          picked: false,
        ),
      ],
      remoteProducts: [
        const RemoteProduct(id: 100, name: 'Widget', barcode: '111'),
        const RemoteProduct(id: 200, name: 'Gadget', barcode: '222'),
      ],
    );
  });

  tearDown(() => db.close());

  test(
    'scanning a reserved product increments its line optimistically',
    () async {
      final outcome = await service.scanBarcode(pickingId: 1, barcode: '111');

      expect(
        outcome,
        isA<ScanApplied>()
            .having((o) => o.productName, 'productName', 'Widget')
            .having((o) => o.newQuantity, 'newQuantity', 1),
      );
      final line = await db.moveLineById(10);
      expect(line!.quantity, 1);
      expect(line.picked, isTrue);

      final ops = await db.pendingOps();
      expect(ops.single.kind, 'set_quantity');
    },
  );

  test(
    'double scan queues two absolute-quantity ops (idempotent replay)',
    () async {
      await service.scanBarcode(pickingId: 1, barcode: '111');
      await service.scanBarcode(pickingId: 1, barcode: '111');

      expect((await db.moveLineById(10))!.quantity, 2);
      final ops = await db.pendingOps();
      expect(ops, hasLength(2));
      // Distinct client UUIDs so the server can dedupe retries per op.
      expect(ops.map((o) => o.uuid).toSet(), hasLength(2));
    },
  );

  test(
    'scanning an unreserved product creates a local line with negative id',
    () async {
      final outcome = await service.scanBarcode(pickingId: 1, barcode: '222');

      expect(
        outcome,
        isA<ScanApplied>().having((o) => o.productName, 'name', 'Gadget'),
      );
      final lines = await db.watchMoveLines(1).first;
      final local = lines.singleWhere((l) => l.productId == 200);
      expect(local.id, isNegative);
      expect(local.quantity, 1);

      final ops = await db.pendingOps();
      expect(ops.single.kind, 'add_product_line');
    },
  );

  test('unknown barcode is surfaced, nothing queued', () async {
    final outcome = await service.scanBarcode(pickingId: 1, barcode: '999');

    expect(outcome, isA<ScanUnknownBarcode>());
    expect(await db.pendingOps(), isEmpty);
  });

  test('validate marks the picking done locally and queues the op', () async {
    await service.validate(pickingId: 1);

    final picking = (await db.watchPickings().first).single;
    expect(picking.state, 'done');
    expect((await db.pendingOps()).single.kind, 'validate_picking');
  });
}
