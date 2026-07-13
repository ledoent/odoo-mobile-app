import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'core/providers.dart';
import 'core/router.dart';
import 'core/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: ScannerApp()));
}

class ScannerApp extends ConsumerStatefulWidget {
  const ScannerApp({super.key});

  @override
  ConsumerState<ScannerApp> createState() => _ScannerAppState();
}

class _ScannerAppState extends ConsumerState<ScannerApp> {
  final _router = AppRouter();

  @override
  Widget build(BuildContext context) {
    // Keep the connectivity → sync trigger alive for the app's lifetime.
    ref.watch(connectivitySyncProvider);
    return MaterialApp.router(
      title: 'Odoo Scanner',
      theme: buildScannerTheme(),
      routerConfig: _router.config(),
    );
  }
}
