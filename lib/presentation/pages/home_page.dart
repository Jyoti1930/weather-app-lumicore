import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/weather_cubit.dart';
import '../cubit/weather_state.dart';
import '../widgets/error_view.dart';
import '../widgets/recent_searches_widget.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/weather_display.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weather')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: BlocBuilder<WeatherCubit, WeatherState>(
            builder: (context, state) {
              return RefreshIndicator(
                onRefresh: () => context.read<WeatherCubit>().refreshWeather(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SearchBarWidget(
                        onSearch: (city) => context.read<WeatherCubit>().searchCity(city),
                      ),
                      const SizedBox(height: 16),
                      _buildContent(context, state),
                      RecentSearchesWidget(
                        searches: state.recentSearches,
                        onTap: (city) => context.read<WeatherCubit>().searchCity(city),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WeatherState state) {
    if (state is WeatherLoading) {
      return const WeatherShimmerLoading();
    } else if (state is WeatherLoaded) {
      return WeatherDisplay(
        weather: state.weather,
        isFromCache: state.isFromCache,
        cacheMessage: state.cacheMessage,
      );
    } else if (state is WeatherFailure) {
      return ErrorView(
        message: state.message,
        onRetry: state.recentSearches.isNotEmpty
            ? () => context.read<WeatherCubit>().searchCity(state.recentSearches.first)
            : null,
      );
    }
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Text(
          'Search for a city to see the current weather.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
