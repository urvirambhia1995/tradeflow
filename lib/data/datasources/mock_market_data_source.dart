import 'dart:async';
import 'dart:math';

import '../../core/constants/stock_constants.dart';
import '../../domain/entities/pricetick.dart';

class MockMarketDataSource {
  final Random _random = Random();

  final StreamController<PriceTick> _controller =
  StreamController<PriceTick>.broadcast();

  Timer? _timer;

  final Map<String, int> _currentPrices = {
    for (final stock in StockConstants.stocks)
      stock.symbol: stock.initialPricePaise,
  };

  final Map<String, int> _initialPrices = {
    for (final stock in StockConstants.stocks)
      stock.symbol: stock.initialPricePaise,
  };

  Stream<PriceTick> get priceTicks => _controller.stream;

  PriceTick? getCurrentPrice(String symbol) {
    final currentPrice = _currentPrices[symbol];

    if (currentPrice == null) {
      return null;
    }

    final initialPrice = _initialPrices[symbol]!;

    final changePaise = currentPrice - initialPrice;

    final changePercent =
        (changePaise / initialPrice) * 100;

    return PriceTick(
      symbol: symbol,
      ltpPaise: currentPrice,
      previousLtpPaise: currentPrice,
      changePaise: changePaise,
      changePercent: changePercent,
      direction: PriceDirection.unchanged,
      timestamp: DateTime.now(),
    );
  }

  void start({
    Duration interval = const Duration(seconds: 1),
  }) {
    if (_timer != null) {
      return;
    }

    _timer = Timer.periodic(interval, (_) {
      _emitTicks();
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void _emitTicks() {
    for (final stock in StockConstants.stocks) {
      _emitTick(stock.symbol);
    }
  }

  void _emitTick(String symbol) {
    final previousPrice = _currentPrices[symbol]!;

    // Random movement between -50 and +50 paise.
    final movement = _random.nextInt(101) - 50;

    var newPrice = previousPrice + movement;

    if (newPrice <= 0) {
      newPrice = previousPrice;
    }

    _currentPrices[symbol] = newPrice;

    final initialPrice = _initialPrices[symbol]!;

    final changePaise = newPrice - initialPrice;

    final changePercent =
        (changePaise / initialPrice) * 100;

    final direction = newPrice > previousPrice
        ? PriceDirection.up
        : newPrice < previousPrice
        ? PriceDirection.down
        : PriceDirection.unchanged;

    _controller.add(
      PriceTick(
        symbol: symbol,
        ltpPaise: newPrice,
        previousLtpPaise: previousPrice,
        changePaise: changePaise,
        changePercent: changePercent,
        direction: direction,
        timestamp: DateTime.now(),
      ),
    );
  }

  void dispose() {
    stop();
    _controller.close();
  }
}