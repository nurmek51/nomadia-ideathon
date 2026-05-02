import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum DemoRoleTab {
  resident('/resident', 'Житель', Icons.home_work_outlined),
  ranger('/ranger', 'Рейнджер', Icons.medical_services_outlined),
  supplier('/supplier', 'Поставщик', Icons.inventory_2_outlined),
  dispatcher('/dispatcher', 'Центр', Icons.hub_outlined);

  const DemoRoleTab(this.route, this.label, this.icon);

  final String route;
  final String label;
  final IconData icon;
}

AppBar buildNomadiaAppBar(
  BuildContext context, {
  required String title,
  String? fallbackRoute,
}) {
  final canPop = Navigator.of(context).canPop() || GoRouter.of(context).canPop();
  final showBack = canPop || fallbackRoute != null;

  return AppBar(
    automaticallyImplyLeading: false,
    title: Text(title),
    leading: showBack
        ? IconButton(
            onPressed: () {
              if (GoRouter.of(context).canPop()) {
                context.pop();
                return;
              }
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
                return;
              }
              if (fallbackRoute != null) {
                context.go(fallbackRoute);
              }
            },
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Назад',
          )
        : null,
  );
}

class RoleBottomNavBar extends StatelessWidget {
  const RoleBottomNavBar({
    super.key,
    required this.current,
  });

  final DemoRoleTab current;

  @override
  Widget build(BuildContext context) {
    const tabs = DemoRoleTab.values;
    return NavigationBar(
      selectedIndex: tabs.indexOf(current),
      onDestinationSelected: (index) {
        final target = tabs[index];
        if (target != current) {
          context.go(target.route);
        }
      },
      destinations: [
        for (final tab in tabs)
          NavigationDestination(
            icon: Icon(tab.icon),
            label: tab.label,
          ),
      ],
    );
  }
}
