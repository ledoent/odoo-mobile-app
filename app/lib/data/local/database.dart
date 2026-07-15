import 'package:drift/drift.dart';

import '../odoo/crm_models.dart';
import '../odoo/models.dart';
import '../odoo/sales_models.dart';
import '../sync/op.dart';

part 'database.g.dart';

/// Local mirror of the working set: open pickings for the selected
/// operation type. Rows are replaced wholesale on each pull.
class Pickings extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get state => text()();
  TextColumn get pickingTypeCode => text()();
  TextColumn get partnerName => text().withDefault(const Constant(''))();
  DateTimeColumn get scheduledDate => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class MoveLines extends Table {
  IntColumn get id => integer()();
  IntColumn get pickingId => integer()();
  IntColumn get productId => integer()();
  TextColumn get productName => text().withDefault(const Constant(''))();
  RealColumn get quantity => real().withDefault(const Constant(0))();
  BoolColumn get picked => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class Products extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get barcode => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// CRM mirror: my open opportunities and the pipeline stages.
class Leads extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get partnerName => text().withDefault(const Constant(''))();
  IntColumn get stageId => integer().nullable()();
  TextColumn get stageName => text().withDefault(const Constant(''))();
  RealColumn get expectedRevenue => real().withDefault(const Constant(0))();
  TextColumn get phone => text().withDefault(const Constant(''))();
  TextColumn get email => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}

