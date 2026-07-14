import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../data/local/database.dart';
import '../data/odoo/crm_api.dart';
import '../data/odoo/odoo_client.dart';
import '../data/odoo/sales_api.dart';
import '../data/odoo/scanner_api.dart';
import '../data/sync/sync_engine.dart';
import '../features/crm/crm_service.dart';
import '../features/onboarding/session_repository.dart';
import '../features/sales/sales_service.dart';
import '../features/scan/scan_service.dart';

final sessionRepositoryProvider = Provider<SessionRepository>(
  (ref) => SessionRepository(),
);

/// Loaded once at startup; onboarding invalidates it after saving.
final sessionProvider = FutureProvider<OdooSession?>(
  (ref) => ref.watch(sessionRepositoryProvider).load(),
);

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase(driftDatabase(name: 'odoo_scanner'));
  ref.onDispose(db.close);
  return db;
});

final odooClientProvider = Provider<OdooClient?>((ref) {
  final session = ref.watch(sessionProvider).value;
  if (session == null) return null;
  return OdooClient(
    baseUrl: session.serverUrl,
    db: session.db,
    username: session.username,
    apiKey: session.apiKey,
  );
});

final scannerApiProvider = Provider<ScannerApi?>((ref) {
  final client = ref.watch(odooClientProvider);
  return client == null ? null : JsonRpcScannerApi(client);
});

final crmApiProvider = Provider<CrmApi?>((ref) {
  final client = ref.watch(odooClientProvider);
  return client == null ? null : JsonRpcCrmApi(client);
});

final salesApiProvider = Provider<SalesApi?>((ref) {
  final client = ref.watch(odooClientProvider);
  return client == null ? null : JsonRpcSalesApi(client);
});

final syncEngineProvider = Provider<SyncEngine?>((ref) {
  final warehouseApi = ref.watch(scannerApiProvider);
  final crmApi = ref.watch(crmApiProvider);
  final salesApi = ref.watch(salesApiProvider);
  if (warehouseApi == null || crmApi == null || salesApi == null) return null;
  return SyncEngine(
    db: ref.watch(databaseProvider),
    warehouseApi: warehouseApi,
    crmApi: crmApi,
    salesApi: salesApi,
  );
});

final scanServiceProvider = Provider<ScanService>(
  (ref) => ScanService(ref.watch(databaseProvider)),
);

final crmServiceProvider = Provider<CrmService>(
  (ref) => CrmService(ref.watch(databaseProvider)),
);

final salesServiceProvider = Provider<SalesService>(
  (ref) => SalesService(ref.watch(databaseProvider)),
);

final pendingOpCountProvider = StreamProvider<int>(
  (ref) => ref.watch(databaseProvider).watchPendingOpCount(),
);

/// Kicks a sync whenever connectivity comes back (§6: connectivity drives
/// the sync trigger). Kept alive for the app's lifetime from main().
final connectivitySyncProvider = Provider<void>((ref) {
  final sub = Connectivity().onConnectivityChanged.listen((results) {
    final online = results.any((r) => r != ConnectivityResult.none);
    if (!online) return;
    ref.read(syncEngineProvider)?.sync();
  });
  ref.onDispose(sub.cancel);
});
