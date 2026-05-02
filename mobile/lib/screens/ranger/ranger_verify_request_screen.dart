import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../api_service.dart';
import '../../widgets/nomadia_navigation.dart';

class RangerVerifyRequestScreen extends StatefulWidget {
  const RangerVerifyRequestScreen({
    super.key,
    required this.requestId,
  });

  final int requestId;

  @override
  State<RangerVerifyRequestScreen> createState() =>
      _RangerVerifyRequestScreenState();
}

class _RangerVerifyRequestScreenState extends State<RangerVerifyRequestScreen> {
  late Future<Map<String, dynamic>> _future;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _future = ApiService.instance.getRequest(widget.requestId);
  }

  Future<void> _verify() async {
    setState(() => _submitting = true);
    try {
      await ApiService.instance.verifyRequest(widget.requestId);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заявка подтверждена рейнджером')),
      );
      context.go('/ranger');
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
        title: 'Проверка заявки',
        fallbackRoute: '/ranger',
      ),
      bottomNavigationBar: const NomadiaBottomArea(
        current: DemoRoleTab.ranger,
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
                      Text('Предмет: ${request['item']}'),
                      const SizedBox(height: 8),
                      Text('Срочность: ${_urgencyLabel(request['urgency'] as String)}'),
                      const SizedBox(height: 8),
                      Text('Пациент: ${_groupLabel(request['vulnerable_group'] as String)}'),
                      const SizedBox(height: 8),
                      Text('Село: ${request['village']}'),
                      const SizedBox(height: 8),
                      Text('Описание: ${request['description']}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('✓ Заявка от местного жителя'),
                      SizedBox(height: 8),
                      Text('✓ Медицинская потребность подтверждена'),
                      SizedBox(height: 8),
                      Text('✓ Локальный запас проверен'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitting ? null : _verify,
                child: Text(_submitting ? 'Подтверждение...' : 'Подтвердить заявку'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => context.go('/ranger'),
                child: const Text('Отклонить'),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}

String _urgencyLabel(String value) {
  return switch (value) {
    'critical' => 'Критическая',
    'high' => 'Высокая',
    'medium' => 'Средняя',
    _ => 'Низкая',
  };
}

String _groupLabel(String value) {
  return switch (value) {
    'chronic_patient' => 'хроническое заболевание',
    'elderly' => 'пожилой',
    'pregnant' => 'беременная',
    'child' => 'ребёнок',
    _ => 'нет',
  };
}
