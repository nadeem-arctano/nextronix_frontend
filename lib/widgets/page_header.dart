import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Common page header with title, subtitle, and optional action buttons
class PageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;

  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.h2),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle!, style: theme.textTheme.muted),
            ],
          ],
        ),
        if (actions != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children:
                actions!.expand((w) => [w, const SizedBox(width: 8)]).toList()
                  ..removeLast(),
          ),
      ],
    );
  }
}
