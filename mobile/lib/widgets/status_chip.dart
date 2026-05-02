import 'package:flutter/material.dart';

import '../theme.dart';
import '../utils/labels.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _backgroundFor(label),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.line, width: 1),
      ),
      child: Text(
        _humanize(label),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Color _backgroundFor(String status) {
    return switch (normalizeStatusCode(status)) {
      'critical' || 'created' => AppTheme.danger.withValues(alpha: 0.16),
      'high' || 'verified' || 'matched' => AppTheme.warning.withValues(alpha: 0.16),
      'supplier_confirmed' || 'prioritized' => AppTheme.secondary.withValues(alpha: 0.18),
      'in_delivery' || 'delivered' => AppTheme.success.withValues(alpha: 0.16),
      _ => AppTheme.surfaceMuted,
    };
  }

  String _humanize(String raw) {
    final status = statusLabel(raw);
    if (status != raw || normalizeStatusCode(raw) != raw) {
      return status;
    }
    return priorityLevelLabel(raw);
  }
}
