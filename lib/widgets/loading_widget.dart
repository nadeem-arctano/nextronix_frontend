import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  const LoadingWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(width: 200, child: ShadProgress()),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!, style: theme.textTheme.muted),
          ],
        ],
      ),
    );
  }
}

class ErrorWidget2 extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorWidget2({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.circleAlert,
            size: 40,
            color: theme.colorScheme.destructive,
          ),
          const SizedBox(height: 12),
          Text(message, style: theme.textTheme.muted),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ShadButton.outline(
              leading: const Icon(LucideIcons.refreshCw, size: 14),
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
}

class EmptyWidget extends StatelessWidget {
  final String message;
  final IconData icon;

  const EmptyWidget({
    super.key,
    this.message = 'No data found',
    this.icon = LucideIcons.inbox,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: theme.colorScheme.mutedForeground),
          const SizedBox(height: 12),
          Text(message, style: theme.textTheme.muted),
        ],
      ),
    );
  }
}
