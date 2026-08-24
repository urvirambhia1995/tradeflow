import '../entities/pricetick.dart';

abstract class MarketRepository {
  Stream<PriceTick> get priceTicks;

  PriceTick? getCurrentPrice(String symbol);

  void start();

  void stop();
}