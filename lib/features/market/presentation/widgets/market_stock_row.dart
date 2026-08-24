import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/entities/pricetick.dart';
import '../cubit/market_cubit.dart';
import '../cubit/market_state.dart';

class MarketStockRow extends StatefulWidget {
  final String symbol;

  const MarketStockRow({
    super.key,
    required this.symbol,
  });

  @override
  State<MarketStockRow> createState() => _MarketStockRowState();
}

class _MarketStockRowState extends State<MarketStockRow> {
  bool _flash = false;
  Color _flashColor = Colors.transparent;
  Timer? _flashTimer;
  @override
  void dispose() {
    _flashTimer?.cancel();
    super.dispose();
  }
  void _triggerFlash(PriceTick tick) {
    if (tick.direction == PriceDirection.unchanged) {
      return;
    }

    _flashTimer?.cancel();

    setState(() {
      _flashColor = tick.direction == PriceDirection.up
          ? Colors.green.withOpacity(0.18)
          : Colors.red.withOpacity(0.18);

      _flash = true;
    });

    _flashTimer = Timer(
      const Duration(milliseconds: 300),
          () {
        if (!mounted) return;

        setState(() {
          _flash = false;
        });
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return BlocListener<MarketCubit, MarketState>(
      listenWhen: (previous, current) {
        final previousTick = previous.prices[widget.symbol];
        final currentTick = current.prices[widget.symbol];

        return previousTick?.timestamp != currentTick?.timestamp;
      },
      listener: (context, state) {
        final tick = state.prices[widget.symbol];

        if (tick != null) {
          _triggerFlash(tick);
        }
      },
      child: BlocSelector<MarketCubit, MarketState, PriceTick?>(
        selector: (state) => state.prices[widget.symbol],
        builder: (context, tick) {
          if (tick == null) {
            return _buildLoadingRow(context);
          }

          return _buildPriceRow(context, tick);
        },
      ),
    );
  }
  Widget _buildLoadingRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 6,
      ),
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        child: const ListTile(
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          leading: CircleAvatar(
            radius: 20,
            child: Icon(Icons.show_chart),
          ),
          title: Text(
            'Loading...',
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text('Waiting for price...'),
        ),
      ),
    );
  }

  Widget _buildPriceRow(
      BuildContext context,
      PriceTick tick,
      ) {
    final price = tick.ltpPaise / 100;
    final change = tick.changePaise / 100;

    final isPositive = tick.changePaise > 0;
    final isNegative = tick.changePaise < 0;

    final changeColor = isPositive
        ? Colors.green
        : isNegative
        ? Colors.red
        : Colors.grey;

    final changeBackground = isPositive
        ? Colors.green.withOpacity(0.10)
        : isNegative
        ? Colors.red.withOpacity(0.10)
        : Colors.grey.withOpacity(0.10);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 5,
      ),
      child:
      AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: _flash
              ? _flashColor
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              // Open OrderTicketPage here if required.
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 13,
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.trending_up,
                      color: Theme.of(context)
                          .colorScheme
                          .primary,
                      size: 22,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          tick.symbol,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'NSE • Equity',
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

                  Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${price.toStringAsFixed(2)}',
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
                          color: changeBackground,
                          borderRadius:
                          BorderRadius.circular(7),
                        ),
                        child: Text(
                          '${isPositive ? '+' : ''}'
                              '₹${change.toStringAsFixed(2)} '
                              '(${isPositive ? '+' : ''}'
                              '${tick.changePercent.toStringAsFixed(2)}%)',
                          style: TextStyle(
                            color: changeColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

    );
  }
}