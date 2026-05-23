import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:google_fonts/google_fonts.dart';

/// Nextronix Design System
/// Modern, clean admin dashboard theme with Poppins font
class AppTheme {
  AppTheme._();

  // ─── Brand Colors ─────────────────────────────────────────────────────
  static const Color brand = Color(0xFF6366F1); // Indigo
  static const Color brandLight = Color(0xFF818CF8);
  static const Color brandDark = Color(0xFF4F46E5);

  // ─── Semantic Colors ──────────────────────────────────────────────────
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color dangerColor = Color(0xFFEF4444);
  static const Color infoColor = Color(0xFF06B6D4);

  // ─── Legacy compat ────────────────────────────────────────────────────
  static const Color borderColor = Color(0xFFE5E7EB);
  static const Color bgColor = Color(0xFFF9FAFB);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color primaryColor = Color(0xFF6366F1);

  // ─── Sidebar ──────────────────────────────────────────────────────────
  static const Color sidebarBg = Color(0xFF0F172A);
  static const Color sidebarColor = Color(0xFF0F172A);
  static const Color sidebarActiveColor = Color(0xFF1E293B);
  static const Color sidebarHover = Color(0xFF1E293B);

  // ─── Light Theme ──────────────────────────────────────────────────────
  static ShadThemeData lightTheme = ShadThemeData(
    brightness: Brightness.light,
    colorScheme: const ShadZincColorScheme.light(),
    textTheme: ShadTextTheme.fromGoogleFont(GoogleFonts.poppins),
    inputTheme: ShadInputTheme(
      decoration: ShadDecoration(
        border: ShadBorder.all(
          color: Color(0xFFE5E7EB),
          width: 1,
          radius: BorderRadius.circular(8),
        ),
        secondaryBorder: ShadBorder.none,
        focusedBorder: ShadBorder.all(
          color: Color(0xFFE5E7EB),
          width: 1,
          radius: BorderRadius.circular(8),
        ),
        errorBorder: ShadBorder.all(
          color: dangerColor,
          width: 1,
          radius: BorderRadius.circular(8),
        ),
        secondaryErrorBorder: ShadBorder.none,
      ),
    ),
    selectTheme: ShadSelectTheme(
      decoration: ShadDecoration(
        border: ShadBorder.all(
          color: Color(0xFFE5E7EB),
          width: 1,
          radius: BorderRadius.circular(8),
        ),
        secondaryBorder: ShadBorder.none,
        focusedBorder: ShadBorder.all(
          color: Color(0xffe4e4e7),
          width: 1,
          radius: BorderRadius.circular(8),
        ),
      ),
    ),
  );

  // ─── Dark Theme ───────────────────────────────────────────────────────
  static ShadThemeData darkTheme = ShadThemeData(
    brightness: Brightness.dark,
    colorScheme: const ShadZincColorScheme.dark(),
    textTheme: ShadTextTheme.fromGoogleFont(GoogleFonts.poppins),
    inputTheme: ShadInputTheme(
      decoration: ShadDecoration(
        border: ShadBorder.all(
          color: const Color(0xFF374151),
          width: 1,
          radius: BorderRadius.circular(8),
        ),
        secondaryBorder: ShadBorder.none,
        focusedBorder: ShadBorder.all(
          color: const Color(0xFF374151),
          width: 1,
          radius: BorderRadius.circular(8),
        ),
        errorBorder: ShadBorder.all(
          color: dangerColor,
          width: 1,
          radius: BorderRadius.circular(8),
        ),
        secondaryErrorBorder: ShadBorder.none,
      ),
    ),
    selectTheme: ShadSelectTheme(
      decoration: ShadDecoration(
        border: ShadBorder.all(
          color: const Color(0xFF374151),
          width: 1,
          radius: BorderRadius.circular(8),
        ),
        secondaryBorder: ShadBorder.none,
        focusedBorder: ShadBorder.all(
          color: const Color(0xFF818CF8).withValues(alpha: 0.4),
          width: 1,
          radius: BorderRadius.circular(8),
        ),
      ),
    ),
  );

  // ─── Helpers ──────────────────────────────────────────────────────────
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
        return brand;
      case 'returned':
      case 'refunded':
        return Colors.orange;
      default:
        return const Color(0xFF6B7280);
    }
  }

  static Color getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return brand;
      case 'manager':
        return const Color(0xFF7C3AED);
      case 'customer':
        return successColor;
      default:
        return const Color(0xFF6B7280);
    }
  }
}
