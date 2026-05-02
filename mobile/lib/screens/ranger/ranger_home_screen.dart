import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../api_service.dart';
import '../../utils/labels.dart';
import '../../widgets/emergency_card.dart';
import '../../widgets/metric_card.dart';
import '../../widgets/nomadia_navigation.dart';

class RangerHomeScreen extends StatefulWidget {
  const RangerHomeScreen({super.key});

  @override
  State<RangerHomeScreen> createState() => _RangerHomeScreenState();
}

class _RangerHomeScreenState extends State<RangerHomeScreen> {
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Map<String, dynamic>> _load() async {
    final api = ApiService.instance;
    final requests = await api.listRequests(status: 'created', village: 'Горное село');
    final inventory = await api.getInventory();
    final state = await api.getDemoState();
    return {
      'requests': requests,
      'inventory': inventory['nodes'] as Map<String, dynamic>,
      'issueLogs': state['issue_logs'] as List<dynamic>,
    };
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _load();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildNomadiaAppBar(
        context,
        title: 'Рейнджер Nomadia',
        fallbackRoute: '/',
      ),
      bottomNavigationBar: const RoleBottomNavBar(current: DemoRoleTab.ranger),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }
          final data = snapshot.data!;
          final requests = data['requests'] as List<dynamic>;
          final inventory = data['inventory'] as Map<String, dynamic>;
          final lifepod = inventory['LifePod — Горное село'] as Map<String, dynamic>;
          final warnings = (lifepod['items'] as Map<String, dynamic>).values
              .where((value) => (value as int) <= 8)
              .length;
          final issueLogs = data['issueLogs'] as List<dynamic>;

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: MetricCard(
                        label: 'Новые заявки',
                        value: '${requests.length}',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: MetricCard(
                        label: 'LifePod warnings',
                        value: '$warnings',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: MetricCard(
                        label: 'Выдано сегодня',
                        value: '${issueLogs.length}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (requests.isNotEmpty)
                  EmergencyCard(
                    title: 'Инсулин нужен пациенту',
                    subtitle: 'Требует подтверждения',
                    details: const [
                      'Село: Горное село',
                      'Группа: хронический пациент',
                    ],
                    status: statusLabel('created'),
                    actionLabel: 'Проверить заявку',
                    onTap: () => context.push('/ranger/verify/${requests.first['id']}'),
                  )
                else
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Новых заявок нет. Создайте демо-заявку из роли жителя.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => context.push('/ranger/lifepod'),
                  child: const Text('Инвентарь LifePod'),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () => context.push('/resident/create'),
                  child: const Text('Создать заявку за жителя'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
