import 'dart:html' as html;
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Smart back navigation that mirrors the browser's native back button
/// behavior on web — keeps history clean (no duplicate entries) so that
/// chrome's back/forward buttons stay in sync with the in-app back button.
///
/// - On web: triggers `window.history.back()` directly so the browser
///   pops a single entry, exactly like clicking chrome's back arrow.
/// - On other platforms (or when no history is available): falls back to
///   `context.pop()` if poppable, otherwise navigates to [fallbackPath].
void smartBack(BuildContext context, String fallbackPath) {
  try {
    if (html.window.history.length > 1) {
      html.window.history.back();
      return;
    }
  } catch (_) {
    // Not on web (or history unavailable) — fall through to GoRouter.
  }

  if (context.canPop()) {
    context.pop();
  } else {
    context.go(fallbackPath);
  }
}
