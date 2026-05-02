import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../api_service.dart';
import '../../widgets/nomadia_navigation.dart';

class ResidentCreateRequestScreen extends StatefulWidget {
  const ResidentCreateRequestScreen({super.key});

  @override
  State<ResidentCreateRequestScreen> createState() =>
      _ResidentCreateRequestScreenState();
}

class _ResidentCreateRequestScreenState extends State<ResidentCreateRequestScreen> {
  final _itemController = TextEditingController(text: 'insulin');
  final _descriptionController =
      TextEditingController(text: 'Пациенту срочно нужен инсулин');

  String _category = 'medicine';
  String _urgency = 'critical';
  String _group = 'chronic_patient';
  String _village = 'Горное село';
  bool _submitting = false;

  @override
  void dispose() {
    _itemController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      final created = await ApiService.instance.createRequest({
        'category': _category,
        'item': _itemController.text.trim(),
        'urgency': _urgency,
        'vulnerable_group': _group,
        'village': _village,
        'description': _descriptionController.text.trim(),
        'created_by_role': 'resident',
      });
      if (!mounted) {
        return;
      }
      context.go('/resident/status/${created['id']}');
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
        title: 'Новая заявка',
        fallbackRoute: '/resident',
      ),
      bottomNavigationBar: const NomadiaBottomArea(
        current: DemoRoleTab.resident,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _Section(
            title: 'Что нужно?',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ChoiceChip(
                  label: 'Еда',
                  value: 'food',
                  groupValue: _category,
                  onSelected: (value) => setState(() => _category = value),
                ),
                _ChoiceChip(
                  label: 'Вода',
                  value: 'water',
                  groupValue: _category,
                  onSelected: (value) => setState(() => _category = value),
                ),
                _ChoiceChip(
                  label: 'Медицина',
                  value: 'medicine',
                  groupValue: _category,
                  onSelected: (value) => setState(() => _category = value),
                ),
                _ChoiceChip(
                  label: 'Детские товары',
                  value: 'baby',
                  groupValue: _category,
                  onSelected: (value) => setState(() => _category = value),
                ),
                _ChoiceChip(
                  label: 'Топливо',
                  value: 'fuel',
                  groupValue: _category,
                  onSelected: (value) => setState(() => _category = value),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _itemController,
            decoration: const InputDecoration(labelText: 'Предмет'),
          ),
          const SizedBox(height: 16),
          _Section(
            title: 'Срочность',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ChoiceChip(
                  label: 'Низкая',
                  value: 'low',
                  groupValue: _urgency,
                  onSelected: (value) => setState(() => _urgency = value),
                ),
                _ChoiceChip(
                  label: 'Средняя',
                  value: 'medium',
                  groupValue: _urgency,
                  onSelected: (value) => setState(() => _urgency = value),
                ),
                _ChoiceChip(
                  label: 'Высокая',
                  value: 'high',
                  groupValue: _urgency,
                  onSelected: (value) => setState(() => _urgency = value),
                ),
                _ChoiceChip(
                  label: 'Критическая',
                  value: 'critical',
                  groupValue: _urgency,
                  onSelected: (value) => setState(() => _urgency = value),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _Section(
            title: 'Кто нуждается?',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ChoiceChip(
                  label: 'Ребёнок',
                  value: 'child',
                  groupValue: _group,
                  onSelected: (value) => setState(() => _group = value),
                ),
                _ChoiceChip(
                  label: 'Беременная',
                  value: 'pregnant',
                  groupValue: _group,
                  onSelected: (value) => setState(() => _group = value),
                ),
                _ChoiceChip(
                  label: 'Пожилой',
                  value: 'elderly',
                  groupValue: _group,
                  onSelected: (value) => setState(() => _group = value),
                ),
                _ChoiceChip(
                  label: 'Хронический пациент',
                  value: 'chronic_patient',
                  groupValue: _group,
                  onSelected: (value) => setState(() => _group = value),
                ),
                _ChoiceChip(
                  label: 'Нет',
                  value: 'none',
                  groupValue: _group,
                  onSelected: (value) => setState(() => _group = value),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _village,
            decoration: const InputDecoration(labelText: 'Село'),
            items: const [
              DropdownMenuItem(value: 'Горное село', child: Text('Горное село')),
              DropdownMenuItem(value: 'Аксу', child: Text('Аксу')),
              DropdownMenuItem(value: 'Туркана, Кения', child: Text('Туркана, Кения')),
              DropdownMenuItem(value: 'Гулу, Уганда', child: Text('Гулу, Уганда')),
              DropdownMenuItem(value: 'Таматаве, Мадагаскар', child: Text('Таматаве, Мадагаскар')),
              DropdownMenuItem(value: 'Агадес, Нигер', child: Text('Агадес, Нигер')),
              DropdownMenuItem(value: 'Санта-Роса, Перу', child: Text('Санта-Роса, Перу')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _village = value);
              }
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Описание'),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _submitting ? null : _submit,
            child: Text(_submitting ? 'Отправка...' : 'Отправить заявку'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onSelected,
  });

  final String label;
  final String value;
  final String groupValue;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: value == groupValue,
      onSelected: (_) => onSelected(value),
    );
  }
}