class CrmStages extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  IntColumn get sequence => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Sales mirror: my open quotations and their lines.
class SaleOrders extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get state => text()();
  TextColumn get partnerName => text().withDefault(const Constant(''))();
  RealColumn get amountTotal => real().withDefault(const Constant(0))();
  DateTimeColumn get dateOrder => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class SaleOrderLines extends Table {
  IntColumn get id => integer()();
  IntColumn get orderId => integer()();
  TextColumn get description => text().withDefault(const Constant(''))();
  RealColumn get quantity => real().withDefault(const Constant(0))();
  RealColumn get priceSubtotal => real().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

enum OpStatus { pending, done, conflict }

/// Outbound operation queue. The UI never writes to Odoo directly: every
/// mutation is appended here (with a client UUID for idempotency) and applied
/// optimistically to the mirror; the sync engine drains it in order.
class OpQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().unique()();
  TextColumn get kind => text()();
  TextColumn get payload => text()(); // JSON-encoded op payload
  TextColumn get status =>
      textEnum<OpStatus>().withDefault(Constant(OpStatus.pending.name))();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(
  tables: [
    Pickings,
    MoveLines,
    Products,
    OpQueue,
    Leads,
    CrmStages,
    SaleOrders,
    SaleOrderLines,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(leads);
        await m.createTable(crmStages);
        await m.createTable(saleOrders);
        await m.createTable(saleOrderLines);
      }
    },
  );

  // ---- Mirror reads ----

  Stream<List<Picking>> watchPickings() => (select(
    pickings,
  )..orderBy([(t) => OrderingTerm.asc(t.scheduledDate)])).watch();

  Stream<List<MoveLine>> watchMoveLines(int pickingId) =>
      (select(moveLines)..where((t) => t.pickingId.equals(pickingId))).watch();

  Future<Product?> productByBarcode(String barcode) => (select(
    products,
  )..where((t) => t.barcode.equals(barcode))).getSingleOrNull();

  Future<MoveLine?> moveLineById(int id) =>
      (select(moveLines)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<MoveLine?> moveLineFor(int pickingId, int productId) =>
      (select(moveLines)
            ..where(
              (t) =>
                  t.pickingId.equals(pickingId) & t.productId.equals(productId),
            )
            ..limit(1))
          .getSingleOrNull();

  Stream<List<Lead>> watchLeads() =>
      (select(leads)..orderBy([
            (t) => OrderingTerm.asc(t.stageId),
            (t) => OrderingTerm.desc(t.expectedRevenue),
          ]))
          .watch();

  Future<Lead?> leadById(int id) =>
      (select(leads)..where((t) => t.id.equals(id))).getSingleOrNull();

  Stream<List<CrmStage>> watchCrmStages() => (select(
    crmStages,
  )..orderBy([(t) => OrderingTerm.asc(t.sequence)])).watch();

  Stream<List<SaleOrder>> watchSaleOrders() => (select(
    saleOrders,
  )..orderBy([(t) => OrderingTerm.desc(t.dateOrder)])).watch();

  Future<SaleOrder?> saleOrderById(int id) =>
      (select(saleOrders)..where((t) => t.id.equals(id))).getSingleOrNull();

  Stream<List<SaleOrderLine>> watchSaleOrderLines(int orderId) =>
      (select(saleOrderLines)..where((t) => t.orderId.equals(orderId))).watch();

  // ---- Mirror writes (sync pull + optimistic updates) ----

  Future<void> replaceWorkingSet({
    required List<RemotePicking> remotePickings,
    required List<RemoteMoveLine> remoteMoveLines,
    required List<RemoteProduct> remoteProducts,
  }) async {
    await batch((b) {
      b.deleteAll(pickings);
      // Preserve optimistic local rows (negative ids): their create op may
      // not have reached the server yet, and wiping them here would lose
      // the operator's work.
      b.deleteWhere(moveLines, (t) => t.id.isBiggerThanValue(0));
      b.insertAll(
        pickings,
        remotePickings.map(
          (p) => PickingsCompanion.insert(
            id: Value(p.id),
            name: p.name,
            state: p.state,
            pickingTypeCode: p.pickingTypeCode,
            partnerName: Value(p.partnerName),
            scheduledDate: Value(p.scheduledDate),
          ),
        ),
      );
      b.insertAll(
        moveLines,
        remoteMoveLines.map(
          (l) => MoveLinesCompanion.insert(
            id: Value(l.id),
            pickingId: l.pickingId,
            productId: l.productId,
            productName: Value(l.productName),
            quantity: Value(l.quantity),
            picked: Value(l.picked),
          ),
        ),
      );
      b.insertAllOnConflictUpdate(
        products,
        remoteProducts.map(
          (p) => ProductsCompanion.insert(
            id: Value(p.id),
            name: p.name,
            barcode: Value(p.barcode),
          ),
        ),
      );
    });
  }

  Future<void> replaceCrmWorkingSet({
    required List<RemoteLead> remoteLeads,
    required List<RemoteCrmStage> remoteStages,
  }) async {
    await batch((b) {
      // Same negative-id preservation as move lines: unsynced quick-adds
      // must survive a pull.
      b.deleteWhere(leads, (t) => t.id.isBiggerThanValue(0));
      b.deleteAll(crmStages);
      b.insertAll(
        leads,
        remoteLeads.map(
          (l) => LeadsCompanion.insert(
            id: Value(l.id),
            name: l.name,
            partnerName: Value(l.partnerName),
            stageId: Value(l.stageId),
            stageName: Value(l.stageName),
            expectedRevenue: Value(l.expectedRevenue),
            phone: Value(l.phone),
            email: Value(l.email),
          ),
        ),
      );
      b.insertAll(
        crmStages,
        remoteStages.map(
          (s) => CrmStagesCompanion.insert(
            id: Value(s.id),
            name: s.name,
            sequence: Value(s.sequence),
          ),
        ),
      );
    });
  }

  Future<void> replaceSalesWorkingSet({
    required List<RemoteSaleOrder> remoteOrders,
    required List<RemoteSaleOrderLine> remoteLines,
  }) async {
    await batch((b) {
      b.deleteAll(saleOrders);
      b.deleteAll(saleOrderLines);
      b.insertAll(
        saleOrders,
        remoteOrders.map(
          (o) => SaleOrdersCompanion.insert(
            id: Value(o.id),
            name: o.name,
            state: o.state,
            partnerName: Value(o.partnerName),
            amountTotal: Value(o.amountTotal),
            dateOrder: Value(o.dateOrder),
          ),
        ),
      );
      b.insertAll(
        saleOrderLines,
        remoteLines.map(
          (l) => SaleOrderLinesCompanion.insert(
            id: Value(l.id),
            orderId: l.orderId,
            description: Value(l.description),
            quantity: Value(l.quantity),
            priceSubtotal: Value(l.priceSubtotal),
          ),
        ),
      );
    });
  }

  Future<void> setLocalLeadStage(int leadId, int stageId, String stageName) =>
      (update(leads)..where((t) => t.id.equals(leadId))).write(
        LeadsCompanion(stageId: Value(stageId), stageName: Value(stageName)),
      );

  /// Next id for an optimistic local-only row: negative so it can never
  /// collide with a server id. The row is deleted once its create op
  /// succeeds (the pull then brings the real server row).
  Future<int> _nextLocalId(
    TableInfo<Table, dynamic> table,
    GeneratedColumn<int> id,
  ) async {
    final minId = await (selectOnly(
      table,
    )..addColumns([id.min()])).map((row) => row.read(id.min())).getSingle();
    return (minId != null && minId < 0 ? minId : 0) - 1;
  }

  Future<int> insertLocalLead({
    required String name,
    required String partnerName,
    required String phone,
    required String email,
    int? stageId,
    String stageName = '',
  }) async {
    final localId = await _nextLocalId(leads, leads.id);
    await into(leads).insert(
      LeadsCompanion.insert(
        id: Value(localId),
        name: name,
        partnerName: Value(partnerName),
        stageId: Value(stageId),
        stageName: Value(stageName),
        phone: Value(phone),
        email: Value(email),
      ),
    );
    return localId;
  }

  Future<void> setLocalSaleOrderState(int orderId, String state) =>
      (update(saleOrders)..where((t) => t.id.equals(orderId))).write(
        SaleOrdersCompanion(state: Value(state)),
      );

  Future<void> setLocalMoveLineQuantity(int moveLineId, double quantity) =>
      (update(moveLines)..where((t) => t.id.equals(moveLineId))).write(
        MoveLinesCompanion(
          quantity: Value(quantity),
          picked: const Value(true),
        ),
      );

  Future<void> deleteLocalLead(int localId) => (delete(
    leads,
  )..where((t) => t.id.equals(localId) & t.id.isSmallerThanValue(0))).go();

  Future<void> deleteLocalMoveLine(int localId) => (delete(
    moveLines,
  )..where((t) => t.id.equals(localId) & t.id.isSmallerThanValue(0))).go();

  Future<int> insertLocalMoveLine({
    required int pickingId,
    required int productId,
    required String productName,
    required double quantity,
  }) async {
    final localId = await _nextLocalId(moveLines, moveLines.id);
    await into(moveLines).insert(
      MoveLinesCompanion.insert(
        id: Value(localId),
        pickingId: pickingId,
        productId: productId,
        productName: Value(productName),
        quantity: Value(quantity),
        picked: const Value(true),
      ),
    );
    return localId;
  }

  Future<void> setLocalPickingState(int pickingId, String state) =>
      (update(pickings)..where((t) => t.id.equals(pickingId))).write(
        PickingsCompanion(state: Value(state)),
      );

  // ---- Op queue ----

  Future<int> enqueue(SyncOp op) =>
      enqueueOp(uuid: op.uuid, kind: op.kind, payload: op.encodePayload());

  Future<int> enqueueOp({
    required String uuid,
    required String kind,
    required String payload,
  }) => into(
    opQueue,
  ).insert(OpQueueCompanion.insert(uuid: uuid, kind: kind, payload: payload));

  Future<List<OpQueueData>> pendingOps() =>
      (select(opQueue)
            ..where((t) => t.status.equals(OpStatus.pending.name))
            ..orderBy([(t) => OrderingTerm.asc(t.id)]))
          .get();

  Stream<int> watchPendingOpCount() {
    final count = opQueue.id.count();
    return (selectOnly(opQueue)
          ..addColumns([count])
          ..where(opQueue.status.equals(OpStatus.pending.name)))
        .map((row) => row.read(count) ?? 0)
        .watchSingle();
  }

  Stream<List<OpQueueData>> watchConflictOps() =>
      (select(opQueue)
            ..where((t) => t.status.equals(OpStatus.conflict.name))
            ..orderBy([(t) => OrderingTerm.asc(t.id)]))
          .watch();

  /// Puts a conflicted op back in line for the next drain.
  Future<void> retryOp(int opId) =>
      (update(opQueue)..where((t) => t.id.equals(opId))).write(
        const OpQueueCompanion(status: Value(OpStatus.pending)),
      );

  /// Drops a conflicted op the operator has decided not to replay.
  Future<void> discardOp(int opId) =>
      (update(opQueue)..where((t) => t.id.equals(opId))).write(
        const OpQueueCompanion(status: Value(OpStatus.done)),
      );

  Future<void> markOpDone(int opId) =>
      (update(opQueue)..where((t) => t.id.equals(opId))).write(
        const OpQueueCompanion(status: Value(OpStatus.done)),
      );

  Future<void> markOpConflict(int opId, String error) =>
      (update(opQueue)..where((t) => t.id.equals(opId))).write(
        OpQueueCompanion(
          status: const Value(OpStatus.conflict),
          lastError: Value(error),
        ),
      );

  Future<void> bumpOpAttempt(int opId, String error) async {
    await customUpdate(
      'UPDATE op_queue SET attempts = attempts + 1, last_error = ? WHERE id = ?',
      variables: [Variable.withString(error), Variable.withInt(opId)],
      updates: {opQueue},
    );
  }
}
