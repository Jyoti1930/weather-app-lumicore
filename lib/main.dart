import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/network/dio_client.dart';
import 'core/network/network_info.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/weather_local_data_source.dart';
import 'data/datasources/weather_remote_data_source.dart';
import 'data/repositories/weather_repository_impl.dart';
import 'domain/usecases/get_recent_searches_usecase.dart';
import 'domain/usecases/get_weather_usecase.dart';
import 'domain/usecases/get_initial_weather_usecase.dart';
import 'presentation/cubit/weather_cubit.dart';
import 'presentation/pages/home_page.dart';


const String weatherBoxName = 'weather_cache_box';
const String searchesBoxName = 'recent_searches_box';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  final weatherBox = await Hive.openBox<String>(weatherBoxName);
  final searchesBox = await Hive.openBox<String>(searchesBoxName);

  runApp(WeatherApp(weatherBox: weatherBox, searchesBox: searchesBox));
}

class WeatherApp extends StatelessWidget {
  final Box<String> weatherBox;
  final Box<String> searchesBox;

  const WeatherApp({
    super.key,
    required this.weatherBox,
    required this.searchesBox,
  });

  @override
  Widget build(BuildContext context) {
    final dio = DioClient().dio;

    final remoteDataSource = WeatherRemoteDataSourceImpl(dio);
    final localDataSource = WeatherLocalDataSourceImpl(
      weatherBox: weatherBox,
      searchesBox: searchesBox,
    );
    final networkInfo = NetworkInfoImpl(Connectivity());

    final repository = WeatherRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
      networkInfo: networkInfo,
    );

    return MaterialApp(
      title: 'Weather App',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: BlocProvider(
        create: (_) => WeatherCubit(
          getWeatherUseCase: GetWeatherUseCase(repository),
          getRecentSearchesUseCase: GetRecentSearchesUseCase(repository),
          getInitialWeatherUseCase: GetInitialWeatherUseCase(repository),
        ),
        child: const HomePage(),
      ),
    );
  }
}
