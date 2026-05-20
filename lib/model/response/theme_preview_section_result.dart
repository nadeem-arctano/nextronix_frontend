import 'dart:convert';
import '../../core/utils/parsers.dart';

class ThemePreviewSectionResult {
  final int id;
  final int themeId;
  final String sectionKey;
  final String label;
  final int sortOrder;
  final Map<String, dynamic>? configOverride;

  ThemePreviewSectionResult({
    required this.id,
    required this.themeId,
    required this.sectionKey,
    required this.label,
    required this.sortOrder,
    this.configOverride,
  });

  factory ThemePreviewSectionResult.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? configOverride;
    final rawConfig = json['configOverride'];
    if (rawConfig != null) {
      if (rawConfig is Map<String, dynamic>) {
        configOverride = rawConfig;
      } else if (rawConfig is String && rawConfig.isNotEmpty) {
        try {
          final decoded = jsonDecode(rawConfig);
          if (decoded is Map<String, dynamic>) {
            configOverride = decoded;
          }
        } catch (_) {
          configOverride = null;
        }
      }
    }

    return ThemePreviewSectionResult(
      id: parseInt(json['id']),
      themeId: parseInt(json['themeId']),
      sectionKey: json['sectionKey']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      sortOrder: parseInt(json['sortOrder']),
      configOverride: configOverride,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "themeId": themeId,
    "sectionKey": sectionKey,
    "label": label,
    "sortOrder": sortOrder,
    "configOverride": configOverride,
  };
}
