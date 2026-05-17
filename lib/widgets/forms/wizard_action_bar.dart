import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../core/theme/app_theme.dart';

/// Bottom action bar used by every wizard.
///
/// Layout
/// ──────
/// **Left**   – Cancel (always present, neutral outline button)
/// **Right**  – optional Save as draft + Next/Submit
///
/// The bar renders inline (no fixed positioning) so it sits at the end
/// of the page content and scrolls with everything else.
class WizardActionBar extends StatelessWidget {
  final VoidCallback? onCancel;
  final VoidCallback? onSaveDraft;
  final VoidCallback? onNext;
  final VoidCallback? onSubmit;
  final bool isLast;
  final bool isSubmitting;
  final bool isSavingDraft;
  final String submitLabel;
  final IconData submitIcon;

  const WizardActionBar({
    super.key,
    required this.onCancel,
    required this.onNext,
    required this.onSubmit,
    required this.isLast,
    this.onSaveDraft,
    this.isSubmitting = false,
    this.isSavingDraft = false,
    this.submitLabel = 'Submit',
    this.submitIcon = LucideIcons.check,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 16),
      child: Row(
        children: [
          // ─── Left: Cancel ─────────────────────────────────────────────
          ShadButton.outline(onPressed: onCancel, child: const Text('Cancel')),
          const Spacer(),
          // ─── Right: Save as draft + Next/Submit ───────────────────────
          if (onSaveDraft != null) ...[
            ShadButton.secondary(
              leading: isSavingDraft
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(LucideIcons.save, size: 14),
              onPressed: isSavingDraft ? null : onSaveDraft,
              child: Text(isSavingDraft ? 'Saving...' : 'Save as draft'),
            ),
            const SizedBox(width: 8),
          ],
          if (!isLast)
            ShadButton(
              backgroundColor: AppTheme.brand,
              trailing: const Icon(
                LucideIcons.arrowRight,
                size: 14,
                color: Colors.white,
              ),
              onPressed: onNext,
              child: const Text('Next', style: TextStyle(color: Colors.white)),
            )
          else
            ShadButton(
              backgroundColor: AppTheme.brand,
              leading: isSubmitting
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(submitIcon, size: 14, color: Colors.white),
              onPressed: isSubmitting ? null : onSubmit,
              child: Text(
                isSubmitting ? 'Submitting...' : submitLabel,
                style: const TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
