import 'package:flutter/material.dart';

/// Renders a ticket priority as a colored text label.
///
/// Earlier versions wrapped the text in a tinted/bordered box; we now show
/// just the colored text so dense tables (e.g. support list) feel lighter.
/// Use the `boxed` constructor flag if a future caller needs the old style
/// back without forking the widget.
class PriorityBadge extends StatelessWidget {
  final String priority;

  /// When `true`, renders the legacy boxed look (tinted background + border).
  /// Defaults to `false` — colored text only.
  final bool boxed;

  const PriorityBadge({super.key, required this.priority, this.boxed = false});

  @override
  Widget build(BuildContext context) {
    final color = _color(priority);
    final text = Text(
      priority.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: 0.5,
      ),
    );

    if (!boxed) return text;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: text,
    );
  }

  Color _color(String p) {
    switch (p.toLowerCase()) {
      case 'urgent':
        return const Color(0xFFDC2626);
      case 'high':
        return const Color(0xFFEA580C);
      case 'medium':
        return const Color(0xFF2563EB);
      case 'low':
      default:
        return const Color(0xFF6B7280);
    }
  }
}
