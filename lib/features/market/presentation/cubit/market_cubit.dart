import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/entities/pricetick.dart';
import '../../../../domain/repositories/marketrepository.dart';
import 'market_state.dart';

class MarketCubit extends Cubit<MarketState> {
  final MarketRepository _repository;

  StreamSubscription<PriceTick>? _priceSubscription;

  MarketCubit({
    required MarketRepository repository,
  })  : _repository = repository,
        super(const MarketState()) {
    _listenToPrices();
    _repository.start();
  }

  void _listenToPrices() {
    _priceSubscription = _repository.priceTicks.listen(
      _onPriceTick,
    );
  }

  void _onPriceTick(PriceTick tick) {
    final updatedPrices = Map<String, PriceTick>.from(
      state.prices,
    );

    updatedPrices[tick.symbol] = tick;

    emit(
      state.copyWith(
        prices: updatedPrices,
      ),
    );
  }

  PriceTick? getPrice(String symbol) {
    return state.prices[symbol] ??
        _repository.getCurrentPrice(symbol);
  }

  @override
  Future<void> close() {
    _priceSubscription?.cancel();
    return super.close();
  }
}