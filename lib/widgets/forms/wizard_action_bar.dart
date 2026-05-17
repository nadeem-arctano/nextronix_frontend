import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Sticky bottom bar used by every wizard: Back on the left, current
/// position in the middle, primary action on the right.
///
/// The primary action shape is controlled by `isLast`:
///  - `false` → "Next" with right-arrow
///  - `true`  → submit button rendered with the icon + label provided
///
/// `isSubmitting` swaps the submit icon for a small spinner.
class WizardActionBar extends StatelessWidget {
  final int currentIndex;
  final int totalSteps;
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final VoidCallback? onSubmit;
  final bool isLast;
  final bool isSubmitting;
  final String submitLabel;
  final IconData submitIcon;

  const WizardActionBar({
    super.key,
    required this.currentIndex,
    required this.totalSteps,
    required this.onBack,
    required this.onNext,
    required this.onSubmit,
    required this.isLast,
    this.isSubmitting = false,
    this.submitLabel = 'Submit',
    this.submitIcon = LucideIcons.check,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        border: Border(top: BorderSide(color: theme.colorScheme.border)),
      ),
      child: Row(
        children: [
          // Hide Back entirely when there's nowhere to go (first step).
          if (onBack != null) ...[
            ShadButton.outline(
              leading: const Icon(LucideIcons.arrowLeft, size: 14),
              onPressed: onBack,
              child: const Text('Back'),
            ),
            const SizedBox(width: 8),
          ],
          Text(
            'Step ${currentIndex + 1} of $totalSteps',
            style: theme.textTheme.muted,
          ),
          const Spacer(),
          if (!isLast)
            ShadButton(
              trailing: const Icon(LucideIcons.arrowRight, size: 14),
              onPressed: onNext,
              child: const Text('Next'),
            )
          else
            ShadButton(
              leading: isSubmitting
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(submitIcon, size: 14),
              onPressed: isSubmitting ? null : onSubmit,
              child: Text(isSubmitting ? 'Saving...' : submitLabel),
            ),
        ],
      ),
    );
  }
}
