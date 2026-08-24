import '../../../../domain/entities/holding.dart';
import '../../../../domain/entities/order.dart';
import '../../../../domain/entities/wallet.dart';

class TradingState {
  final Wallet wallet;
  final List<Holding> holdings;
  final List<Order> orders;
  final String? error;

  const TradingState({
    required this.wallet,
    required this.holdings,
    required this.orders,
    this.error,
  });

  TradingState copyWith({
    Wallet? wallet,
    List<Holding>? holdings,
    List<Order>? orders,
    String? error,
    bool clearError = false,
  }) {
    return TradingState(
      wallet: wallet ?? this.wallet,
      holdings: holdings ?? this.holdings,
      orders: orders ?? this.orders,
      error: clearError ? null : error ?? this.error,
    );
  }
}