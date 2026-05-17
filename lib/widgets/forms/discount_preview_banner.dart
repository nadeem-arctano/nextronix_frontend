import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../core/theme/app_theme.dart';

/// Live banner that compares MRP and selling price.
///
/// - If selling > MRP → warning ("Selling price is higher than MRP")
/// - If discount > 0  → success badge with `% off` and ₹ savings
/// - Else (no diff or invalid input) → renders nothing
///
/// Drop-in widget; pass nullable doubles parsed from the form fields.
class DiscountPreviewBanner extends StatelessWidget {
  final double? mrp;
  final double? selling;

  const DiscountPreviewBanner({super.key, this.mrp, this.selling});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    if (mrp == null || selling == null || mrp! <= 0 || selling! <= 0) {
      return const SizedBox.shrink();
    }
    if (selling! > mrp!) {
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          children: const [
            Icon(
              LucideIcons.triangleAlert,
              size: 14,
              color: AppTheme.warningColor,
            ),
            SizedBox(width: 6),
            Text(
              'Selling price is higher than MRP',
              style: TextStyle(color: AppTheme.warningColor, fontSize: 12),
            ),
          ],
        ),
      );
    }
    final off = ((mrp! - selling!) / mrp! * 100).clamp(0, 100);
    if (off == 0) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.successColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          const Icon(
            LucideIcons.badgePercent,
            size: 14,
            color: AppTheme.successColor,
          ),
          const SizedBox(width: 6),
          Text(
            '${off.toStringAsFixed(0)}% off MRP — buyers save ₹${(mrp! - selling!).toStringAsFixed(2)}',
            style: const TextStyle(
              color: AppTheme.successColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            'Margin shown to buyer at checkout',
            style: theme.textTheme.muted.copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }
}
