import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/entities/holding.dart';
import '../../../market/presentation/cubit/market_cubit.dart';
import '../../../market/presentation/cubit/market_state.dart';
import 'summary_item.dart';

class SummaryCard extends StatelessWidget {
  final List<Holding> holdings;

  const SummaryCard({
    super.key,
    required this.holdings,
  });

  @override
  Widget build(BuildContext context) {
    return BlocSelector<MarketCubit, MarketState, Map<String, dynamic>>(
      selector: (state) {
        int invested = 0;
        int currentValue = 0;

        for (final holding in holdings) {
          invested +=
              holding.quantity * holding.averagePricePaise;

          final tick = state.prices[holding.symbol];

          if (tick != null) {
            currentValue +=
                holding.quantity * tick.ltpPaise;
          } else {
            currentValue +=
                holding.quantity *
                    holding.averagePricePaise;
          }
        }

        final pnl = currentValue - invested;

        final pnlPercent = invested == 0
            ? 0.0
            : (pnl / invested) * 100;

        return {
          'invested': invested,
          'currentValue': currentValue,
          'pnl': pnl,
          'pnlPercent': pnlPercent,
        };
      },
      builder: (context, data) {
        final invested = data['invested'] as int;
        final currentValue =
        data['currentValue'] as int;
        final pnl = data['pnl'] as int;
        final pnlPercent =
        data['pnlPercent'] as double;

        return Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.outlineVariant,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),

            side: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),

                    const SizedBox(width: 10),

                    const Text(
                      'Portfolio Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SummaryItem(
                      title: 'Invested',
                      value: invested,
                    ),

                    SummaryItem(
                      title: 'Current Value',
                      value: currentValue,
                    ),

                    SummaryItem(
                      title: 'P&L',
                      value: pnl,
                      percentage: pnlPercent,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}