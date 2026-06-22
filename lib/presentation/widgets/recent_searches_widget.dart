import 'package:flutter/material.dart';

class RecentSearchesWidget extends StatelessWidget {
  final List<String> searches;
  final void Function(String city) onTap;

  const RecentSearchesWidget({
    super.key,
    required this.searches,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (searches.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 16, bottom: 8),
          child: Text(
            'Recent searches',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: searches
              .map(
                (city) => ActionChip(
                  avatar: const Icon(Icons.history, size: 16),
                  label: Text(city),
                  onPressed: () => onTap(city),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
