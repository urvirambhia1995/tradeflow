import '../entities/watchlist.dart';

abstract class WatchlistRepository {
  List<Watchlist> getWatchlists();

  Future<void> saveWatchlists(List<Watchlist> watchlists);
}