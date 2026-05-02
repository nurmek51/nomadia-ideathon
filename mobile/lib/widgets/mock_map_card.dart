import 'package:flutter/material.dart';

import '../theme.dart';

class MockMapCard extends StatelessWidget {
  const MockMapCard({
    super.key,
    required this.fromLabel,
    required this.toLabel,
  });

  final String fromLabel;
  final String toLabel;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Маршрут', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: CustomPaint(
                painter: _RoutePainter(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _MapLabel(
                        color: AppTheme.success,
                        label: fromLabel,
                        alignRight: false,
                      ),
                      _MapLabel(
                        color: AppTheme.primary,
                        label: toLabel,
                        alignRight: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapLabel extends StatelessWidget {
  const _MapLabel({
    required this.color,
    required this.label,
    required this.alignRight,
  });

  final Color color;
  final String label;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class _RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = AppTheme.line.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final routePaint = Paint()
      ..color = AppTheme.secondary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    for (double y = 12; y < size.height; y += 28) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), borderPaint);
    }

    final path = Path()
      ..moveTo(38, 34)
      ..cubicTo(size.width * 0.34, 38, size.width * 0.46, size.height * 0.7,
          size.width - 38, size.height - 34);
    canvas.drawPath(path, routePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
