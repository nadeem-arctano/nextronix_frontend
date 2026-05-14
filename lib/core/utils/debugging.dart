import 'dart:developer';
import 'package:flutter/foundation.dart';

enum DebugColor { green, red, yellow }

class Debugging {
  static const String _reset = '\x1B[0m';
  static const Map<DebugColor, String> _colorMap = {
    DebugColor.green: '\x1B[32m',
    DebugColor.red: '\x1B[31m',
    DebugColor.yellow: '\x1B[33m',
  };

  /// Standard logging — string is evaluated before the call.
  /// Use [printingLazy] in hot paths (BLE/MQTT listeners) to avoid
  /// string-interpolation cost in release builds.
  static void printing({
    required String text,
    bool enableLog = false,
    String? tag,
    DebugColor color = DebugColor.green,
  }) {
    if (!kDebugMode) return;

    String message = text.contains('\n\n')
        ? '${tag ?? "Multi-line Debug:"}\n$text'
        : '${tag ?? "Debug"}: $text';

    final coloredMessage = '${_colorMap[color]}$message$_reset';

    if (enableLog) {
      log(coloredMessage);
    } else {
      debugPrint(coloredMessage);
    }
  }

  /// Lazy logging — the [textBuilder] callback is only invoked in debug mode,
  /// avoiding string interpolation cost in release builds.
  /// Use this in hot paths like BLE/MQTT stream listeners.
  static void printingLazy({
    required String Function() textBuilder,
    bool enableLog = false,
    String? tag,
    DebugColor color = DebugColor.green,
  }) {
    if (!kDebugMode) return;
    printing(text: textBuilder(), enableLog: enableLog, tag: tag, color: color);
  }
}
