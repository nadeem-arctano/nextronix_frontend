import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SecureTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final String? maskedValue;
  final bool isSet;
  final ValueChanged<String> onChanged;
  final IconData? icon;

  const SecureTextField({
    super.key,
    required this.label,
    required this.onChanged,
    this.hint,
    this.maskedValue,
    this.isSet = false,
    this.icon,
  });

  @override
  State<SecureTextField> createState() => _SecureTextFieldState();
}

class _SecureTextFieldState extends State<SecureTextField> {
  bool _obscure = true;
  bool _editing = false;
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            if (widget.icon != null) ...[
              Icon(
                widget.icon,
                size: 12,
                color: theme.colorScheme.mutedForeground,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              widget.label,
              style: theme.textTheme.small.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (widget.isSet) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'SET',
                  style: TextStyle(
                    fontSize: 9,
                    color: Color(0xFF10B981),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        if (widget.isSet && !_editing)
          // Saved state preview
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.border),
              borderRadius: BorderRadius.circular(8),
              color: theme.colorScheme.muted.withValues(alpha: 0.2),
            ),
            child: Row(
              children: [
                Icon(
                  LucideIcons.lock,
                  size: 14,
                  color: theme.colorScheme.mutedForeground,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.maskedValue ?? '••••••••',
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.foreground,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                if (widget.maskedValue != null)
                  IconButton(
                    icon: Icon(
                      LucideIcons.copy,
                      size: 14,
                      color: theme.colorScheme.mutedForeground,
                    ),
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: widget.maskedValue!),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Copied to clipboard'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                  ),
                IconButton(
                  icon: Icon(
                    LucideIcons.pencil,
                    size: 14,
                    color: theme.colorScheme.mutedForeground,
                  ),
                  onPressed: () => setState(() => _editing = true),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 28,
                    minHeight: 28,
                  ),
                ),
              ],
            ),
          )
        else
          Row(
            children: [
              Expanded(
                child: ShadInput(
                  controller: _controller,
                  obscureText: _obscure,
                  placeholder: Text(
                    widget.hint ?? 'Enter ${widget.label.toLowerCase()}',
                  ),
                  onChanged: widget.onChanged,
                  style: const TextStyle(fontSize: 13),
                  trailing: GestureDetector(
                    onTap: () => setState(() => _obscure = !_obscure),
                    child: Icon(
                      _obscure ? LucideIcons.eye : LucideIcons.eyeOff,
                      size: 14,
                      color: theme.colorScheme.mutedForeground,
                    ),
                  ),
                ),
              ),
              if (_editing) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    LucideIcons.x,
                    size: 14,
                    color: theme.colorScheme.mutedForeground,
                  ),
                  onPressed: () {
                    setState(() {
                      _editing = false;
                      _controller.clear();
                      widget.onChanged('');
                    });
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 28,
                    minHeight: 28,
                  ),
                ),
              ],
            ],
          ),
      ],
    );
  }
}
