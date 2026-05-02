import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../api_service.dart';
import '../../widgets/emergency_card.dart';
import '../../widgets/metric_card.dart';
import '../../widgets/nomadia_navigation.dart';

class SupplierHomeScreen extends StatefulWidget {
  const SupplierHomeScreen({super.key});

  @override
  State<SupplierHomeScreen> createState() => _SupplierHomeScreenState();
}

class _SupplierHomeScreenState extends State<SupplierHomeScreen> {
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Map<String, dynamic>> _load() async {
    final api = ApiService.instance;
    final tasks = await api.getSupplierTasks(supplierNode: 'Аптека Аксу');
    final inventory = await api.getInventory();
    return {
      'tasks': tasks,
      'inventory': inventory['nodes'] as Map<String, dynamic>,
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
        title: 'Аптека Аксу',
        fallbackRoute: '/',
      ),
      bottomNavigationBar: const RoleBottomNavBar(current: DemoRoleTab.supplier),
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
          final tasks = data['tasks'] as List<dynamic>;
          final inventory = data['inventory'] as Map<String, dynamic>;
          final pharmacy = inventory['Аптека Аксу'] as Map<String, dynamic>;
          final lowStockCount = (pharmacy['items'] as Map<String, dynamic>).values
              .where((value) => (value as int) <= 2)
              .length;

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Статус: подключено к Nomadia',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: MetricCard(
                        label: 'Emergency-заявки',
                        value: '${tasks.length}',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: MetricCard(
                        label: 'Низкие остатки',
                        value: '$lowStockCount',
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: MetricCard(
                        label: 'Ожидает компенсации',
                        value: '42 000 ₸',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (tasks.isNotEmpty)
                  EmergencyCard(
                    title: 'Инсулин x1',
                    subtitle: 'Запрос от диспетчера',
                    details: const [
                      'Куда: Горное село',
                      'Доставка: Drone Medical Line',
                    ],
                    status: '${tasks.first['status']}',
                    actionLabel: 'Открыть',
                    onTap: () => context.push(
                      '/supplier/task/${tasks.first['request_id']}',
                      extra: Map<String, dynamic>.from(tasks.first as Map),
                    ),
                  )
                else
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Пока нет новых emergency-заявок. Сначала выполните matching у диспетчера.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => context.push('/supplier/inventory'),
                  child: const Text('Обновить запасы'),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: tasks.isEmpty
                      ? null
                      : () => context.push(
                            '/supplier/task/${tasks.first['request_id']}',
                            extra: Map<String, dynamic>.from(tasks.first as Map),
                          ),
                  child: const Text('Принять заявку'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
