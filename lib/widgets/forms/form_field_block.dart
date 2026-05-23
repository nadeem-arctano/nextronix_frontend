import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../core/theme/app_theme.dart';

/// Wraps a form control with a consistent label / required-asterisk / hint.
///
/// Use this anywhere you'd otherwise hand-roll a label-then-input column —
/// it keeps spacing and typography uniform across the app.
///
/// ```dart
/// FormFieldBlock(
///   label: 'Selling price',
///   required: true,
///   hint: 'What buyers actually pay.',
///   child: TextFormField(...),
/// )
/// ```
class FormFieldBlock extends StatelessWidget {
  final String label;
  final String? hint;
  final bool required;
  final Widget child;

  const FormFieldBlock({
    super.key,
    required this.label,
    this.hint,
    this.required = false,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fixed-height label row so required/optional fields stay aligned
          // when used side-by-side in a grid.
          SizedBox(
            height: 18,
            child: Row(
              children: [
                Text(
                  label,
                  style: theme.textTheme.small.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
                if (required) ...[
                  const SizedBox(width: 4),
                  const Text(
                    '*',
                    style: TextStyle(color: AppTheme.dangerColor, height: 1.2),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 6),
          child,
          if (hint != null) ...[
            const SizedBox(height: 4),
            Text(hint!, style: theme.textTheme.muted.copyWith(fontSize: 11)),
          ],
        ],
      ),
    );
  }
}
