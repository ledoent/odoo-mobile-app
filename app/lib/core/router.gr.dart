// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'router.dart';

/// generated route for
/// [CrmPipelineScreen]
class CrmPipelineRoute extends PageRouteInfo<void> {
  const CrmPipelineRoute({List<PageRouteInfo>? children})
    : super(CrmPipelineRoute.name, initialChildren: children);

  static const String name = 'CrmPipelineRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CrmPipelineScreen();
    },
  );
}

/// generated route for
/// [HomeScreen]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HomeScreen();
    },
  );
}

/// generated route for
/// [LeadDetailScreen]
class LeadDetailRoute extends PageRouteInfo<LeadDetailRouteArgs> {
  LeadDetailRoute({
    Key? key,
    required int leadId,
    List<PageRouteInfo>? children,
  }) : super(
         LeadDetailRoute.name,
         args: LeadDetailRouteArgs(key: key, leadId: leadId),
         initialChildren: children,
       );

  static const String name = 'LeadDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<LeadDetailRouteArgs>();
      return LeadDetailScreen(key: args.key, leadId: args.leadId);
    },
  );
}

class LeadDetailRouteArgs {
  const LeadDetailRouteArgs({this.key, required this.leadId});

  final Key? key;

  final int leadId;

  @override
  String toString() {
    return 'LeadDetailRouteArgs{key: $key, leadId: $leadId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LeadDetailRouteArgs) return false;
    return key == other.key && leadId == other.leadId;
  }

  @override
  int get hashCode => key.hashCode ^ leadId.hashCode;
}

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
/// [QuotationDetailScreen]
class QuotationDetailRoute extends PageRouteInfo<QuotationDetailRouteArgs> {
  QuotationDetailRoute({
    Key? key,
    required int orderId,
    List<PageRouteInfo>? children,
  }) : super(
         QuotationDetailRoute.name,
         args: QuotationDetailRouteArgs(key: key, orderId: orderId),
         initialChildren: children,
       );

  static const String name = 'QuotationDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<QuotationDetailRouteArgs>();
      return QuotationDetailScreen(key: args.key, orderId: args.orderId);
    },
  );
}

class QuotationDetailRouteArgs {
  const QuotationDetailRouteArgs({this.key, required this.orderId});

  final Key? key;

  final int orderId;

  @override
  String toString() {
    return 'QuotationDetailRouteArgs{key: $key, orderId: $orderId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! QuotationDetailRouteArgs) return false;
    return key == other.key && orderId == other.orderId;
  }

  @override
  int get hashCode => key.hashCode ^ orderId.hashCode;
}

/// generated route for
/// [QuotationsScreen]
class QuotationsRoute extends PageRouteInfo<void> {
  const QuotationsRoute({List<PageRouteInfo>? children})
    : super(QuotationsRoute.name, initialChildren: children);

  static const String name = 'QuotationsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const QuotationsScreen();
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
