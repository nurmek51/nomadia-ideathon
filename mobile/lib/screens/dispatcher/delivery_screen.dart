import 'package:flutter/material.dart';

import '../../api_service.dart';
import '../../widgets/mock_map_card.dart';
import '../../widgets/nomadia_navigation.dart';

class DeliveryScreen extends StatefulWidget {
  const DeliveryScreen({
    super.key,
    required this.requestId,
    required this.deliveryId,
    this.deliveryResult,
  });

  final int requestId;
  final int deliveryId;
  final Map<String, dynamic>? deliveryResult;

  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  late Future<Map<String, dynamic>> _future;
  bool _completing = false;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _future = ApiService.instance.getRequestStatusView(widget.requestId);
  }

  Future<void> _complete() async {
    setState(() => _completing = true);
    try {
      await ApiService.instance.completeDelivery(widget.deliveryId);
      if (!mounted) {
        return;
      }
      setState(() => _completed = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Доставка завершена')),
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
        setState(() => _completing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final delivery = widget.deliveryResult ?? const {};
    return Scaffold(
      appBar: buildNomadiaAppBar(
        context,
        title: 'Доставка запущена',
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

          final status = snapshot.data!;
          final isDelivered = _completed || status['status'] == 'delivered';

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('✓ Заявка создана'),
                      const SizedBox(height: 8),
                      const Text('✓ Приоритет рассчитан'),
                      const SizedBox(height: 8),
                      const Text('✓ Ресурс найден'),
                      const SizedBox(height: 8),
                      const Text('✓ Доставка запущена'),
                      const SizedBox(height: 8),
                      Text('${isDelivered ? '✓' : '○'} Доставлено'),
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
                        _deliveryLine(delivery['delivery_type'] as String?),
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 10),
                      Text('${status['matched_node'] ?? 'Источник'} → Горное село'),
                      const SizedBox(height: 8),
                      Text('ETA: ${delivery['eta_minutes'] ?? status['eta_minutes']} минуты'),
                      const SizedBox(height: 8),
                      Text(
                        'Статус: ${isDelivered ? 'доставлено' : status['current_step'] ?? 'дрон вылетел'}',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              MockMapCard(
                fromLabel: status['matched_node'] as String? ?? 'Аптека Аксу',
                toLabel: 'Горное село',
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: ElevatedButton(
          onPressed: (_completing || _completed) ? null : _complete,
          child: Text(
            _completed
                ? 'Доставка завершена'
                : _completing
                    ? 'Подтверждение...'
                    : 'Отметить как доставлено',
          ),
        ),
      ),
    );
  }
}

String _deliveryLine(String? type) {
  return switch (type) {
    'drone' => 'Drone Medical Line',
    'vehicle' => 'Ground Support Line',
    'ranger_pickup' => 'Ranger Pickup',
    _ => 'External Supply',
  };
}
