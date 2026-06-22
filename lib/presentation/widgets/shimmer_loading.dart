import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class WeatherShimmerLoading extends StatelessWidget {
  const WeatherShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(context).colorScheme.surfaceVariant;
    final highlightColor = Theme.of(context).colorScheme.surface;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Column(
        children: [
          Container(
            height: 260,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ],
      ),
    );
  }
}
