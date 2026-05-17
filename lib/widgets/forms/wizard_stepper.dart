import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../core/theme/app_theme.dart';

/// Single step descriptor for the wizard strip.
///
/// Generic across wizards (used by the Add Product flow today, ready to be
/// reused by any other multi-step screen we build later — kyc / onboarding
/// / order edit etc.).
class WizardStep {
  final String title;
  final String subtitle;
  final IconData icon;

  const WizardStep({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

/// Horizontal step strip with click-to-jump support.
///
/// - Active step      → brand colour, filled icon circle
/// - Completed step   → green check (any step before the active one is
///                      considered completed and remains tappable)
/// - Future step      → muted; tappable only when `canTap(index)` returns
///   `true` (default: every step is tappable). Locked steps render at
///   reduced opacity, show a small lock glyph, and use a "forbidden"
///   cursor on web.
class WizardStepper extends StatelessWidget {
  final List<WizardStep> steps;
  final int currentIndex;
  final ValueChanged<int> onTap;

  /// Optional gate. Past steps + the active step are always tappable
  /// regardless of what this returns.
  final bool Function(int index)? canTap;

  const WizardStepper({
    super.key,
    required this.steps,
    required this.currentIndex,
    required this.onTap,
    this.canTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.muted.withValues(alpha: 0.3),
        border: Border(bottom: BorderSide(color: theme.colorScheme.border)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: steps.asMap().entries.expand((e) {
            final idx = e.key;
            final step = e.value;
            // Past + current are always tappable. Future steps consult the
            // optional gate; if no gate is supplied they default to tappable
            // (preserves the old behaviour for callers that don't care).
            final tappable = idx <= currentIndex
                ? true
                : (canTap?.call(idx) ?? true);
            return [
              _StepChip(
                step: step,
                number: idx + 1,
                isActive: idx == currentIndex,
                isDone: idx < currentIndex,
                tappable: tappable,
                onTap: tappable ? () => onTap(idx) : null,
              ),
              if (idx < steps.length - 1)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Container(
                    width: 24,
                    height: 1,
                    color: theme.colorScheme.border,
                  ),
                ),
            ];
          }).toList(),
        ),
      ),
    );
  }
}

class _StepChip extends StatelessWidget {
  final WizardStep step;
  final int number;
  final bool isActive;
  final bool isDone;
  final bool tappable;
  final VoidCallback? onTap;

  const _StepChip({
    required this.step,
    required this.number,
    required this.isActive,
    required this.isDone,
    required this.tappable,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final accent = isActive
        ? AppTheme.brand
        : isDone
        ? AppTheme.successColor
        : theme.colorScheme.mutedForeground;

    final chip = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? AppTheme.brand
                  : isDone
                  ? AppTheme.successColor
                  : theme.colorScheme.background,
              border: Border.all(
                color: isActive
                    ? AppTheme.brand
                    : isDone
                    ? AppTheme.successColor
                    : theme.colorScheme.border,
              ),
            ),
            child: Center(
              child: isDone
                  ? const Icon(LucideIcons.check, size: 14, color: Colors.white)
                  : Icon(
                      step.icon,
                      size: 13,
                      color: isActive
                          ? Colors.white
                          : theme.colorScheme.mutedForeground,
                    ),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '$number. ',
                    style: theme.textTheme.muted.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    step.title,
                    style: TextStyle(
                      color: accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                step.subtitle,
                style: theme.textTheme.muted.copyWith(fontSize: 10),
              ),
            ],
          ),
          if (!tappable && !isActive && !isDone) ...[
            const SizedBox(width: 6),
            Icon(
              LucideIcons.lock,
              size: 11,
              color: theme.colorScheme.mutedForeground.withValues(alpha: 0.6),
            ),
          ],
        ],
      ),
    );

    if (!tappable) {
      // Locked: dim it and signal "no-go" via the cursor.
      return MouseRegion(
        cursor: SystemMouseCursors.forbidden,
        child: Opacity(opacity: 0.45, child: chip),
      );
    }
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: chip,
    );
  }
}
