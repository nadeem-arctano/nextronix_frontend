import 'package:flutter/material.dart';
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
    return Text(
      status.replaceAll('_', ' ').toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: _color,
        letterSpacing: 0.3,
      ),
    );
  }
}
