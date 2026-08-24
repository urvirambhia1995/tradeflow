import 'package:flutter/material.dart';

class SummaryItem extends StatelessWidget {
  final String title;
  final int value;
  final double? percentage;

  const SummaryItem({
    super.key,
    required this.title,
    required this.value,
    this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    final isPnl = percentage != null;
    final isPositive = value > 0;

    final valueColor = isPnl
        ? (isPositive ? Colors.green : Colors.red)
        : Theme.of(context).colorScheme.onSurface;

    final amount = value / 100;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context)
                .colorScheme
                .onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),

      ],
    );
  }
}