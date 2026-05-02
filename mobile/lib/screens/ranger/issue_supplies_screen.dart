import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../api_service.dart';
import '../../widgets/nomadia_navigation.dart';

class IssueSuppliesScreen extends StatefulWidget {
  const IssueSuppliesScreen({super.key});

  @override
  State<IssueSuppliesScreen> createState() => _IssueSuppliesScreenState();
}

class _IssueSuppliesScreenState extends State<IssueSuppliesScreen> {
  final _quantityController = TextEditingController(text: '3');
  final _recipientController = TextEditingController(text: 'Семья #12');
  final _commentController = TextEditingController(text: 'Выдано после паводка');

  String _item = 'food_packs';
  bool _submitting = false;

  @override
  void dispose() {
    _quantityController.dispose();
    _recipientController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      final result = await ApiService.instance.issueInventory({
        'node': 'LifePod — Горное село',
        'item': _item,
        'quantity': int.tryParse(_quantityController.text) ?? 1,
        'request_id': null,
        'recipient': _recipientController.text.trim(),
      });
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] as String)),
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
        title: 'Выдать ресурс',
        fallbackRoute: '/ranger/lifepod',
      ),
      bottomNavigationBar: const NomadiaBottomArea(
        current: DemoRoleTab.ranger,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          DropdownButtonFormField<String>(
            initialValue: _item,
            decoration: const InputDecoration(labelText: 'Ресурс'),
            items: const [
              DropdownMenuItem(value: 'food_packs', child: Text('Сухие пайки')),
              DropdownMenuItem(value: 'water_kits', child: Text('Наборы воды')),
              DropdownMenuItem(value: 'baby_food', child: Text('Детское питание')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _item = value);
              }
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _quantityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Количество'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _recipientController,
            decoration: const InputDecoration(labelText: 'Получатель'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _commentController,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Комментарий'),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _submitting ? null : _submit,
            child: Text(_submitting ? 'Отправка...' : 'Подтвердить выдачу'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
