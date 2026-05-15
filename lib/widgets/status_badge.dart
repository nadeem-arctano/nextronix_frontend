import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../core/theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final Map<String, Color>? colorMap;

  const StatusBadge({super.key, required this.status, this.colorMap});

  Color get _color {
    if (colorMap != null && colorMap!.containsKey(status)) {
      return colorMap![status]!;
    }
    return AppTheme.getStatusColor(status);
  }

  @override
  Widget build(BuildContext context) {
    return ShadBadge.outline(
      backgroundColor: _color.withValues(alpha: 0.08),
      foregroundColor: _color,
      child: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: _color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
