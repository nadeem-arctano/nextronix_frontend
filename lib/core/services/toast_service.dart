import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../theme/app_theme.dart';
import '../../model/response/response.dart';

/// Centralised toast helper. Use these instead of building SnackBar instances
/// in every screen — keeps tone, colours and sizing consistent.
///
/// `ToastService.success(context, 'Saved')`
/// `ToastService.error(context, 'Network failed')`
/// `ToastService.fromError(context, alertErrorResponse)`
class ToastService {
  ToastService._();

  static void _show(
    BuildContext context, {
    required String message,
    required Color color,
    required IconData icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger.removeCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        elevation: 6,
        duration: duration,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Row(
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void success(BuildContext context, String message) {
    _show(
      context,
      message: message,
      color: AppTheme.successColor,
      icon: LucideIcons.check,
    );
  }

  static void error(BuildContext context, String message) {
    _show(
      context,
      message: message,
      color: AppTheme.dangerColor,
      icon: LucideIcons.circleAlert,
      duration: const Duration(seconds: 5),
    );
  }

  static void info(BuildContext context, String message) {
    _show(
      context,
      message: message,
      color: AppTheme.infoColor,
      icon: LucideIcons.info,
    );
  }

  static void warning(BuildContext context, String message) {
    _show(
      context,
      message: message,
      color: AppTheme.warningColor,
      icon: LucideIcons.triangleAlert,
    );
  }

  /// Convenience wrapper: pulls a friendly message out of an
  /// AlertErrorResponse and shows it as an error toast.
  static void fromError(BuildContext context, AlertErrorResponse err) {
    error(context, err.alertMessage);
  }
}
