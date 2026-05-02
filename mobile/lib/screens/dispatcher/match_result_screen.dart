import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../api_service.dart';
import '../../widgets/mock_map_card.dart';
import '../../widgets/nomadia_navigation.dart';
import '../../widgets/status_chip.dart';

class MatchResultScreen extends StatefulWidget {
  const MatchResultScreen({
    super.key,
    required this.requestId,
    required this.matchResult,
  });

  final int requestId;
  final Map<String, dynamic> matchResult;

  @override
  State<MatchResultScreen> createState() => _MatchResultScreenState();
}

class _MatchResultScreenState extends State<MatchResultScreen> {
  late Future<Map<String, dynamic>> _future;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _future = ApiService.instance.getInventory();
  }

  Future<void> _approve() async {
    setState(() => _loading = true);
    try {
      final delivery = await ApiService.instance.approveDelivery(widget.requestId);
      if (!mounted) {
        return;
      }
      context.push(
        '/dispatcher/delivery/${widget.requestId}/${delivery['delivery_id']}',
        extra: delivery,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$error')),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final match = widget.matchResult;
    return Scaffold(
      appBar: buildNomadiaAppBar(
        context,
        title: 'Ресурс найден',
        fallbackRoute: '/dispatcher',
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
          final nodes = snapshot.data!['nodes'] as Map<String, dynamic>;
          final lifePod = nodes['LifePod — Горное село'] as Map<String, dynamic>;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        match['matched_node'] as String,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 12),
                      Text('Инсулин доступен: ${match['available_units']} единиц'),
                      const SizedBox(height: 8),
                      Text('Расстояние: ${match['distance_km']} км'),
                      const SizedBox(height: 8),
                      Text('Рекомендуемая доставка: ${_deliveryLabel(match['delivery_type'] as String)}'),
                      const SizedBox(height: 8),
                      Text('ETA: ${match['eta_minutes']} минуты'),
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
                        'LifePod — Горное село',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 10),
                      Text('Инсулин: ${(lifePod['items'] as Map<String, dynamic>)['insulin']} единиц'),
                      const SizedBox(height: 8),
                      const StatusChip(label: 'created'),
                      const SizedBox(height: 10),
                      const Text('Статус: требуется внешняя доставка'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(match['reason'] as String),
                ),
              ),
              const SizedBox(height: 12),
              MockMapCard(
                fromLabel: match['matched_node'] as String,
                toLabel: 'Горное село',
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: ElevatedButton(
          onPressed: _loading ? null : _approve,
          child: Text(_loading ? 'Запуск...' : 'Подтвердить доставку'),
        ),
      ),
    );
  }
}

String _deliveryLabel(String value) {
  return switch (value) {
    'drone' => 'Drone Medical Line',
    'vehicle' => 'Ground Support Line',
    'ranger_pickup' => 'Ranger Pickup',
    _ => 'External Supply',
  };
}
