import 'package:flutter/material.dart';

import '../../api_service.dart';
import '../../widgets/metric_card.dart';
import '../../widgets/nomadia_navigation.dart';

class AidCreditsScreen extends StatelessWidget {
  const AidCreditsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildNomadiaAppBar(
        context,
        title: 'Aid Credits',
        fallbackRoute: '/resident',
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: ApiService.instance.getAidCredits('resident_demo'),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }
          final credits = snapshot.data!['credits'] as Map<String, dynamic>;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              MetricCard(label: 'Еда', value: '${credits['food']}'),
              const SizedBox(height: 12),
              MetricCard(label: 'Медицина', value: '${credits['medicine']}'),
              const SizedBox(height: 12),
              MetricCard(label: 'Вода', value: '${credits['water']}'),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(width: 1.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.qr_code_2, size: 88),
                              SizedBox(height: 8),
                              Text('[ QR MOCK ]'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Покажите этот код в партнёрском магазине или аптеке',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
