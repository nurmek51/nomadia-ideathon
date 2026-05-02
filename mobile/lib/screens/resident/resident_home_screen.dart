import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../api_service.dart';
import '../../widgets/nomadia_navigation.dart';
import '../../widgets/status_chip.dart';

class ResidentHomeScreen extends StatefulWidget {
  const ResidentHomeScreen({super.key});

  @override
  State<ResidentHomeScreen> createState() => _ResidentHomeScreenState();
}

class _ResidentHomeScreenState extends State<ResidentHomeScreen> {
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  Future<Map<String, dynamic>> _loadData() async {
    final api = ApiService.instance;
    final credits = await api.getAidCredits('resident_demo');
    Map<String, dynamic>? latest;
    try {
      latest = await api.getLatestResidentRequest('resident_demo');
    } catch (_) {
      latest = null;
    }
    return {
      'credits': credits['credits'] as Map<String, dynamic>,
      'latest': latest,
    };
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _loadData();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildNomadiaAppBar(
        context,
        title: 'Помощь рядом',
        fallbackRoute: '/',
      ),
      bottomNavigationBar: const RoleBottomNavBar(current: DemoRoleTab.resident),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _ErrorState(
              message: '${snapshot.error}',
              onRetry: _refresh,
            );
          }

          final data = snapshot.data!;
          final latest = data['latest'] as Map<String, dynamic>?;
          final credits = data['credits'] as Map<String, dynamic>;

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Нужна помощь?',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Создайте emergency-заявку на еду, воду или медикаменты.',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 18),
                        ElevatedButton(
                          onPressed: () => context.push('/resident/create'),
                          child: const Text('Создать заявку'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: latest == null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Моя последняя заявка',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              const Text('Пока нет созданных заявок.'),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Моя последняя заявка',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _itemLabel(latest['item'] as String),
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              StatusChip(label: latest['status'] as String),
                              const SizedBox(height: 12),
                              Text('ETA: ${latest['eta_minutes'] ?? 'ожидание'}'),
                              const SizedBox(height: 16),
                              OutlinedButton(
                                onPressed: () => context.push(
                                  '/resident/status/${latest['request_id']}',
                                ),
                                child: const Text('Открыть статус'),
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
                          'Aid Credits',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 14),
                        Text('Еда: ${credits['food']} кредитов'),
                        const SizedBox(height: 6),
                        Text('Медицина: ${credits['medicine']} кредитов'),
                        const SizedBox(height: 6),
                        Text('Вода: ${credits['water']} кредитов'),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: () => context.push('/resident/credits'),
                          child: const Text('Показать QR'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => onRetry(),
              child: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }
}

String _itemLabel(String item) {
  return switch (item) {
    'insulin' => 'Инсулин',
    'food_packs' => 'Сухие пайки',
    'water_kits' => 'Наборы воды',
    'antibiotics' => 'Антибиотики',
    'baby_food' => 'Детское питание',
    'fuel_cans' => 'Канистры топлива',
    'medical_kits' => 'Медицинские наборы',
    'solar_lanterns' => 'Солнечные фонари',
    _ => item,
  };
}
