import 'dart:io';
import 'dart:ui' as ui;

import 'package:auto_route/auto_route.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart' hide Provider;
import 'package:odoo_scanner/core/providers.dart';
import 'package:odoo_scanner/core/router.dart';
import 'package:odoo_scanner/core/theme.dart';
import 'package:odoo_scanner/data/local/database.dart';
import 'package:odoo_scanner/data/sync/op.dart';

import '../seeds.dart';

/// Renders the real screens over seeded data and writes phone-sized PNGs to
/// build/screenshots/ — the Flutter adaptation of the Playwright per-route
/// capture pattern, used for PR visual evidence. Runs as part of the normal
/// test suite (doubles as a render smoke test); skips silently if the
/// bundled Roboto font isn't available.
void main() {
  final fontDir = Directory(
    '${Platform.environment['FLUTTER_ROOT']}/bin/cache/artifacts/material_fonts',
  );

  late AppDatabase db;

  Future<void> loadFont(String family, String path) async {
    final bytes = await File(path).readAsBytes();
    final loader = FontLoader(family)
      ..addFont(Future.value(ByteData.view(bytes.buffer)));
    await loader.load();
  }

  setUpAll(() async {
    if (!fontDir.existsSync()) return;
    for (final entry in fontDir.listSync()) {
      final name = entry.uri.pathSegments.last;
      if (name.startsWith('Roboto-') && name.endsWith('.ttf')) {
        await loadFont('Roboto', entry.path);
      }
      if (name == 'MaterialIcons-Regular.otf') {
        await loadFont('MaterialIcons', entry.path);
      }
    }
  });

  setUp(() {
    db = AppDatabase(DatabaseConnection(NativeDatabase.memory()));
  });

  tearDown(() => db.close());

  Future<void> capture(
    WidgetTester tester,
    PageRouteInfo route,
    String name, {
    Future<void> Function(WidgetTester)? interact,
  }) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    tester.view.devicePixelRatio = 3.0;
    final shotKey = GlobalKey();
    final router = AppRouter();
    await tester.pumpWidget(
      RepaintBoundary(
        key: shotKey,
        child: ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
            syncEngineProvider.overrideWithValue(null),
          ],
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: buildScannerTheme(),
            routerConfig: router.config(
              deepLinkBuilder: (_) => DeepLink([route]),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
    if (interact != null) await interact(tester);

    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(shotKey),
    );
    await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: 2.0);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final file = File('build/screenshots/$name.png');
      file.parent.createSync(recursive: true);
      file.writeAsBytesSync(bytes!.buffer.asUint8List());
    });

    // Flush drift's stream keep-alive timer before teardown.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await tester.binding.setSurfaceSize(null);
  }

  testWidgets('capture PR screenshots', (tester) async {
    if (!fontDir.existsSync()) {
      markTestSkipped('material_fonts cache not available');
      return;
    }

    await seedCrm(db);
    await seedSales(db);
    await seedWarehouse(db);
    final op = SetLeadStageOp(leadId: 99, stageId: 3);
    final opId = await db.enqueueOp(
      uuid: op.uuid,
      kind: op.kind,
      payload: op.encodePayload(),
    );
    await db.markOpConflict(opId, 'Lead was modified on the server');

    await capture(tester, const HomeRoute(), '01-home');
    await capture(tester, const CrmPipelineRoute(), '02-crm-pipeline');
    await capture(tester, LeadDetailRoute(leadId: 2), '03-lead-detail');
    await capture(tester, const QuotationsRoute(), '04-quotations');
    await capture(
      tester,
      QuotationDetailRoute(orderId: 9),
      '05-quotation-detail',
    );
    await capture(tester, const PickingsRoute(), '06-receipts');
    await capture(
      tester,
      PickingDetailRoute(pickingId: 1),
      '07-receipt-detail',
    );
    await capture(
      tester,
      const HomeRoute(),
      '08-sync-issues',
      interact: (t) async {
        await t.tap(find.byIcon(Icons.sync_problem));
        await t.pump();
        await t.pump(const Duration(milliseconds: 400));
      },
    );
  });
}
