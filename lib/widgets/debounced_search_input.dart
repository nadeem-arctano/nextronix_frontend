import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// A reusable search input that automatically debounces user input and
/// dispatches the (trimmed) value to [onSearch] after [debounce] elapses.
///
/// Used to replace the duplicated debounce-timer + ShadInput pattern that
/// existed across the products, users, returns, support and admins screens.
///
/// Behavior:
///   * Calls [onSearch] with `null` when the trimmed value is empty.
///   * Calls [onSearch] immediately when the user submits (Enter key).
///   * Cancels any pending debounce on dispose.
///
/// Example:
/// ```dart
/// DebouncedSearchInput(
///   placeholder: 'Search products...',
///   onSearch: (q) => provider.setSearch(q),
/// )
/// ```
class DebouncedSearchInput extends StatefulWidget {
  /// Called with the trimmed search value. Emits `null` for empty input.
  final ValueChanged<String?> onSearch;

  /// Optional external controller. If not provided, an internal one is used.
  final TextEditingController? controller;

  /// Placeholder shown when the field is empty.
  final String placeholder;

  /// Field width. Defaults to 260 (matching products screen).
  final double width;

  /// Debounce duration. Defaults to 500ms (matching products screen).
  final Duration debounce;

  /// Initial value to seed the input.
  final String? initialValue;

  /// Optional autofocus.
  final bool autofocus;

  const DebouncedSearchInput({
    super.key,
    required this.onSearch,
    this.controller,
    this.placeholder = 'Search...',
    this.width = 260,
    this.debounce = const Duration(milliseconds: 500),
    this.initialValue,
    this.autofocus = false,
  });

  @override
  State<DebouncedSearchInput> createState() => _DebouncedSearchInputState();
}

class _DebouncedSearchInputState extends State<DebouncedSearchInput> {
  late final TextEditingController _controller;
  bool _ownsController = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController(text: widget.initialValue);
      _ownsController = true;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _scheduleDebounced(String value) {
    _timer?.cancel();
    _timer = Timer(widget.debounce, () {
      final trimmed = value.trim();
      widget.onSearch(trimmed.isEmpty ? null : trimmed);
    });
  }

  void _emitImmediate(String value) {
    _timer?.cancel();
    final trimmed = value.trim();
    widget.onSearch(trimmed.isEmpty ? null : trimmed);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: ShadInput(
        controller: _controller,
        placeholder: Text(widget.placeholder),
        style: const TextStyle(fontSize: 12),
        autofocus: widget.autofocus,
        leading: const Padding(
          padding: EdgeInsets.only(left: 8),
          child: Icon(LucideIcons.search, size: 14),
        ),
        onSubmitted: _emitImmediate,
        onChanged: (value) {
          // Trigger a rebuild so the optional clear icon updates if the
          // surrounding screen reads `controller.text`.
          setState(() {});
          _scheduleDebounced(value);
        },
        trailing: _controller.text.isEmpty
            ? null
            : GestureDetector(
                onTap: () {
                  _controller.clear();
                  _emitImmediate('');
                  setState(() {});
                },
                child: const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Icon(LucideIcons.x, size: 14),
                ),
              ),
      ),
    );
  }
}
