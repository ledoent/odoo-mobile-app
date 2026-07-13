import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';

import '../features/onboarding/onboarding_screen.dart';
import '../features/pickings/picking_detail_screen.dart';
import '../features/pickings/pickings_screen.dart';
import '../features/startup/startup_screen.dart';

part 'router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: StartupRoute.page, initial: true),
    AutoRoute(page: OnboardingRoute.page),
    AutoRoute(page: PickingsRoute.page),
    AutoRoute(page: PickingDetailRoute.page),
  ];
}
