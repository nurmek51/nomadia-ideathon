import 'package:flutter/material.dart';

import '../../api_service.dart';
import '../../widgets/nomadia_navigation.dart';

class SupplierRequestDetailScreen extends StatefulWidget {
  const SupplierRequestDetailScreen({
    super.key,
    required this.requestId,
    this.task,
  });

  final int requestId;
  final Map<String, dynamic>? task;

  @override
  State<SupplierRequestDetailScreen> createState() =>
      _SupplierRequestDetailScreenState();
}

class _SupplierRequestDetailScreenState extends State<SupplierRequestDetailScreen> {
  late Future<Map<String, dynamic>> _future;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Map<String, dynamic>> _load() async {
    final request = await ApiService.instance.getRequest(widget.requestId);
    final status = await ApiService.instance.getRequestStatusView(widget.requestId);
    return {
      'request': request,
      'status': status,
    };
  }

  Future<void> _accept() async {
    setState(() => _submitting = true);
    try {
      await ApiService.instance.supplierAcceptRequest({
        'request_id': widget.requestId,
        'supplier_node': 'Аптека Аксу',
      });
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Аптека подтвердила наличие. Доставка может быть запущена.'),
        ),
      );
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$error')),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildNomadiaAppBar(
        context,
        title: 'Emergency-заявка',
        fallbackRoute: '/supplier',
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
          final request = snapshot.data!['request'] as Map<String, dynamic>;
          final status = snapshot.data!['status'] as Map<String, dynamic>;
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
                        '${request['item']} x1',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 10),
                      Text('Куда: ${request['village']}'),
                      const SizedBox(height: 8),
                      Text('Приоритет: ${status['priority_level'] ?? 'ожидается'}'),
                      const SizedBox(height: 8),
                      Text('Доставка: ${_deliveryLabel(status['delivery_type'] as String?)}'),
                      const SizedBox(height: 8),
                      Text('ETA: ${status['eta_minutes'] ?? 'ожидание'} минуты'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitting ? null : _accept,
                child: Text(_submitting ? 'Подтверждение...' : 'Принять и подготовить'),
              ),
            ],
          );
        },
      ),
    );
  }
}

String _deliveryLabel(String? deliveryType) {
  return switch (deliveryType) {
    'drone' => 'Drone Medical Line',
    'vehicle' => 'Ground Support Line',
    'ranger_pickup' => 'Выдача рейнджером',
    _ => 'External Supply',
  };
}
