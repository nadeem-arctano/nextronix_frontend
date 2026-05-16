import 'package:flutter/material.dart';

/// Lays out form fields in a 2-column grid on wide screens, single column on narrow.
class ResponsiveFieldGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;

  const ResponsiveFieldGrid({
    super.key,
    required this.children,
    this.spacing = 16,
    this.runSpacing = 14,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth > 600;
        if (!wide) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children:
                children
                    .expand((w) => [w, SizedBox(height: runSpacing)])
                    .toList()
                  ..removeLast(),
          );
        }
        final rows = <Widget>[];
        for (var i = 0; i < children.length; i += 2) {
          final left = children[i];
          final right = i + 1 < children.length ? children[i + 1] : null;
          rows.add(
            Padding(
              padding: EdgeInsets.only(bottom: runSpacing),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: left),
                  SizedBox(width: spacing),
                  Expanded(child: right ?? const SizedBox()),
                ],
              ),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: rows,
        );
      },
    );
  }
}
