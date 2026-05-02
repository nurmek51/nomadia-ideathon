import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme.dart';

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
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          top: BorderSide(color: AppTheme.line, width: 1.1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(
            children: [
              for (final tab in tabs)
                Expanded(
                  child: _NavTabButton(
                    tab: tab,
                    selected: tab == current,
                    onTap: () {
                      if (tab != current) {
                        context.go(tab.route);
                      }
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class NomadiaBottomArea extends StatelessWidget {
  const NomadiaBottomArea({
    super.key,
    required this.current,
    this.topChild,
  });

  final DemoRoleTab current;
  final Widget? topChild;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.background,
        border: Border(
          top: BorderSide(color: AppTheme.line, width: 1.1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (topChild != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: topChild!,
            ),
          RoleBottomNavBar(current: current),
        ],
      ),
    );
  }
}

class _NavTabButton extends StatelessWidget {
  const _NavTabButton({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  final DemoRoleTab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
          color: AppTheme.ink,
        );

    return Material(
      color: selected ? AppTheme.surfaceMuted : AppTheme.surface,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              right: tab != DemoRoleTab.values.last
                  ? const BorderSide(color: AppTheme.line, width: 1.1)
                  : BorderSide.none,
              top: selected
                  ? const BorderSide(color: AppTheme.primary, width: 3)
                  : BorderSide.none,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(tab.icon, size: 20, color: AppTheme.ink),
              const SizedBox(height: 6),
              Text(
                tab.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
