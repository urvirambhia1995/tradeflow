import 'package:get_it/get_it.dart';

import '../data/datasources/mock_market_data_source.dart';
import '../data/datasources/watchlist_local_data_source.dart';
import '../data/repositories/market_repository_impl.dart';
import '../data/repositories/watchlist_repository_impl.dart';
import '../domain/repositories/marketrepository.dart';
import '../features/trading/presentation/cubit/trading_cubit.dart';
import '../data/datasources/trading_local_data_source.dart';
import '../data/repositories/trading_repository_impl.dart';
import '../domain/repositories/trading_repository.dart';
import '../domain/repositories/watchlist_repository.dart';
import '../features/market/presentation/cubit/market_cubit.dart';
import '../features/watchlist/presentation/cubit/watchlist_cubit.dart';
final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Data source
  getIt.registerLazySingleton<MockMarketDataSource>(
        () => MockMarketDataSource(),
  );
  final watchlistDataSource = WatchlistLocalDataSource();
  await watchlistDataSource.init();

  getIt.registerLazySingleton<WatchlistLocalDataSource>(
        () => watchlistDataSource,
  );

  getIt.registerLazySingleton<WatchlistRepository>(
        () => WatchlistRepositoryImpl(
      getIt<WatchlistLocalDataSource>(),
    ),
  );
  // Repository
  getIt.registerLazySingleton<MarketRepository>(
        () => MarketRepositoryImpl(
      getIt<MockMarketDataSource>(),
    ),
  );
  final tradingDataSource = TradingLocalDataSource();
  await tradingDataSource.init();

  getIt.registerLazySingleton<TradingLocalDataSource>(
        () => tradingDataSource,
  );

  getIt.registerLazySingleton<TradingRepository>(
        () => TradingRepositoryImpl(
      getIt<TradingLocalDataSource>(),
    ),
  );
  // Cubit
  getIt.registerLazySingleton<MarketCubit>(
        () => MarketCubit(
      repository: getIt<MarketRepository>(),
    ),
  );


  getIt.registerLazySingleton<WatchlistCubit>(
        () => WatchlistCubit(
      repository: getIt<WatchlistRepository>(),
    ),
  );

  getIt.registerLazySingleton<TradingCubit>(
        () => TradingCubit(
      repository: getIt<TradingRepository>(),
    ),
  );
}