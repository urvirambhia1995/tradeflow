enum OrderSide {
  buy,
  sell,
}

class Order {
  final String id;
  final String symbol;
  final OrderSide side;
  final int quantity;
  final int pricePaise;
  final int totalValuePaise;
  final DateTime timestamp;

  const Order({
    required this.id,
    required this.symbol,
    required this.side,
    required this.quantity,
    required this.pricePaise,
    required this.totalValuePaise,
    required this.timestamp,
  });
}