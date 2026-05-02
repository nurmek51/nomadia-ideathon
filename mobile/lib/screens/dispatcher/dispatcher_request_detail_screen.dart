import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../api_service.dart';
import '../../utils/labels.dart';
import '../../widgets/nomadia_navigation.dart';
import '../../widgets/status_chip.dart';

class DispatcherRequestDetailScreen extends StatefulWidget {
  const DispatcherRequestDetailScreen({
    super.key,
    required this.requestId,
  });

  final int requestId;

  @override
  State<DispatcherRequestDetailScreen> createState() =>
      _DispatcherRequestDetailScreenState();
}

class _DispatcherRequestDetailScreenState
    extends State<DispatcherRequestDetailScreen> {
  late Future<Map<String, dynamic>> _future;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _future = ApiService.instance.getRequest(widget.requestId);
  }

  Future<void> _prioritize() async {
    setState(() => _loading = true);
    try {
      final result = await ApiService.instance.prioritizeRequest(widget.requestId);
      if (!mounted) {
        return;
      }
      context.push('/dispatcher/priority/${widget.requestId}', extra: result);
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

  Future<void> _continueFlow(Map<String, dynamic> request) async {
    final status = normalizeStatusCode(request['status'] as String);
    setState(() => _loading = true);
    try {
      switch (status) {
        case 'created':
        case 'verified':
          await _prioritize();
          return;
        case 'prioritized':
          if (!mounted) {
            return;
          }
          context.push(
            '/dispatcher/priority/${widget.requestId}',
            extra: {
              'request_id': widget.requestId,
              'priority_score': request['priority_score'],
              'priority_level': request['priority_level'],
              'ai_summary': request['ai_summary'] ??
                  'Приоритизация рассчитана и сохранена для этой заявки.',
              'reasons': (request['reasons'] as List<dynamic>?) ?? const [],
              'recommended_action': request['recommended_action'],
            },
          );
          return;
        case 'matched':
          try {
            final match = await ApiService.instance.getRequestMatch(widget.requestId);
            if (!mounted) {
              return;
            }
            context.push('/dispatcher/match/${widget.requestId}', extra: match);
            return;
          } catch (_) {
            final rematched = await ApiService.instance.matchRequest(widget.requestId);
            if (!mounted) {
              return;
            }
            context.push('/dispatcher/match/${widget.requestId}', extra: rematched);
            return;
          }
        case 'supplier_confirmed':
          try {
            final match = await ApiService.instance.getRequestMatch(widget.requestId);
            if (!mounted) {
              return;
            }
            context.push('/dispatcher/match/${widget.requestId}', extra: match);
            return;
          } catch (_) {}
          final delivery = await ApiService.instance.approveDelivery(widget.requestId);
          if (!mounted) {
            return;
          }
          context.push(
            '/dispatcher/delivery/${widget.requestId}/${delivery['delivery_id']}',
            extra: delivery,
          );
          return;
        case 'in_delivery':
        case 'delivered':
          final delivery = await ApiService.instance.getRequestDelivery(widget.requestId);
          if (!mounted) {
            return;
          }
          context.push(
            '/dispatcher/delivery/${widget.requestId}/${delivery['delivery_id']}',
            extra: delivery,
          );
          return;
        default:
          await _prioritize();
      }
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
    return Scaffold(
      appBar: buildNomadiaAppBar(
        context,
        title: 'Детали заявки',
        fallbackRoute: '/dispatcher',
      ),
      bottomNavigationBar: const NomadiaBottomArea(
        current: DemoRoleTab.dispatcher,
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
          final request = snapshot.data!;
          final status = normalizeStatusCode(request['status'] as String);
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
                        '${request['item']}',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 12),
                      Text('Село: ${request['village']}'),
                      const SizedBox(height: 8),
                      Text('Срочность: ${urgencyLabel(request['urgency'] as String)}'),
                      const SizedBox(height: 8),
                      Text(
                        'Группа: ${vulnerableGroupLabel(request['vulnerable_group'] as String)}',
                      ),
                      const SizedBox(height: 8),
                      StatusChip(label: request['status'] as String),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : () => _continueFlow(request),
                child: Text(
                  _loading ? 'Загрузка...' : _primaryActionLabel(status),
                ),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}

String _primaryActionLabel(String status) {
  return switch (status) {
    'created' || 'verified' => 'Рассчитать AI-приоритет',
    'prioritized' => 'Открыть AI-приоритизацию',
    'matched' => 'Продолжить matching',
    'supplier_confirmed' => 'Продолжить к доставке',
    'in_delivery' => 'Открыть доставку',
    'delivered' => 'Открыть завершённую доставку',
    _ => 'Продолжить сценарий',
  };
}
