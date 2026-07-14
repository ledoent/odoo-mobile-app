import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odoo_scanner/data/local/database.dart';
import 'package:odoo_scanner/data/odoo/crm_models.dart';
import 'package:odoo_scanner/data/odoo/sales_models.dart';
import 'package:odoo_scanner/features/crm/crm_service.dart';
import 'package:odoo_scanner/features/sales/sales_service.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(DatabaseConnection(NativeDatabase.memory()));
    await db.replaceCrmWorkingSet(
      remoteLeads: [
        const RemoteLead(id: 1, name: 'Big deal', stageId: 2, stageName: 'New'),
      ],
      remoteStages: [
        const RemoteCrmStage(id: 2, name: 'New', sequence: 0),
        const RemoteCrmStage(id: 3, name: 'Qualified', sequence: 1),
      ],
    );
    await db.replaceSalesWorkingSet(
      remoteOrders: [
        const RemoteSaleOrder(id: 9, name: 'S00009', state: 'sent'),
      ],
      remoteLines: [],
    );
  });

  tearDown(() => db.close());

  test('setStage updates the mirror and queues one op', () async {
    await CrmService(
      db,
    ).setStage(leadId: 1, stageId: 3, stageName: 'Qualified');

    final lead = await db.leadById(1);
    expect(lead!.stageId, 3);
    expect(lead.stageName, 'Qualified');
    final ops = await db.pendingOps();
    expect(ops.single.kind, 'set_lead_stage');
  });

  test(
    'createLead inserts a local negative-id row and queues the op',
    () async {
      final localId = await CrmService(
        db,
      ).createLead(name: 'Walk-in prospect', phone: '555-0100');

      expect(localId, isNegative);
      final lead = await db.leadById(localId);
      expect(lead!.name, 'Walk-in prospect');
      expect((await db.pendingOps()).single.kind, 'create_lead');
    },
  );

  test('logNote queues without touching the mirror', () async {
    await CrmService(db).logNote(leadId: 1, body: 'Spoke with them');

    expect((await db.pendingOps()).single.kind, 'log_lead_note');
    expect((await db.leadById(1))!.stageId, 2);
  });

  test('confirmOrder flips local state and queues the op', () async {
    await SalesService(db).confirmOrder(orderId: 9);

    expect((await db.saleOrderById(9))!.state, 'sale');
    expect((await db.pendingOps()).single.kind, 'confirm_sale_order');
  });
}
