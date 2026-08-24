import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/entities/holding.dart';
import '../../../../domain/entities/order.dart';
import '../../../../domain/entities/wallet.dart';
import '../../../../domain/repositories/trading_repository.dart';
import 'trading_state.dart';

class TradingCubit extends Cubit<TradingState> {
  final TradingRepository _repository;

  TradingCubit({
    required TradingRepository repository,
  })  : _repository = repository,
        super(
        TradingState(
          wallet: repository.getWallet(),
          holdings: repository.getHoldings(),
          orders: repository.getOrders(),
        ),
      );

  Future<bool> buy({
    required String symbol,
    required int quantity,
    required int pricePaise,
  }) async {
    if (quantity <= 0) {
      emit(state.copyWith(
        error: 'Quantity must be greater than zero',
      ));
      return false;
    }

    final totalValue = quantity * pricePaise;

    if (totalValue > state.wallet.balancePaise) {
      emit(state.copyWith(
        error: 'Insufficient balance',
      ));
      return false;
    }

    final existingHolding = state.holdings
        .where((holding) => holding.symbol == symbol)
        .firstOrNull;

    final List<Holding> updatedHoldings;

    if (existingHolding == null) {
      updatedHoldings = [
        ...state.holdings,
        Holding(
          symbol: symbol,
          quantity: quantity,
          averagePricePaise: pricePaise,
        ),
      ];
    } else {
      final oldQuantity = existingHolding.quantity;
      final oldAverage = existingHolding.averagePricePaise;

      final totalQuantity = oldQuantity + quantity;

      final newAverage =
          ((oldQuantity * oldAverage) +
              (quantity * pricePaise)) ~/
              totalQuantity;

      updatedHoldings = state.holdings.map((holding) {
        if (holding.symbol != symbol) {
          return holding;
        }

        return holding.copyWith(
          quantity: totalQuantity,
          averagePricePaise: newAverage,
        );
      }).toList();
    }

    final order = Order(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      symbol: symbol,
      side: OrderSide.buy,
      quantity: quantity,
      pricePaise: pricePaise,
      totalValuePaise: totalValue,
      timestamp: DateTime.now(),
    );

    final updatedWallet = state.wallet.copyWith(
      balancePaise:
      state.wallet.balancePaise - totalValue,
    );

    final updatedOrders = [
      ...state.orders,
      order,
    ];

    emit(
      state.copyWith(
        wallet: updatedWallet,
        holdings: updatedHoldings,
        orders: updatedOrders,
        clearError: true,
      ),
    );

    await _persist(
      updatedWallet,
      updatedHoldings,
      updatedOrders,
    );

    return true;
  }

  Future<bool> sell({
    required String symbol,
    required int quantity,
    required int pricePaise,
  }) async {
    if (quantity <= 0) {
      emit(state.copyWith(
        error: 'Quantity must be greater than zero',
      ));
      return false;
    }

    final holding = state.holdings
        .where((holding) => holding.symbol == symbol)
        .firstOrNull;

    if (holding == null || holding.quantity < quantity) {
      emit(state.copyWith(
        error: 'Insufficient quantity',
      ));
      return false;
    }

    final totalValue = quantity * pricePaise;

    final remainingQuantity =
        holding.quantity - quantity;

    final List<Holding> updatedHoldings;

    if (remainingQuantity == 0) {
      updatedHoldings = state.holdings
          .where((item) => item.symbol != symbol)
          .toList();
    } else {
      updatedHoldings = state.holdings.map((item) {
        if (item.symbol != symbol) {
          return item;
        }

        return item.copyWith(
          quantity: remainingQuantity,
        );
      }).toList();
    }

    final updatedWallet = state.wallet.copyWith(
      balancePaise:
      state.wallet.balancePaise + totalValue,
    );

    final order = Order(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      symbol: symbol,
      side: OrderSide.sell,
      quantity: quantity,
      pricePaise: pricePaise,
      totalValuePaise: totalValue,
      timestamp: DateTime.now(),
    );

    final updatedOrders = [
      ...state.orders,
      order,
    ];

    emit(
      state.copyWith(
        wallet: updatedWallet,
        holdings: updatedHoldings,
        orders: updatedOrders,
        clearError: true,
      ),
    );

    await _persist(
      updatedWallet,
      updatedHoldings,
      updatedOrders,
    );

    return true;
  }

  Future<void> _persist(
      Wallet wallet,
      List<Holding> holdings,
      List<Order> orders,
      ) async {
    await Future.wait([
      _repository.saveWallet(wallet),
      _repository.saveHoldings(holdings),
      _repository.saveOrders(orders),
    ]);
  }

  void clearError() {
    emit(state.copyWith(clearError: true));
  }
}