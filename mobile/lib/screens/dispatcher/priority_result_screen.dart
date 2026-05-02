import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../api_service.dart';
import '../../widgets/nomadia_navigation.dart';
import '../../widgets/priority_score_card.dart';

class PriorityResultScreen extends StatelessWidget {
  const PriorityResultScreen({
    super.key,
    required this.requestId,
    required this.result,
  });

  final int requestId;
  final Map<String, dynamic> result;

  @override
  Widget build(BuildContext context) {
    final reasons = (result['reasons'] as List<dynamic>).cast<String>();

    return Scaffold(
      appBar: buildNomadiaAppBar(
        context,
        title: 'AI-приоритизация',
        fallbackRoute: '/dispatcher',
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          PriorityScoreCard(
            score: result['priority_score'] as int,
            level: result['priority_level'] as String,
            summary: result['ai_summary'] as String,
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: reasons
                    .map((reason) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text('✓ $reason'),
                        ))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NomadiaBottomArea(
        current: DemoRoleTab.dispatcher,
        topChild: ElevatedButton(
          onPressed: () async {
            try {
              final matchResult = await _matchRequest(requestId);
              if (context.mounted) {
                context.push('/dispatcher/match/$requestId', extra: matchResult);
              }
            } catch (error) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$error')),
                );
              }
            }
          },
          child: const Text('Найти ближайший ресурс'),
        ),
      ),
    );
  }
}

Future<Map<String, dynamic>> _matchRequest(int requestId) async {
  return ApiService.instance.matchRequest(requestId);
}
