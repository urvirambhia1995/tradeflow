enum PriceDirection {
  up,
  down,
  unchanged,
}

class PriceTick {
  final String symbol;
  final int ltpPaise;
  final int previousLtpPaise;
  final int changePaise;
  final double changePercent;
  final PriceDirection direction;
  final DateTime timestamp;

  const PriceTick({
    required this.symbol,
    required this.ltpPaise,
    required this.previousLtpPaise,
    required this.changePaise,
    required this.changePercent,
    required this.direction,
    required this.timestamp,
  });
}