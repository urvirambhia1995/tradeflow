import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../trading/presentation/cubit/trading_cubit.dart';
import '../../../trading/presentation/cubit/trading_state.dart';
import '../widget/holding_row.dart';
import '../widget/summary_card.dart';

class HoldingsPage extends StatelessWidget {
  const HoldingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Holdings',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Your investment portfolio',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: BlocBuilder<TradingCubit, TradingState>(
        builder: (context, tradingState) {
          final holdings = tradingState.holdings;

          if (holdings.isEmpty) {
            return _buildEmptyState(context);
          }

          return RefreshIndicator(
            onRefresh: () async {
              // Later you can refresh market prices here.
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                16,
                12,
                16,
                24,
              ),
              children: [
                // Portfolio summary
                SummaryCard(
                  holdings: holdings,
                ),

                const SizedBox(height: 24),

                // Section header
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Your Stocks',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      '${holdings.length} '
                          '${holdings.length == 1 ? 'stock' : 'stocks'}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Holdings
                ...holdings.map(
                      (holding) => Padding(
                    padding: const EdgeInsets.only(
                      bottom: 10,
                    ),
                    child: HoldingRow(
                      holding: holding,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.account_balance_wallet_outlined,
                size: 38,
                color: Theme.of(context)
                    .colorScheme
                    .primary,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'No holdings yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Buy a stock to see your investments here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 20),

          ],
        ),
      ),
    );
  }
}