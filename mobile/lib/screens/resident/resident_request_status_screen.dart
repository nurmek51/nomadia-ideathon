import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../api_service.dart';
import '../../widgets/mock_map_card.dart';
import '../../widgets/nomadia_navigation.dart';
import '../../widgets/status_chip.dart';

class ResidentRequestStatusScreen extends StatefulWidget {
  const ResidentRequestStatusScreen({
    super.key,
    required this.requestId,
  });

  final int requestId;

  @override
  State<ResidentRequestStatusScreen> createState() =>
      _ResidentRequestStatusScreenState();
}

class _ResidentRequestStatusScreenState
    extends State<ResidentRequestStatusScreen> {
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService.instance.getRequestStatusView(widget.requestId);
  }

  Future<void> _reload() async {
    setState(() {
      _future = ApiService.instance.getRequestStatusView(widget.requestId);
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildNomadiaAppBar(
        context,
        title: 'Статус заявки',
        fallbackRoute: '/resident',
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }

          final statusView = snapshot.data!;
          final route = (statusView['route'] as List<dynamic>?) ?? [];

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _itemLabel(statusView['item'] as String),
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 12),
                        StatusChip(label: statusView['status'] as String),
                        const SizedBox(height: 16),
                        ..._timeline(statusView['status'] as String),
                        const SizedBox(height: 16),
                        Text('ETA: ${statusView['eta_minutes'] ?? 'ожидание'} минуты'),
                        const SizedBox(height: 8),
                        Text(
                          statusView['current_step'] as String? ??
                              'Заявка ожидает следующего шага оператора.',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Система нашла ближайший доступный запас в ${statusView['matched_node'] ?? 'локальном узле'}.',
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Доставка выполняется через ${_deliveryLabel(statusView['delivery_type'] as String?)}.',
                        ),
                      ],
                    ),
                  ),
                ),
                if (route.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  MockMapCard(
                    fromLabel: statusView['matched_node'] as String? ?? 'Источник',
                    toLabel: 'Горное село',
                  ),
                ],
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: () => context.go('/resident'),
                  child: const Text('Вернуться на главную'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _timeline(String status) {
    const ordered = [
      'created',
      'prioritized',
      'matched',
      'in_delivery',
      'delivered',
    ];
    final currentIndex = ordered.indexOf(status);
    return List.generate(
      ordered.length,
      (index) {
        final done = currentIndex >= index || (status == 'verified' && index == 0);
        final label = switch (ordered[index]) {
          'created' => 'Заявка создана',
          'prioritized' => 'Приоритет рассчитан',
          'matched' => 'Ресурс найден',
          'in_delivery' => 'Доставка запущена',
          _ => 'Доставлено',
        };
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text('${done ? '✓' : '○'} $label'),
        );
      },
    );
  }
}

String _deliveryLabel(String? value) {
  return switch (value) {
    'drone' => 'Drone Medical Line',
    'vehicle' => 'Ground Support Line',
    'ranger_pickup' => 'выдачу через рейнджера',
    'external_supply' => 'внешнюю поставку',
    _ => 'операционную цепочку Nomadia',
  };
}

String _itemLabel(String item) {
  return switch (item) {
    'insulin' => 'Инсулин',
    _ => item,
  };
}
