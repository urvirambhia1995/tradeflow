import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/entities/holding.dart';
import '../../../../injection/injection_container.dart';
import '../../../market/presentation/cubit/market_cubit.dart';
import '../../../market/presentation/cubit/market_state.dart';
import '../../../trading/presentation/cubit/trading_cubit.dart';
import '../../../trading/presentation/pages/order_ticket_page.dart';

class HoldingRow extends StatelessWidget {
  final Holding holding;

  const HoldingRow({
    super.key,
    required this.holding,
  });

  @override
  Widget build(BuildContext context) {
    return BlocSelector<MarketCubit, MarketState, dynamic>(
      selector: (state) => state.prices[holding.symbol],
      builder: (context, tick) {
        final ltpPaise =
            tick?.ltpPaise ??
                holding.averagePricePaise;

        final investedPaise =
            holding.quantity *
                holding.averagePricePaise;

        final currentValuePaise =
            holding.quantity *
                ltpPaise;

        final pnlPaise =
            currentValuePaise -
                investedPaise;

        final pnlPercent =
        investedPaise == 0
            ? 0.0
            : (pnlPaise /
            investedPaise) *
            100;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: Theme.of(context)
                  .colorScheme
                  .outlineVariant,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MultiBlocProvider(
                    providers: [
                      BlocProvider.value(
                        value: getIt<MarketCubit>(),
                      ),
                      BlocProvider.value(
                        value: getIt<TradingCubit>(),
                      ),
                    ],
                    child: OrderTicketPage(
                      symbol: holding.symbol,
                    ),
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Stock symbol icon
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      holding.symbol.substring(0, 1),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context)
                            .colorScheme
                            .primary,
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Stock details
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          holding.symbol,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          'Qty ${holding.quantity} • '
                              'Avg ₹${(holding.averagePricePaise / 100).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Price + P&L
                  Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${(ltpPaise / 100).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: pnlPaise >= 0
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${pnlPaise >= 0 ? '+' : ''}'
                              '₹${(pnlPaise / 100).toStringAsFixed(2)} '
                              '(${pnlPercent.toStringAsFixed(2)}%)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: pnlPaise >= 0
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}