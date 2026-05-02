import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../api_service.dart';
import '../../utils/labels.dart';
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
    _future = _load();
  }

  Future<Map<String, dynamic>> _load() async {
    final inventory = await ApiService.instance.getInventory();
    final status = await ApiService.instance.getRequestStatusView(widget.requestId);
    return {
      'inventory': inventory,
      'status': status,
    };
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _load();
    });
    await _future;
  }

  bool _waitingForSupplierConfirmation(Map<String, dynamic> status, Map<String, dynamic> match) {
    final requestStatus = status['status'] as String;
    final matchedNode = match['matched_node'] as String;
    final deliveryType = match['delivery_type'] as String;
    return requestStatus == 'matched' &&
        matchedNode != 'LifePod — Горное село' &&
        matchedNode != 'Внешний склад' &&
        deliveryType != 'ranger_pickup';
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
      await _refresh();
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
          final data = snapshot.data!;
          final nodes = data['inventory']['nodes'] as Map<String, dynamic>;
          final requestStatus = data['status'] as Map<String, dynamic>;
          final lifePod = nodes['LifePod — Горное село'] as Map<String, dynamic>;
          final waitingForSupplier = _waitingForSupplierConfirmation(requestStatus, match);

          return RefreshIndicator(
            onRefresh: _refresh,
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
                          match['matched_node'] as String,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 12),
                        Text('Инсулин доступен: ${match['available_units']} единиц'),
                        const SizedBox(height: 8),
                        Text('Расстояние: ${match['distance_km']} км'),
                        const SizedBox(height: 8),
                        Text(
                          'Рекомендуемая доставка: ${_deliveryLabel(match['delivery_type'] as String)}',
                        ),
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
                        Text(
                          'Инсулин: ${(lifePod['items'] as Map<String, dynamic>)['insulin']} единиц',
                        ),
                        const SizedBox(height: 8),
                        StatusChip(label: requestStatus['status'] as String),
                        const SizedBox(height: 10),
                        Text(
                          waitingForSupplier
                              ? 'Статус: ожидается подтверждение поставщика'
                              : 'Статус: маршрут готов к запуску',
                        ),
                      ],
                    ),
                  ),
                ),
                if (waitingForSupplier) ...[
                  const SizedBox(height: 12),
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Сначала поставщик должен подтвердить наличие ресурса. Откройте роль поставщика, примите заявку и затем обновите этот экран.',
                      ),
                    ),
                  ),
                ],
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
            ),
          );
        },
      ),
      bottomNavigationBar: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          final status = snapshot.data?['status'] as Map<String, dynamic>?;
          final waitingForSupplier = status == null
              ? false
              : _waitingForSupplierConfirmation(status, widget.matchResult);
          return NomadiaBottomArea(
            current: DemoRoleTab.dispatcher,
            topChild: ElevatedButton(
              onPressed: (_loading || waitingForSupplier) ? null : _approve,
              child: Text(
                waitingForSupplier
                    ? 'Ожидание подтверждения поставщика'
                    : _loading
                        ? 'Запуск...'
                        : 'Подтвердить доставку',
              ),
            ),
          );
        },
      ),
    );
  }
}

String _deliveryLabel(String value) {
  return deliveryTypeLabel(value);
}
