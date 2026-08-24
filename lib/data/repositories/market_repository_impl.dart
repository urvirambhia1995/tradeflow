import '../../domain/entities/pricetick.dart';
import '../../domain/repositories/marketrepository.dart';
import '../datasources/mock_market_data_source.dart';

class MarketRepositoryImpl implements MarketRepository {
  final MockMarketDataSource dataSource;

  MarketRepositoryImpl(this.dataSource);

  @override
  Stream<PriceTick> get priceTicks => dataSource.priceTicks;

  @override
  PriceTick? getCurrentPrice(String symbol) {
    return dataSource.getCurrentPrice(symbol);
  }

  @override
  void start() {
    dataSource.start();
  }

  @override
  void stop() {
    dataSource.stop();
  }
}