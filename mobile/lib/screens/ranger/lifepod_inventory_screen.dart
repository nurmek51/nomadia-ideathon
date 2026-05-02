import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../api_service.dart';
import '../../widgets/inventory_item_tile.dart';
import '../../widgets/nomadia_navigation.dart';

class LifePodInventoryScreen extends StatelessWidget {
  const LifePodInventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildNomadiaAppBar(
        context,
        title: 'LifePod — Горное село',
        fallbackRoute: '/ranger',
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: ApiService.instance.getInventory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }
          final nodes = snapshot.data!['nodes'] as Map<String, dynamic>;
          final node = nodes['LifePod — Горное село'] as Map<String, dynamic>;
          final items = node['items'] as Map<String, dynamic>;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      InventoryItemTile(label: 'Инсулин', quantity: items['insulin'] as int),
                      const Divider(),
                      InventoryItemTile(
                        label: 'Антибиотики',
                        quantity: items['antibiotics'] as int,
                      ),
                      const Divider(),
                      InventoryItemTile(
                        label: 'Наборы воды',
                        quantity: items['water_kits'] as int,
                      ),
                      const Divider(),
                      InventoryItemTile(
                        label: 'Сухие пайки',
                        quantity: items['food_packs'] as int,
                      ),
                      const Divider(),
                      InventoryItemTile(
                        label: 'Детское питание',
                        quantity: items['baby_food'] as int,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.push('/ranger/issue'),
                child: const Text('Выдать ресурс'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Для MVP пополнение оформляется через диспетчера'),
                    ),
                  );
                },
                child: const Text('Запросить пополнение'),
              ),
            ],
          );
        },
      ),
    );
  }
}
