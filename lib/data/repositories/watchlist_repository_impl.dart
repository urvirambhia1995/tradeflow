import '../../domain/entities/watchlist.dart';
import '../../domain/repositories/watchlist_repository.dart';
import '../datasources/watchlist_local_data_source.dart';

class WatchlistRepositoryImpl implements WatchlistRepository {
  final WatchlistLocalDataSource dataSource;

  WatchlistRepositoryImpl(this.dataSource);

  @override
  List<Watchlist> getWatchlists() {
    final data = dataSource.getWatchlists();

    return data.map((item) {
      return Watchlist(
        id: item['id'] as String,
        name: item['name'] as String,
        symbols: List<String>.from(item['symbols'] as List),
      );
    }).toList();
  }

  @override
  Future<void> saveWatchlists(
      List<Watchlist> watchlists,
      ) async {
    final data = watchlists.map((watchlist) {
      return {
        'id': watchlist.id,
        'name': watchlist.name,
        'symbols': watchlist.symbols,
      };
    }).toList();

    await dataSource.saveWatchlists(data);
  }
}