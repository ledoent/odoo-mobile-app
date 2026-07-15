import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odoo_scanner/data/local/database.dart';
import 'package:odoo_scanner/data/odoo/crm_models.dart';
import 'package:odoo_scanner/data/odoo/models.dart';
import 'package:odoo_scanner/data/odoo/sales_models.dart';
import 'package:odoo_scanner/data/sync/op.dart';
import 'package:odoo_scanner/data/sync/sync_engine.dart';

import 'fakes.dart';

void main() {
  late AppDatabase db;
  late FakeScannerApi api;
  late FakeCrmApi crmApi;
  late FakeSalesApi salesApi;
  late SyncEngine engine;

  setUp(() {
    db = AppDatabase(DatabaseConnection(NativeDatabase.memory()));
    api = FakeScannerApi();
    crmApi = FakeCrmApi();
    salesApi = FakeSalesApi();
    engine = SyncEngine(
      db: db,
      warehouseApi: api,
      crmApi: crmApi,
      salesApi: salesApi,
    );
  });

  tearDown(() => db.close());

  Future<void> enqueue(SyncOp op) =>
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
    final decoded = SyncOp.decode(op.kind, op.encodePayload(), op.uuid);
    expect(decoded, isA<AddProductLineOp>());
    expect((decoded as AddProductLineOp).localMoveLineId, -2);
    expect(decoded.uuid, op.uuid);
  });

  test('CRM and Sales ops route to their module APIs in queue order', () async {
    await enqueue(SetLeadStageOp(leadId: 7, stageId: 3));
    await enqueue(LogLeadNoteOp(leadId: 7, body: 'called'));
    await enqueue(CreateLeadOp(name: 'New lead', localLeadId: -1));
    await enqueue(ConfirmSaleOrderOp(orderId: 42));

    final result = await engine.sync();

    expect(result, isA<SyncSuccess>().having((r) => r.applied, 'applied', 4));
    expect(crmApi.applied, ['stage:7->3', 'note:7:called', 'lead:New lead']);
    expect(salesApi.applied, ['confirm:42']);
  });

  test('CRM/Sales pulls replace their mirrors', () async {
    crmApi.leads = [
      const RemoteLead(
        id: 1,
        name: 'Big deal',
        stageId: 2,
        stageName: 'Qualified',
      ),
    ];
    crmApi.stages = [
      const RemoteCrmStage(id: 2, name: 'Qualified', sequence: 1),
    ];
    salesApi.orders = [
      const RemoteSaleOrder(id: 9, name: 'S00009', state: 'draft'),
    ];
    salesApi.lines = [
      const RemoteSaleOrderLine(
        id: 90,
        orderId: 9,
        description: 'Widget',
        quantity: 2,
        priceSubtotal: 50,
      ),
    ];

    await engine.sync();

    expect((await db.watchLeads().first).single.name, 'Big deal');
    expect((await db.watchCrmStages().first).single.name, 'Qualified');
    expect((await db.watchSaleOrders().first).single.name, 'S00009');
    expect((await db.watchSaleOrderLines(9).first).single.quantity, 2);
  });

  test('a module the server lacks does not break the other pulls', () async {
    salesApi.orders = [
      const RemoteSaleOrder(id: 9, name: 'S00009', state: 'draft'),
    ];
    final failingEngine = SyncEngine(
      db: db,
      warehouseApi: api,
      crmApi: _ThrowingCrmApi(),
      salesApi: salesApi,
    );

    final result = await failingEngine.sync();

    expect(result, isA<SyncSuccess>());
    expect((await db.watchSaleOrders().first).single.name, 'S00009');
  });

  test('conflicted CRM op is surfaced, later sales op still applies', () async {
    await enqueue(SetLeadStageOp(leadId: 7, stageId: 3));
    await enqueue(ConfirmSaleOrderOp(orderId: 42));
    crmApi.nextError = FakeScannerApi.conflict('Lead was deleted');

    final result = await engine.sync();

    expect(
      result,
      isA<SyncSuccess>()
          .having((r) => r.applied, 'applied', 1)
          .having((r) => r.conflicts, 'conflicts', 1),
    );
    expect(salesApi.applied, ['confirm:42']);
  });

  test(
    'auth failure during drain keeps ops pending, reports SyncAuthFailed',
    () async {
      await enqueue(SetQuantityOp(moveLineId: 11, quantity: 3));
      await enqueue(SetQuantityOp(moveLineId: 12, quantity: 1));
      api.nextError = FakeScannerApi.authFailure();

      final result = await engine.sync();

      // Not offline, not a conflict: the user must re-authenticate. Nothing
      // was mass-marked conflict and nothing applied.
      expect(result, isA<SyncAuthFailed>());
      expect(api.applied, isEmpty);
      expect(await db.pendingOps(), hasLength(2));
    },
  );

  test(
    'auth failure during pull reports SyncAuthFailed, not success',
    () async {
      final authEngine = SyncEngine(
        db: db,
        warehouseApi: api,
        crmApi: _AuthFailingCrmApi(),
        salesApi: salesApi,
      );

      expect(await authEngine.sync(), isA<SyncAuthFailed>());
    },
  );

  test('pull preserves unsynced local rows (negative ids)', () async {
    final localLead = await db.insertLocalLead(
      name: 'Walk-in',
      partnerName: '',
      phone: '',
      email: '',
    );
    final localLine = await db.insertLocalMoveLine(
      pickingId: 1,
      productId: 100,
      productName: 'Widget',
      quantity: 1,
    );

    await engine.sync(); // empty server: replaces mirrors

    expect(await db.leadById(localLead), isNotNull);
    expect(await db.moveLineById(localLine), isNotNull);
  });

  test('successful create reconciles away the optimistic local row', () async {
    final localLead = await db.insertLocalLead(
      name: 'Walk-in',
      partnerName: '',
      phone: '',
      email: '',
    );
    await enqueue(CreateLeadOp(name: 'Walk-in', localLeadId: localLead));

    final result = await engine.sync();

    expect(result, isA<SyncSuccess>().having((r) => r.applied, 'applied', 1));
    expect(crmApi.applied, ['lead:Walk-in']);
    // The -1 row is gone; the server row arrives with the next pull.
    expect(await db.leadById(localLead), isNull);
  });
}

class _AuthFailingCrmApi extends FakeCrmApi {
  @override
  Future<List<RemoteLead>> fetchMyOpenLeads() async =>
      throw FakeScannerApi.authFailure();
}

class _ThrowingCrmApi extends FakeCrmApi {
  @override
  Future<List<RemoteLead>> fetchMyOpenLeads() async =>
      throw FakeScannerApi.conflict('crm.lead does not exist');
}
