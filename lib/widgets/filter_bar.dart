import 'package:flutter/material.dart';

/// Common filter bar wrapped in a Card
class FilterBar extends StatelessWidget {
  final List<Widget> children;

  const FilterBar({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: children,
        ),
      ),
    );
  }
}
