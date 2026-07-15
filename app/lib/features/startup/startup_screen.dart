import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/providers.dart';
import '../../core/router.dart';

/// Decides where to land: onboarding when no session is stored, otherwise
/// straight to the pickings list.
@RoutePage()
class StartupScreen extends ConsumerWidget {
  const StartupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(sessionProvider, (_, next) {
      final session = next.value;
      if (next.isLoading) return;
      final router = AutoRouter.of(context);
      if (session == null) {
        router.replaceAll([const OnboardingRoute()]);
      } else {
        router.replaceAll([const HomeRoute()]);
      }
    });
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
