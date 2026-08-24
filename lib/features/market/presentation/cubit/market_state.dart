import '../../../../domain/entities/pricetick.dart';

class MarketState {
  final Map<String, PriceTick> prices;

  const MarketState({
    this.prices = const {},
  });

  MarketState copyWith({
    Map<String, PriceTick>? prices,
  }) {
    return MarketState(
      prices: prices ?? this.prices,
    );
  }
}