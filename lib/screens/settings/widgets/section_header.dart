import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? description;
  final IconData icon;
  final Color color;

  const SectionHeader({
    super.key,
    required this.title,
    this.description,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: theme.textTheme.h4.copyWith(fontSize: 15)),
              if (description != null) ...[
                const SizedBox(height: 2),
                Text(
                  description!,
                  style: theme.textTheme.muted.copyWith(fontSize: 12),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
