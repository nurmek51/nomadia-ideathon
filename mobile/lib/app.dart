import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'screens/dispatcher/delivery_screen.dart';
import 'screens/dispatcher/dispatcher_dashboard_screen.dart';
import 'screens/dispatcher/dispatcher_request_detail_screen.dart';
import 'screens/dispatcher/match_result_screen.dart';
import 'screens/dispatcher/priority_result_screen.dart';
import 'screens/ranger/issue_supplies_screen.dart';
import 'screens/ranger/lifepod_inventory_screen.dart';
import 'screens/ranger/ranger_home_screen.dart';
import 'screens/ranger/ranger_verify_request_screen.dart';
import 'screens/resident/aid_credits_screen.dart';
import 'screens/resident/resident_create_request_screen.dart';
import 'screens/resident/resident_home_screen.dart';
import 'screens/resident/resident_request_status_screen.dart';
import 'screens/role_select_screen.dart';
import 'screens/supplier/supplier_home_screen.dart';
import 'screens/supplier/supplier_inventory_screen.dart';
import 'screens/supplier/supplier_request_detail_screen.dart';
import 'theme.dart';

class NomadiaApp extends StatelessWidget {
  const NomadiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Nomadia',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: _router,
    );
  }
}

final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (context, state) => const RoleSelectScreen(),
    ),
    GoRoute(
      path: '/resident',
      builder: (context, state) => const ResidentHomeScreen(),
    ),
    GoRoute(
      path: '/resident/create',
      builder: (context, state) => const ResidentCreateRequestScreen(),
    ),
    GoRoute(
      path: '/resident/status/:id',
      builder: (context, state) => ResidentRequestStatusScreen(
        requestId: int.parse(state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/resident/credits',
      builder: (context, state) => const AidCreditsScreen(),
    ),
    GoRoute(
      path: '/ranger',
      builder: (context, state) => const RangerHomeScreen(),
    ),
    GoRoute(
      path: '/ranger/verify/:id',
      builder: (context, state) => RangerVerifyRequestScreen(
        requestId: int.parse(state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/ranger/lifepod',
      builder: (context, state) => const LifePodInventoryScreen(),
    ),
    GoRoute(
      path: '/ranger/issue',
      builder: (context, state) => const IssueSuppliesScreen(),
    ),
    GoRoute(
      path: '/supplier',
      builder: (context, state) => const SupplierHomeScreen(),
    ),
    GoRoute(
      path: '/supplier/inventory',
      builder: (context, state) => const SupplierInventoryScreen(),
    ),
    GoRoute(
      path: '/supplier/task/:id',
      builder: (context, state) => SupplierRequestDetailScreen(
        requestId: int.parse(state.pathParameters['id']!),
        task: state.extra as Map<String, dynamic>?,
      ),
    ),
    GoRoute(
      path: '/dispatcher',
      builder: (context, state) => const DispatcherDashboardScreen(),
    ),
    GoRoute(
      path: '/dispatcher/request/:id',
      builder: (context, state) => DispatcherRequestDetailScreen(
        requestId: int.parse(state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/dispatcher/priority/:id',
      builder: (context, state) => PriorityResultScreen(
        requestId: int.parse(state.pathParameters['id']!),
        result: state.extra as Map<String, dynamic>,
      ),
    ),
    GoRoute(
      path: '/dispatcher/match/:id',
      builder: (context, state) => MatchResultScreen(
        requestId: int.parse(state.pathParameters['id']!),
        matchResult: state.extra as Map<String, dynamic>,
      ),
    ),
    GoRoute(
      path: '/dispatcher/delivery/:requestId/:deliveryId',
      builder: (context, state) => DeliveryScreen(
        requestId: int.parse(state.pathParameters['requestId']!),
        deliveryId: int.parse(state.pathParameters['deliveryId']!),
        deliveryResult: state.extra as Map<String, dynamic>?,
      ),
    ),
  ],
);
