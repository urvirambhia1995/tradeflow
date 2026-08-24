import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/authentication/presentation/pages/splash_screen.dart';
import 'features/market/presentation/cubit/market_cubit.dart';
import 'features/trading/presentation/cubit/trading_cubit.dart';
import 'features/watchlist/presentation/cubit/watchlist_cubit.dart';
import 'injection/injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupDependencies();

  runApp(const TradingApp());
}

class TradingApp extends StatelessWidget {
  const TradingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: getIt<MarketCubit>(),
        ),
        BlocProvider.value(
          value: getIt<WatchlistCubit>(),
        ),
        BlocProvider.value(
          value: getIt<TradingCubit>(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'TradeFlow',

        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF16A34A),
          ),
          scaffoldBackgroundColor: const Color(0xFFF7F8FA),
        ),

        home: const SplashPage(),
      ),
    );
  }
}