import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/entities/watchlist.dart';
import '../../../../domain/repositories/watchlist_repository.dart';

class WatchlistCubit extends Cubit<List<Watchlist>> {
  final WatchlistRepository _repository;

  WatchlistCubit({
    required WatchlistRepository repository,
  })  : _repository = repository,
        super(const []) {
    _loadWatchlists();
  }

  void _loadWatchlists() {
    final watchlists = _repository.getWatchlists();

    if (watchlists.isEmpty) {
      const defaultWatchlist = Watchlist(
        id: '1',
        name: 'My Watchlist',
        symbols: [
          'RELIANCE',
          'TCS',
          'INFY',
        ],
      );

      emit([defaultWatchlist]);
      _repository.saveWatchlists([defaultWatchlist]);
      return;
    }

    emit(watchlists);
  }

  void _save(List<Watchlist> watchlists) {
    emit(watchlists);
    _repository.saveWatchlists(watchlists);
  }

  void addSymbol(String watchlistId, String symbol) {
    final updated = state.map((watchlist) {
      if (watchlist.id != watchlistId) {
        return watchlist;
      }

      if (watchlist.symbols.contains(symbol)) {
        return watchlist;
      }

      return watchlist.copyWith(
        symbols: [
          ...watchlist.symbols,
          symbol,
        ],
      );
    }).toList();

    _save(updated);
  }

  void removeSymbol(String watchlistId, String symbol) {
    final updated = state.map((watchlist) {
      if (watchlist.id != watchlistId) {
        return watchlist;
      }

      return watchlist.copyWith(
        symbols: watchlist.symbols
            .where((item) => item != symbol)
            .toList(),
      );
    }).toList();

    _save(updated);
  }

  void addWatchlist(String name) {
    final watchlist = Watchlist(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      symbols: const [],
    );

    _save([
      ...state,
      watchlist,
    ]);
  }

  void renameWatchlist(
      String watchlistId,
      String newName,
      ) {
    final updated = state.map((watchlist) {
      if (watchlist.id != watchlistId) {
        return watchlist;
      }

      return watchlist.copyWith(
        name: newName,
      );
    }).toList();

    _save(updated);
  }

  void deleteWatchlist(String watchlistId) {
    final updated = state
        .where((watchlist) => watchlist.id != watchlistId)
        .toList();

    _save(updated);
  }

  void reorderSymbols(
      String watchlistId,
      int oldIndex,
      int newIndex,
      ) {
    final updated = state.map((watchlist) {
      if (watchlist.id != watchlistId) {
        return watchlist;
      }

      final symbols = List<String>.from(
        watchlist.symbols,
      );

      if (oldIndex < newIndex) {
        newIndex -= 1;
      }

      final symbol = symbols.removeAt(oldIndex);
      symbols.insert(newIndex, symbol);

      return watchlist.copyWith(
        symbols: symbols,
      );
    }).toList();

    _save(updated);
  }
}