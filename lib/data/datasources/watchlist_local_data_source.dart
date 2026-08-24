import 'package:hive_flutter/hive_flutter.dart';

class WatchlistLocalDataSource {
  static const String boxName = 'watchlists';

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(boxName);
  }

  Box get _box => Hive.box(boxName);

  Future<void> saveWatchlists(
      List<Map<String, dynamic>> watchlists,
      ) async {
    await _box.put('watchlists', watchlists);
  }

  List<Map<String, dynamic>> getWatchlists() {
    final data = _box.get('watchlists');

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