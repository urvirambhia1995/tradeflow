import 'package:flutter/material.dart';

import '../../../../core/constants/stock_constants.dart';
import '../widgets/market_stock_row.dart';

class MarketPage extends StatelessWidget {
  const MarketPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Live Market',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        // actions: [
        //   IconButton(
        //     onPressed: () {
        //       // Search will be added later.
        //     },
        //     icon: const Icon(Icons.search),
        //   ),
        // ],
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          16,
          8,
          16,
          24,
        ),
        children: [
          // Market status
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceVariant,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),

                const SizedBox(width: 10),

                const Text(
                  'Market Open',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const Spacer(),

                Text(
                  'LIVE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.green.shade700,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Section header
          Row(
            children: [
              const Text(
                'Stocks',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(width: 8),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${StockConstants.stocks.length}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context)
                        .colorScheme
                        .onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Stock list
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .outlineVariant,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: StockConstants.stocks.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: Theme.of(context)
                    .colorScheme
                    .outlineVariant,
              ),
              itemBuilder: (context, index) {
                final stock = StockConstants.stocks[index];

                return MarketStockRow(
                  key: ValueKey(stock.symbol),
                  symbol: stock.symbol,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}