import 'package:flutter/material.dart';

import '../theme.dart';

class InventoryItemTile extends StatelessWidget {
  const InventoryItemTile({
    super.key,
    required this.label,
    required this.quantity,
    this.onTap,
  });

  final String label;
  final int quantity;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final indicator = switch (quantity) {
      <= 0 => AppTheme.danger,
      <= 8 => AppTheme.warning,
      _ => AppTheme.success,
    };

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: indicator, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            Text(
              '$quantity',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
