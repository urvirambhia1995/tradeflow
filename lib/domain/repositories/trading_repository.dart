import '../entities/holding.dart';
import '../entities/order.dart';
import '../entities/wallet.dart';

abstract class TradingRepository {
  Wallet getWallet();

  List<Holding> getHoldings();

  List<Order> getOrders();

  Future<void> saveWallet(Wallet wallet);

  Future<void> saveHoldings(List<Holding> holdings);

  Future<void> saveOrders(List<Order> orders);
}