import 'package:flutter/material.dart';

import '../../api_service.dart';
import '../../widgets/inventory_item_tile.dart';
import '../../widgets/nomadia_navigation.dart';

class SupplierInventoryScreen extends StatefulWidget {
  const SupplierInventoryScreen({super.key});

  @override
  State<SupplierInventoryScreen> createState() => _SupplierInventoryScreenState();
}

class _SupplierInventoryScreenState extends State<SupplierInventoryScreen> {
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService.instance.getInventory();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = ApiService.instance.getInventory();
    });
    await _future;
  }

  Future<void> _editItem(String itemKey, int current) async {
    final controller = TextEditingController(text: '$current');
    final quantity = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Изменить количество: ${_itemLabel(itemKey)}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Количество'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(int.tryParse(controller.text)),
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );

    if (quantity == null) {
      return;
    }

    try {
      final response = await ApiService.instance.updateInventory({
        'node': 'Аптека Аксу',
        'item': itemKey,
        'quantity': quantity,
      });
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] as String)),
      );
      await _refresh();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildNomadiaAppBar(
        context,
        title: 'Запасы аптеки',
        fallbackRoute: '/supplier',
      ),
      bottomNavigationBar: const NomadiaBottomArea(
        current: DemoRoleTab.supplier,
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
          final items = (nodes['Аптека Аксу'] as Map<String, dynamic>)['items']
              as Map<String, dynamic>;

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: items.entries
                          .map(
                            (entry) => Column(
                              children: [
                                InventoryItemTile(
                                  label: _itemLabel(entry.key),
                                  quantity: entry.value as int,
                                  onTap: () => _editItem(entry.key, entry.value as int),
                                ),
                                if (entry.key != items.keys.last) const Divider(),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}

String _itemLabel(String item) {
  return switch (item) {
    'insulin' => 'Инсулин',
    'antibiotics' => 'Антибиотики',
    'paracetamol' => 'Парацетамол',
    'medical_kits' => 'Медицинские наборы',
    'fuel_cans' => 'Канистры топлива',
    'solar_lanterns' => 'Солнечные фонари',
    'food_packs' => 'Сухие пайки',
    'water_kits' => 'Наборы воды',
    'baby_food' => 'Детское питание',
    _ => item,
  };
}
