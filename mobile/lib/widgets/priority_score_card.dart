import 'package:flutter/material.dart';

import '../theme.dart';
import '../utils/labels.dart';

class PriorityScoreCard extends StatelessWidget {
  const PriorityScoreCard({
    super.key,
    required this.score,
    required this.level,
    required this.summary,
  });

  final int score;
  final String level;
  final String summary;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.ink,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$score / 100',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _levelLabel(level),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              summary,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.92),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  String _levelLabel(String raw) {
    return priorityHeadlineLabel(raw);
  }
}
