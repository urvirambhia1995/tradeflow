import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../market/presentation/cubit/market_cubit.dart';
import '../../../market/presentation/cubit/market_state.dart';
import '../cubit/trading_cubit.dart';
import '../cubit/trading_state.dart';

class OrderTicketPage extends StatefulWidget {
  final String symbol;

  const OrderTicketPage({
    super.key,
    required this.symbol,
  });

  @override
  State<OrderTicketPage> createState() => _OrderTicketPageState();
}

class _OrderTicketPageState extends State<OrderTicketPage> {
  final _quantityController = TextEditingController();

  bool _isBuy = true;

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  int get _quantity {
    return int.tryParse(
      _quantityController.text.trim(),
    ) ??
        0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Place Order',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: BlocSelector<MarketCubit, MarketState, dynamic>(
        selector: (state) => state.prices[widget.symbol],
        builder: (context, tick) {
          if (tick == null) {
            return const Center(
              child: Text('Waiting for price...'),
            );
          }

          final pricePaise = tick.ltpPaise;
          final price = pricePaise / 100;

          final orderValuePaise = _quantity * pricePaise;
          final orderValue = orderValuePaise / 100;

          final isPricePositive = tick.changePaise >= 0;

          return BlocBuilder<TradingCubit, TradingState>(
            builder: (context, tradingState) {
              final balance =
                  tradingState.wallet.balancePaise / 100;

              final heldQuantity =
              _getHeldQuantity(tradingState);

              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        16,
                        16,
                        24,
                      ),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          // -------------------------------------------------
                          // Stock Header
                          // -------------------------------------------------

                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                              BorderRadius.circular(18),
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: theme
                                        .colorScheme
                                        .primaryContainer,
                                    borderRadius:
                                    BorderRadius.circular(14),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    widget.symbol.substring(0, 1),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight:
                                      FontWeight.bold,
                                      color: theme
                                          .colorScheme
                                          .onPrimaryContainer,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 14),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.symbol,
                                        style: const TextStyle(
                                          fontSize: 19,
                                          fontWeight:
                                          FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        'Live market price',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors
                                              .grey
                                              .shade600,
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
                                        fontSize: 18,
                                        fontWeight:
                                        FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Container(
                                      padding:
                                      const EdgeInsets
                                          .symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isPricePositive
                                            ? Colors.green
                                            .withOpacity(0.10)
                                            : Colors.red
                                            .withOpacity(0.10),
                                        borderRadius:
                                        BorderRadius.circular(
                                          7,
                                        ),
                                      ),
                                      child: Text(
                                        '${isPricePositive ? '+' : ''}'
                                            '${tick.changePercent.toStringAsFixed(2)}%',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight:
                                          FontWeight.w600,
                                          color: isPricePositive
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // -------------------------------------------------
                          // Buy / Sell
                          // -------------------------------------------------

                          const Text(
                            'Order Type',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                              BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                              ),
                            ),
                            child: Row(
                              children: [
                                _buildSideButton(
                                  label: 'BUY',
                                  selected: _isBuy,
                                  color: const Color(0xFF16A34A),
                                  onTap: () {
                                    setState(() {
                                      _isBuy = true;
                                    });

                                    context
                                        .read<TradingCubit>()
                                        .clearError();
                                  },
                                ),
                                _buildSideButton(
                                  label: 'SELL',
                                  selected: !_isBuy,
                                  color: const Color(0xFFDC2626),
                                  onTap: () {
                                    setState(() {
                                      _isBuy = false;
                                    });

                                    context
                                        .read<TradingCubit>()
                                        .clearError();
                                  },
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // -------------------------------------------------
                          // Quantity
                          // -------------------------------------------------

                          const Text(
                            'Quantity',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 10),

                          TextField(
                            controller: _quantityController,
                            keyboardType:
                            TextInputType.number,
                            onChanged: (_) {
                              setState(() {});

                              context
                                  .read<TradingCubit>()
                                  .clearError();
                            },
                            decoration: InputDecoration(
                              hintText: 'Enter quantity',
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: const Icon(
                                Icons.numbers_rounded,
                              ),
                              border: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder:
                              OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE5E7EB),
                                ),
                              ),
                              focusedBorder:
                              OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: _isBuy
                                      ? const Color(0xFF16A34A)
                                      : const Color(0xFFDC2626),
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // -------------------------------------------------
                          // Order Summary
                          // -------------------------------------------------

                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                              BorderRadius.circular(18),
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                              ),
                            ),
                            child: Column(
                              children: [
                                _summaryRow(
                                  'Order Value',
                                  '₹${orderValue.toStringAsFixed(2)}',
                                  valueBold: true,
                                ),

                                const SizedBox(height: 14),

                                const Divider(
                                  height: 1,
                                ),

                                const SizedBox(height: 14),

                                _summaryRow(
                                  'Available Balance',
                                  '₹${balance.toStringAsFixed(2)}',
                                ),

                                if (!_isBuy) ...[
                                  const SizedBox(height: 12),
                                  _summaryRow(
                                    'Held Quantity',
                                    '$heldQuantity',
                                  ),
                                ],
                              ],
                            ),
                          ),

                          // -------------------------------------------------
                          // Error
                          // -------------------------------------------------

                          if (tradingState.error != null) ...[
                            const SizedBox(height: 14),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.08),
                                borderRadius:
                                BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                  Colors.red.withOpacity(0.20),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      tradingState.error!,
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 13,
                                        fontWeight:
                                        FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // ---------------------------------------------------------
                  // Bottom Submit Button
                  // ---------------------------------------------------------

                  Container(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      12,
                      16,
                      16,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(
                          color: Color(0xFFE5E7EB),
                        ),
                      ),
                    ),
                    child: SafeArea(
                      top: false,
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isBuy
                                ? const Color(0xFF16A34A)
                                : const Color(0xFFDC2626),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: _quantity <= 0
                              ? null
                              : () async {
                            final tradingCubit = context.read<TradingCubit>();

                            final success = _isBuy
                                ? await tradingCubit.buy(
                              symbol: widget.symbol,
                              quantity: _quantity,
                              pricePaise: pricePaise,
                            )
                                : await tradingCubit.sell(
                              symbol: widget.symbol,
                              quantity: _quantity,
                              pricePaise: pricePaise,
                            );

                            if (!mounted) {
                              return;
                            }

                            if (success) {
                              Navigator.pop(
                                context,
                                true,
                              );
                            }
                          },
                          child: Text(
                            _isBuy
                                ? 'BUY ${widget.symbol}'
                                : 'SELL ${widget.symbol}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Buy / Sell Button
  // ---------------------------------------------------------------------------

  Widget _buildSideButton({
    required String label,
    required bool selected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? color
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected
                  ? Colors.white
                  : Colors.grey.shade600,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Summary Row
  // ---------------------------------------------------------------------------

  Widget _summaryRow(
      String label,
      String value, {
        bool valueBold = false,
      }) {
    return Row(
      mainAxisAlignment:
      MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: valueBold
                ? FontWeight.w700
                : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  int _getHeldQuantity(TradingState state) {
    for (final holding in state.holdings) {
      if (holding.symbol == widget.symbol) {
        return holding.quantity;
      }
    }

    return 0;
  }
}