// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'router.dart';

/// generated route for
/// [OnboardingScreen]
class OnboardingRoute extends PageRouteInfo<void> {
  const OnboardingRoute({List<PageRouteInfo>? children})
    : super(OnboardingRoute.name, initialChildren: children);

  static const String name = 'OnboardingRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const OnboardingScreen();
    },
  );
}

/// generated route for
/// [PickingDetailScreen]
class PickingDetailRoute extends PageRouteInfo<PickingDetailRouteArgs> {
  PickingDetailRoute({
    Key? key,
    required int pickingId,
    List<PageRouteInfo>? children,
  }) : super(
         PickingDetailRoute.name,
         args: PickingDetailRouteArgs(key: key, pickingId: pickingId),
         initialChildren: children,
       );

  static const String name = 'PickingDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PickingDetailRouteArgs>();
      return PickingDetailScreen(key: args.key, pickingId: args.pickingId);
    },
  );
}

class PickingDetailRouteArgs {
  const PickingDetailRouteArgs({this.key, required this.pickingId});

  final Key? key;

  final int pickingId;

  @override
  String toString() {
    return 'PickingDetailRouteArgs{key: $key, pickingId: $pickingId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PickingDetailRouteArgs) return false;
    return key == other.key && pickingId == other.pickingId;
  }

  @override
  int get hashCode => key.hashCode ^ pickingId.hashCode;
}

/// generated route for
/// [PickingsScreen]
class PickingsRoute extends PageRouteInfo<void> {
  const PickingsRoute({List<PageRouteInfo>? children})
    : super(PickingsRoute.name, initialChildren: children);

  static const String name = 'PickingsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const PickingsScreen();
    },
  );
}

/// generated route for
/// [StartupScreen]
class StartupRoute extends PageRouteInfo<void> {
  const StartupRoute({List<PageRouteInfo>? children})
    : super(StartupRoute.name, initialChildren: children);

  static const String name = 'StartupRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const StartupScreen();
    },
  );
}
