import '../../domain/entities/holding.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/wallet.dart';
import '../../domain/repositories/trading_repository.dart';
import '../datasources/trading_local_data_source.dart';

class TradingRepositoryImpl implements TradingRepository {
  final TradingLocalDataSource dataSource;

  TradingRepositoryImpl(this.dataSource);

  @override
  Wallet getWallet() {
    final data = dataSource.getWallet();

    if (data == null) {
      return const Wallet(
        balancePaise: 10000000,
      );
    }

    return Wallet(
      balancePaise: data['balancePaise'] as int,
    );
  }

  @override
  List<Holding> getHoldings() {
    return dataSource.getHoldings().map((item) {
      return Holding(
        symbol: item['symbol'] as String,
        quantity: item['quantity'] as int,
        averagePricePaise:
        item['averagePricePaise'] as int,
      );
    }).toList();
  }

  @override
  List<Order> getOrders() {
    return dataSource.getOrders().map((item) {
      return Order(
        id: item['id'] as String,
        symbol: item['symbol'] as String,
        side: item['side'] == 'buy'
            ? OrderSide.buy
            : OrderSide.sell,
        quantity: item['quantity'] as int,
        pricePaise: item['pricePaise'] as int,
        totalValuePaise:
        item['totalValuePaise'] as int,
        timestamp: DateTime.fromMillisecondsSinceEpoch(
          item['timestamp'] as int,
        ),
      );
    }).toList();
  }

  @override
  Future<void> saveWallet(Wallet wallet) async {
    await dataSource.saveWallet({
      'balancePaise': wallet.balancePaise,
    });
  }

  @override
  Future<void> saveHoldings(
      List<Holding> holdings,
      ) async {
    await dataSource.saveHoldings(
      holdings.map((holding) {
        return {
          'symbol': holding.symbol,
          'quantity': holding.quantity,
          'averagePricePaise':
          holding.averagePricePaise,
        };
      }).toList(),
    );
  }

  @override
  Future<void> saveOrders(
      List<Order> orders,
      ) async {
    await dataSource.saveOrders(
      orders.map((order) {
        return {
          'id': order.id,
          'symbol': order.symbol,
          'side': order.side.name,
          'quantity': order.quantity,
          'pricePaise': order.pricePaise,
          'totalValuePaise':
          order.totalValuePaise,
          'timestamp':
          order.timestamp.millisecondsSinceEpoch,
        };
      }).toList(),
    );
  }
}