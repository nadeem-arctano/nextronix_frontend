import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../core/theme/app_theme.dart';

/// Reusable role badge widget using ShadBadge
class RoleBadge extends StatelessWidget {
  final String role;

  const RoleBadge({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.getRoleColor(role);
    return Text(
      role.toUpperCase(),
      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
    );
  }
}
