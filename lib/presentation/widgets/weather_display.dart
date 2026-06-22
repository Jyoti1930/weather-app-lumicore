import 'package:flutter/material.dart';
import '../../domain/entities/weather_entity.dart';

class WeatherDisplay extends StatelessWidget {
  final WeatherEntity weather;
  final bool isFromCache;
  final String? cacheMessage;

  const WeatherDisplay({
    super.key,
    required this.weather,
    this.isFromCache = false,
    this.cacheMessage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isFromCache)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer.withOpacity(0.4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.cloud_off, size: 18, color: theme.colorScheme.error),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    cacheMessage ?? 'Showing last saved data (offline).',
                    style: TextStyle(color: theme.colorScheme.error, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  '${weather.cityName}, ${weather.country}',
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Image.network(
                  weather.conditionIconUrl,
                  width: 72,
                  height: 72,
                  errorBuilder: (_, __, ___) => const Icon(Icons.wb_sunny, size: 64),
                ),
                Text(
                  '${weather.temperatureCelsius.toStringAsFixed(1)}°C',
                  style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(weather.condition, style: theme.textTheme.titleMedium),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _InfoTile(
                      icon: Icons.water_drop,
                      label: 'Humidity',
                      value: '${weather.humidity}%',
                    ),
                    _InfoTile(
                      icon: Icons.air,
                      label: 'Wind',
                      value: '${weather.windKph.toStringAsFixed(1)} kph',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Updated: ${weather.lastUpdated}',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
