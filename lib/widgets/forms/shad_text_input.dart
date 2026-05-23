import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Consistent `TextFormField` styling used across all admin forms.
///
/// Wraps a Material `TextFormField` with the rounded 8px border, dense
/// padding, prefix / suffix slots, and validator support. Same look and
/// feel as the rest of the design system — no per-screen tweaking.
class ShadTextInput extends StatelessWidget {
  final TextEditingController controller;
  final String? hint;
  final String? prefix;
  final String? suffix;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final bool readOnly;
  final bool obscureText;

  const ShadTextInput({
    super.key,
    required this.controller,
    this.hint,
    this.prefix,
    this.suffix,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.validator,
    this.readOnly = false,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = const Color(0xFFE5E7EB);
    final errorColor = Theme.of(context).colorScheme.error;
    final defaultBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: borderColor),
    );
    final focusedDefault = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: borderColor),
    );
    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: errorColor),
    );

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        prefixText: prefix,
        suffixText: suffix,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: defaultBorder,
        enabledBorder: defaultBorder,
        focusedBorder: focusedDefault,
        errorBorder: errorBorder,
        focusedErrorBorder: errorBorder,
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      validator: validator,
      readOnly: readOnly,
      obscureText: obscureText,
    );
  }
}
