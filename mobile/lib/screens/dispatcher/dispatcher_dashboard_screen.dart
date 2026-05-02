import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../api_service.dart';
import '../../widgets/emergency_card.dart';
import '../../widgets/metric_card.dart';
import '../../widgets/nomadia_navigation.dart';

class DispatcherDashboardScreen extends StatefulWidget {
  const DispatcherDashboardScreen({super.key});

  @override
  State<DispatcherDashboardScreen> createState() =>
      _DispatcherDashboardScreenState();
}

class _DispatcherDashboardScreenState extends State<DispatcherDashboardScreen> {
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Map<String, dynamic>> _load() async {
    final api = ApiService.instance;
    final dashboard = await api.getDashboard();
    final requests = await api.listRequests();
    requests.sort((a, b) => (b['id'] as int).compareTo(a['id'] as int));
    return {
      'dashboard': dashboard,
      'requests': requests,
    };
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _load();
    });
    await _future;
  }

  Future<void> _resetDemo() async {
    try {
      await ApiService.instance.resetDemo();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Демо сброшено')),
      );
      await _refresh();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildNomadiaAppBar(
        context,
        title: 'Командный центр',
        fallbackRoute: '/',
      ),
      bottomNavigationBar:
          const RoleBottomNavBar(current: DemoRoleTab.dispatcher),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }
          final dashboard = snapshot.data!['dashboard'] as Map<String, dynamic>;
          final requests = snapshot.data!['requests'] as List<dynamic>;
          Map<String, dynamic>? active;
          for (final raw in requests) {
            final request = Map<String, dynamic>.from(raw as Map);
            if (request['status'] != 'delivered') {
              active = request;
              break;
            }
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: MetricCard(
                        label: 'Критические заявки',
                        value: '${dashboard['critical_requests']}',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: MetricCard(
                        label: 'Ожидают решения',
                        value: '${dashboard['pending_requests']}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: MetricCard(
                        label: 'Изолированные сёла',
                        value: '${dashboard['isolated_villages']}',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: MetricCard(
                        label: 'Активные доставки',
                        value: '${dashboard['active_deliveries']}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (active != null)
                  EmergencyCard(
                    title: 'Инсулин нужен пациенту',
                    subtitle: 'Срочная заявка',
                    details: [
                      'Село: ${active['village']}',
                      'Статус: ${active['status']}',
                    ],
                    status: '${active['status']}',
                    actionLabel: 'Открыть заявку',
                    onTap: () => context.push('/dispatcher/request/${active!['id']}'),
                  )
                else
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Нет активных заявок. Создайте демо-заявку из роли жителя.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => context.push('/resident/create'),
                  child: const Text('Создать заявку'),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () => context.push('/ranger/lifepod'),
                  child: const Text('Инвентарь LifePod'),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: _resetDemo,
                  child: const Text('Сбросить демо'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
