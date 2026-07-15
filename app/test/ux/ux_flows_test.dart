import 'package:auto_route/auto_route.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart' hide Provider;
import 'package:odoo_scanner/core/providers.dart';
import 'package:odoo_scanner/core/router.dart';
import 'package:odoo_scanner/data/local/database.dart';
import 'package:odoo_scanner/data/odoo/crm_models.dart';
import 'package:odoo_scanner/data/odoo/models.dart';
import 'package:odoo_scanner/data/odoo/sales_models.dart';
import 'package:odoo_scanner/data/sync/op.dart';

/// UX verification: these tests pump the real screens over a real (in-memory)
/// database and walk the flows an operator performs, asserting what is
/// visible and tappable — the layer unit tests can't see.
void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(DatabaseConnection(NativeDatabase.memory()));
  });

  tearDown(() => db.close());

  // Drift parks cancelled query streams behind a timer (re-subscription
  // cache). Dispose the tree and flush that timer inside the test body —
  // flutter_test checks for pending timers before tearDowns run.
  Future<void> endPump(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  }

  Future<void> pumpApp(WidgetTester tester, PageRouteInfo initial) async {
    final router = AppRouter();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          syncEngineProvider.overrideWithValue(null),
        ],
        child: MaterialApp.router(
          routerConfig: router.config(
            deepLinkBuilder: (_) => DeepLink([initial]),
          ),
        ),
      ),
    );
    // Bounded pumps instead of pumpAndSettle: loading spinners animate
    // forever, so settle-detection can spin while streams hydrate.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
  }

  Future<void> seedCrm() => db.replaceCrmWorkingSet(
    remoteLeads: [
      const RemoteLead(
        id: 1,
        name: 'Big deal',
        partnerName: 'Acme',
        stageId: 2,
        stageName: 'New',
        expectedRevenue: 1200,
      ),
      const RemoteLead(
        id: 2,
        name: 'Bigger deal',
        stageId: 3,
        stageName: 'Qualified',
      ),
    ],
    remoteStages: [
      const RemoteCrmStage(id: 2, name: 'New', sequence: 0),
      const RemoteCrmStage(id: 3, name: 'Qualified', sequence: 1),
    ],
  );

  group('CRM pipeline', () {
    testWidgets('groups leads under their stage headers', (tester) async {
      await seedCrm();
      await pumpApp(tester, const CrmPipelineRoute());

      expect(find.text('New (1)'), findsOneWidget);
      expect(find.text('Qualified (1)'), findsOneWidget);
      expect(find.text('Big deal'), findsOneWidget);

      await endPump(tester);
    });

    testWidgets('server lead opens detail with its stage selected', (
      tester,
    ) async {
      await seedCrm();
      await pumpApp(tester, const CrmPipelineRoute());

      await tester.tap(find.text('Bigger deal'));
      await tester.pumpAndSettle();

      expect(find.text('Stage'), findsOneWidget);
      final qualified = tester.widget<ChoiceChip>(
        find.widgetWithText(ChoiceChip, 'Qualified'),
      );
      expect(qualified.selected, isTrue);
      expect(qualified.onSelected, isNotNull, reason: 'stage move enabled');

      await endPump(tester);
    });

    testWidgets('quick-add shows a tappable pending lead, actions locked', (
      tester,
    ) async {
      await seedCrm();
      await pumpApp(tester, const CrmPipelineRoute());

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'Opportunity *'),
        'Walk-in prospect',
      );
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      // Listed under a truthful header, marked as not-yet-synced.
      expect(find.text('Pending sync (1)'), findsOneWidget);
      final ops = await db.pendingOps();
      expect(ops.single.kind, 'create_lead');

      // Still tappable — detail explains the state instead of a dead row.
      await tester.tap(find.text('Walk-in prospect'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Waiting to sync'), findsOneWidget);
      final chip = tester.widget<ChoiceChip>(
        find.widgetWithText(ChoiceChip, 'New'),
      );
      expect(chip.onSelected, isNull, reason: 'stage move locked until sync');
      final note = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Log a note'),
      );
      expect(note.onPressed, isNull, reason: 'notes locked until sync');

      await endPump(tester);
    });
  });

  group('Sync issues surface', () {
    testWidgets('conflicted op shows a badge; retry re-queues it', (
      tester,
    ) async {
      final op = SetLeadStageOp(leadId: 7, stageId: 3);
      final opId = await db.enqueueOp(
        uuid: op.uuid,
        kind: op.kind,
        payload: op.encodePayload(),
      );
      await db.markOpConflict(opId, 'Lead was deleted on the server');

      await pumpApp(tester, const HomeRoute());

      expect(find.byIcon(Icons.sync_problem), findsOneWidget);
      await tester.tap(find.byIcon(Icons.sync_problem));
      await tester.pumpAndSettle();

      expect(find.text('Move lead stage'), findsOneWidget);
      expect(find.text('Lead was deleted on the server'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();

      final pending = await db.pendingOps();
      expect(pending.single.uuid, op.uuid);

      await endPump(tester);
    });

    testWidgets('discard clears the conflict without replaying it', (
      tester,
    ) async {
      final op = ValidatePickingOp(pickingId: 9);
      final opId = await db.enqueueOp(
        uuid: op.uuid,
        kind: op.kind,
        payload: op.encodePayload(),
      );
      await db.markOpConflict(opId, 'Already validated elsewhere');

      await pumpApp(tester, const HomeRoute());
      await tester.tap(find.byIcon(Icons.sync_problem));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      expect(await db.pendingOps(), isEmpty);
      expect(find.text('No sync issues.'), findsOneWidget);

      await endPump(tester);
    });
  });

  group('Sales', () {
    Future<void> seedSales() => db.replaceSalesWorkingSet(
      remoteOrders: [
        const RemoteSaleOrder(
          id: 9,
          name: 'S00009',
          state: 'sent',
          partnerName: 'Acme',
          amountTotal: 100,
        ),
      ],
      remoteLines: [
        const RemoteSaleOrderLine(
          id: 90,
          orderId: 9,
          description: 'Widget',
          quantity: 2,
          priceSubtotal: 50,
        ),
      ],
    );

    testWidgets('quotation opens and confirm queues the op', (tester) async {
      await seedSales();
      await pumpApp(tester, const QuotationsRoute());

      await tester.tap(find.text('S00009'));
      await tester.pumpAndSettle();
      expect(find.text('Widget'), findsOneWidget);

      await tester.tap(find.text('Confirm order'));
      await tester.pumpAndSettle();
      // Both the page and the dialog have a "Confirm order" FilledButton.
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.widgetWithText(FilledButton, 'Confirm order'),
        ),
      );
      await tester.pumpAndSettle();

      expect((await db.pendingOps()).single.kind, 'confirm_sale_order');
      // Button reflects the optimistic state flip.
      final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Confirmed'),
      );
      expect(button.onPressed, isNull);

      await endPump(tester);
    });
  });

  group('Warehouse scan entry', () {
    Future<void> seedWarehouse() => db.replaceWorkingSet(
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
      ],
    );

    testWidgets('typed barcode increments the line (keyboard wedge path)', (
      tester,
    ) async {
      await seedWarehouse();
      await pumpApp(tester, PickingDetailRoute(pickingId: 1));

      await tester.enterText(find.byType(TextField), '111');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.text('1'), findsOneWidget);
      expect((await db.pendingOps()).single.kind, 'set_quantity');

      await endPump(tester);
    });

    testWidgets('unknown barcode is surfaced, nothing queued', (tester) async {
      await seedWarehouse();
      await pumpApp(tester, PickingDetailRoute(pickingId: 1));

      await tester.enterText(find.byType(TextField), '999');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.textContaining('Unknown barcode'), findsOneWidget);
      expect(await db.pendingOps(), isEmpty);

      await endPump(tester);
    });
  });

  group('Home', () {
    testWidgets('module tiles navigate to their screens', (tester) async {
      await pumpApp(tester, const HomeRoute());

      await tester.tap(find.text('CRM'));
      await tester.pumpAndSettle();
      expect(find.text('My Pipeline'), findsOneWidget);

      await endPump(tester);
    });
  });
}
