import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:google_fonts/google_fonts.dart';

/// Nextronix theme configuration using shadcn_ui
/// Supports light and dark mode with consistent color tokens
class AppTheme {
  AppTheme._();

  // ─── Semantic Colors (used in custom widgets) ─────────────────────────
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color dangerColor = Color(0xFFEF4444);
  static const Color infoColor = Color(0xFF06B6D4);

  // ─── Legacy color references (for screens not yet fully migrated) ─────
  static const Color borderColor = Color(0xFFE5E7EB);
  static const Color bgColor = Color(0xFFF9FAFB);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color primaryColor = Color(0xFF2563EB);

  // ─── Sidebar Colors ───────────────────────────────────────────────────
  static const Color sidebarColor = Color(0xFF111827);
  static const Color sidebarActiveColor = Color(0xFF1F2937);

  // ─── Light Theme ──────────────────────────────────────────────────────
  static ShadThemeData lightTheme = ShadThemeData(
    brightness: Brightness.light,
    colorScheme: const ShadSlateColorScheme.light(),
    textTheme: ShadTextTheme.fromGoogleFont(GoogleFonts.inter),
  );

  // ─── Dark Theme ───────────────────────────────────────────────────────
  static ShadThemeData darkTheme = ShadThemeData(
    brightness: Brightness.dark,
    colorScheme: const ShadSlateColorScheme.dark(),
    textTheme: ShadTextTheme.fromGoogleFont(GoogleFonts.inter),
  );

  // ─── Helper: get status color ─────────────────────────────────────────
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'delivered':
      case 'paid':
        return successColor;
      case 'inactive':
      case 'cancelled':
      case 'failed':
      case 'deleted':
      case 'blocked':
        return dangerColor;
      case 'pending':
      case 'draft':
        return warningColor;
      case 'confirmed':
      case 'packed':
        return infoColor;
      case 'shipped':
      case 'out_for_delivery':
        return const Color(0xFF2563EB);
      case 'returned':
      case 'refunded':
        return Colors.orange;
      default:
        return const Color(0xFF6B7280);
    }
  }

  // ─── Helper: get role color ───────────────────────────────────────────
  static Color getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return const Color(0xFF2563EB);
      case 'manager':
        return const Color(0xFF7C3AED);
      case 'customer':
        return successColor;
      default:
        return const Color(0xFF6B7280);
    }
  }
}
