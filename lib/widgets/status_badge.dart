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
    switch (status.toLowerCase()) {
      case 'active':
      case 'delivered':
      case 'paid':
        return AppTheme.successColor;
      case 'inactive':
      case 'cancelled':
      case 'failed':
      case 'deleted':
      case 'blocked':
        return AppTheme.dangerColor;
      case 'pending':
      case 'draft':
        return AppTheme.warningColor;
      case 'confirmed':
      case 'packed':
        return AppTheme.infoColor;
      case 'shipped':
      case 'out_for_delivery':
        return AppTheme.primaryColor;
      case 'returned':
      case 'refunded':
        return Colors.orange;
      default:
        return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(4),
      ),
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
