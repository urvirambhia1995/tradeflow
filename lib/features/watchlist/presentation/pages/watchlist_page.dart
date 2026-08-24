import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/stock_constants.dart';
import '../../../../domain/entities/pricetick.dart';
import '../../../../injection/injection_container.dart';
import '../../../market/presentation/cubit/market_cubit.dart';
import '../../../market/presentation/cubit/market_state.dart';
import '../../../trading/presentation/cubit/trading_cubit.dart';
import '../../../trading/presentation/pages/order_ticket_page.dart';
import '../cubit/watchlist_cubit.dart';

class WatchlistPage extends StatelessWidget {
  const WatchlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Watchlist'),
        actions: [
          IconButton(
            onPressed: () {
              _showCreateWatchlistDialog(context);
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: BlocBuilder<WatchlistCubit, List>(
        builder: (context, watchlists) {
          if (watchlists.isEmpty) {
            return const Center(
              child: Text('No watchlist'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: watchlists.length,
            itemBuilder: (context, index) {
              final watchlist = watchlists[index];

              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                clipBehavior: Clip.antiAlias,
                color: Theme.of(context).colorScheme.surfaceVariant,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: Theme.of(context)
                        .colorScheme
                        .outlineVariant,
                  ),
                ),
                child: ExpansionTile(
                  initiallyExpanded: true,
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  childrenPadding: EdgeInsets.zero,

                  // Watchlist name + delete button
                  title: Text(
                    watchlist.name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  trailing: PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.more_vert,
                      size: 22,
                    ),
                    onSelected: (value) {
                      if (value == 'rename') {
                        _showRenameWatchlistDialog(
                          context,
                          watchlist.id,
                          watchlist.name,
                        );
                      } else if (value == 'delete') {
                        _showDeleteWatchlistDialog(
                          context,
                          watchlist.id,
                          watchlist.name,
                        );
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'rename',
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              size: 20,
                            ),
                            SizedBox(width: 10),
                            Text('Rename'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: Colors.redAccent,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Delete',
                              style: TextStyle(
                                color: Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    '${watchlist.symbols.length} stocks',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  children: [
                    if (watchlist.symbols.isEmpty)
                      const Padding(
                        key: ValueKey('empty'),
                        padding: EdgeInsets.all(16),
                        child: Text('No stocks added'),
                      )
                    else
                      ReorderableListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: watchlist.symbols.length,
                        onReorder: (oldIndex, newIndex) {
                          context.read<WatchlistCubit>().reorderSymbols(
                            watchlist.id,
                            oldIndex,
                            newIndex,
                          );
                        },
                        itemBuilder: (context, index) {
                          final symbol = watchlist.symbols[index];

                          return _WatchlistStockRow(
                            key: ValueKey(symbol),
                            symbol: symbol,
                            watchlistId: watchlist.id,
                          );
                        },
                      ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        4,
                        16,
                        12,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            _showAddStockDialog(
                              context,
                              watchlist.id,
                              watchlist.symbols,
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add Stock'),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showRenameWatchlistDialog(
      BuildContext context,
      String watchlistId,
      String currentName,
      ) {
    final controller = TextEditingController(
      text: currentName,
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Rename Watchlist'),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Watchlist name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = controller.text.trim();

                if (name.isEmpty) {
                  return;
                }

                context
                    .read<WatchlistCubit>()
                    .renameWatchlist(
                  watchlistId,
                  name,
                );

                Navigator.pop(dialogContext);
              },
              child: const Text('Rename'),
            ),
          ],
        );
      },
    );
  }
  void _showAddStockDialog(
      BuildContext context,
      String watchlistId,
      List<String> existingSymbols,
      ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add Stock'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: StockConstants.stocks.map((stock) {
                final isAdded = existingSymbols.contains(
                  stock.symbol,
                );

                return ListTile(
                  title: Text(stock.symbol),
                  trailing: isAdded
                      ? const Icon(
                    Icons.check,
                    color: Colors.green,
                  )
                      : null,
                  enabled: !isAdded,
                  onTap: isAdded
                      ? null
                      : () {
                    context
                        .read<WatchlistCubit>()
                        .addSymbol(
                      watchlistId,
                      stock.symbol,
                    );

                    Navigator.pop(dialogContext);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Create Watchlist Dialog
  // ---------------------------------------------------------------------------

  void _showCreateWatchlistDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Create Watchlist'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Watchlist name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = controller.text.trim();

                if (name.isEmpty) {
                  return;
                }

                context
                    .read<WatchlistCubit>()
                    .addWatchlist(name);

                Navigator.pop(dialogContext);
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Delete Watchlist Dialog
  // ---------------------------------------------------------------------------

  void _showDeleteWatchlistDialog(
      BuildContext context,
      String watchlistId,
      String watchlistName,
      ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Watchlist?'),
          content: Text(
            'Are you sure you want to delete "$watchlistName"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                context
                    .read<WatchlistCubit>()
                    .deleteWatchlist(watchlistId);

                Navigator.pop(dialogContext);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

// ===========================================================================
// Watchlist Stock Row
// ===========================================================================

class _WatchlistStockRow extends StatelessWidget {
  final String symbol;
  final String watchlistId;

  const _WatchlistStockRow({
    super.key,
    required this.symbol,
    required this.watchlistId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocSelector<MarketCubit, MarketState, PriceTick?>(
      selector: (state) => state.prices[symbol],
      builder: (context, tick) {
        if (tick == null) {
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            title: Text(
              symbol,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: const Text('Waiting for price...'),
          );
        }

        final price = tick.ltpPaise / 100;
        final isPositive = tick.changePaise >= 0;

        return Material(
          color: Colors.transparent,
          child: InkWell(
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
                      symbol: symbol,
                    ),
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              child: Row(
                children: [
                  // Stock icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      symbol.substring(0, 1),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimaryContainer,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Symbol
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tick.symbol,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.touch_app_outlined,
                              size: 13,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Tap to trade',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Price + change
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
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
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: isPositive
                              ? Colors.green.withOpacity(0.10)
                              : Colors.red.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${isPositive ? '+' : ''}'
                              '${tick.changePercent.toStringAsFixed(2)}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isPositive
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 4),

                  // More menu
                  PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.more_vert,
                      size: 20,
                    ),
                    onSelected: (value) {
                      if (value == 'remove') {
                        context
                            .read<WatchlistCubit>()
                            .removeSymbol(
                          watchlistId,
                          symbol,
                        );
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'remove',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text('Remove'),
                          ],
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