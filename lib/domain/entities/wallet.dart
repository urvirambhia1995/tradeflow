class Wallet {
  final int balancePaise;

  const Wallet({
    required this.balancePaise,
  });

  Wallet copyWith({
    int? balancePaise,
  }) {
    return Wallet(
      balancePaise: balancePaise ?? this.balancePaise,
    );
  }
}