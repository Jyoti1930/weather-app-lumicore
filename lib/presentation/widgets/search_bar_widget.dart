import 'package:flutter/material.dart';

class SearchBarWidget extends StatefulWidget {
  final void Function(String city) onSearch;

  const SearchBarWidget({super.key, required this.onSearch});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final city = _controller.text.trim();
    if (city.isNotEmpty) {
          FocusScope.of(context).unfocus(); // hides keyboard
      widget.onSearch(city);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => _submit(),
      decoration: InputDecoration(
        hintText: 'Search city (e.g. Dubai, London)',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: _submit,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
