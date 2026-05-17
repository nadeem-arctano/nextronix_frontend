import 'package:flutter/material.dart';

/// Lays out form fields in a responsive grid: side-by-side on wide layouts,
/// stacked column on narrow ones.
///
/// Pass any number of children; they fill the row evenly. The `breakpoint`
/// controls when the grid collapses (default 540px — works well inside our
/// section cards).
class FormFieldGrid extends StatelessWidget {
  final List<Widget> children;
  final double breakpoint;
  final double gap;

  const FormFieldGrid({
    super.key,
    required this.children,
    this.breakpoint = 540,
    this.gap = 16,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < breakpoint || children.length == 1) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:
              children
                  .expand((w) => [Expanded(child: w), SizedBox(width: gap)])
                  .toList()
                ..removeLast(),
        );
      },
    );
  }
}
