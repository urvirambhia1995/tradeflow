import 'package:hive_flutter/hive_flutter.dart';

class TradingLocalDataSource {
  static const String boxName = 'trading';

  static const String walletKey = 'wallet';
  static const String holdingsKey = 'holdings';
  static const String ordersKey = 'orders';

  Future<void> init() async {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox(boxName);
    }
  }

  Box get _box => Hive.box(boxName);

  Future<void> saveWallet(Map<String, dynamic> wallet) async {
    await _box.put(walletKey, wallet);
  }

  Map<String, dynamic>? getWallet() {
    final data = _box.get(walletKey);

    if (data == null) {
      return null;
    }

    return Map<String, dynamic>.from(data);
  }

  Future<void> saveHoldings(
      List<Map<String, dynamic>> holdings,
      ) async {
    await _box.put(holdingsKey, holdings);
  }

  List<Map<String, dynamic>> getHoldings() {
    final data = _box.get(holdingsKey);

    if (data == null) {
      return [];
    }

    return List<Map<String, dynamic>>.from(
      (data as List).map(
            (item) => Map<String, dynamic>.from(item),
      ),
    );
  }

  Future<void> saveOrders(
      List<Map<String, dynamic>> orders,
      ) async {
    await _box.put(ordersKey, orders);
  }

  List<Map<String, dynamic>> getOrders() {
    final data = _box.get(ordersKey);

    if (data == null) {
      return [];
    }

    return List<Map<String, dynamic>>.from(
      (data as List).map(
            (item) => Map<String, dynamic>.from(item),
      ),
    );
  }
}