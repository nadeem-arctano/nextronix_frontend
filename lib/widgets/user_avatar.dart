import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:flutter/material.dart';

/// Reusable user avatar with initials using ShadAvatar
class UserAvatar extends StatelessWidget {
  final String name;
  final double radius;
  final Color? backgroundColor;
  final Color? textColor;

  const UserAvatar({
    super.key,
    required this.name,
    this.radius = 16,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final initials = _getInitials(name);
    final size = radius * 2;

    return ShadAvatar(
      '',
      size: Size(size, size),
      placeholder: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor ?? theme.colorScheme.muted,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          initials,
          style: TextStyle(
            color: textColor ?? theme.colorScheme.foreground,
            fontWeight: FontWeight.w600,
            fontSize: radius * 0.65,
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }
}
