import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../api_service.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildNomadiaAppBar(
        context,
        title: 'Детали заявки',
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
          final request = snapshot.data!;
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
                      Text('Срочность: ${request['urgency']}'),
                      const SizedBox(height: 8),
                      Text('Группа: ${request['vulnerable_group']}'),
                      const SizedBox(height: 8),
                      StatusChip(label: request['status'] as String),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _prioritize,
                child: Text(_loading ? 'Расчёт...' : 'Рассчитать AI-приоритет'),
              ),
            ],
          );
        },
      ),
    );
  }
}
