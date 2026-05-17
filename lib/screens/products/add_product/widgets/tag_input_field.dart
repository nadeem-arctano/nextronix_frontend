import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/theme/app_theme.dart';

/// Reusable "type → press Enter / Add → chip" input.
///
/// Used for adding Colors and Sizes on the variants step. Keeps the typed
/// list normalised (trimmed, deduped, max length capped) so the matrix
/// generator never gets garbage entries.
class TagInputField extends StatefulWidget {
  final String label;
  final String hintText;
  final String example;
  final List<String> values;
  final ValueChanged<List<String>> onChanged;
  final int maxTags;

  const TagInputField({
    super.key,
    required this.label,
    required this.hintText,
    required this.example,
    required this.values,
    required this.onChanged,
    this.maxTags = 12,
  });

  @override
  State<TagInputField> createState() => _TagInputFieldState();
}

class _TagInputFieldState extends State<TagInputField> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _add() {
    final raw = _controller.text.trim();
    if (raw.isEmpty) return;
    if (widget.values.length >= widget.maxTags) return;
    final lower = raw.toLowerCase();
    if (widget.values.map((v) => v.toLowerCase()).contains(lower)) {
      _controller.clear();
      return;
    }
    widget.onChanged([...widget.values, raw]);
    _controller.clear();
    _focus.requestFocus();
  }

  void _remove(String tag) {
    widget.onChanged(widget.values.where((v) => v != tag).toList());
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label column
          SizedBox(
            width: 100,
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                widget.label,
                style: theme.textTheme.small.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          // Input + Add
          SizedBox(
            width: 320,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focus,
                        onSubmitted: (_) => _add(),
                        decoration: InputDecoration(
                          hintText: widget.hintText,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ShadButton.outline(
                      onPressed: _add,
                      child: const Text('Add'),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Example: ${widget.example}',
                  style: theme.textTheme.muted.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          // Tag list
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.values
                    .map((v) => _TagChip(label: v, onRemove: () => _remove(v)))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;
  const _TagChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 4, top: 4, bottom: 4),
      decoration: BoxDecoration(
        color: AppTheme.brand.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.brand.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.small.copyWith(
              fontSize: 12,
              color: AppTheme.brand,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: Icon(LucideIcons.x, size: 12, color: AppTheme.brand),
            ),
          ),
        ],
      ),
    );
  }
}
