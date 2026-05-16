import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SettingsTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final String? value;
  final ValueChanged<String> onChanged;
  final IconData? icon;
  final bool isRequired;
  final TextInputType? keyboardType;
  final int? maxLines;
  final int? maxLength;
  final List<String>? autofillHints;

  const SettingsTextField({
    super.key,
    required this.label,
    required this.onChanged,
    this.hint,
    this.value,
    this.icon,
    this.isRequired = false,
    this.keyboardType,
    this.maxLines = 1,
    this.maxLength,
    this.autofillHints,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 12, color: theme.colorScheme.mutedForeground),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: theme.textTheme.small.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: TextStyle(color: theme.colorScheme.destructive),
              ),
          ],
        ),
        const SizedBox(height: 6),
        ShadInput(
          initialValue: value,
          placeholder: Text(hint ?? ''),
          keyboardType: keyboardType,
          maxLines: maxLines,
          maxLength: maxLength,
          onChanged: onChanged,
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );
  }
}
