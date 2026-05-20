import 'theme_list_response.dart';
import 'theme_preview_section_result.dart';

class ThemeDetailResponse {
  final int? statusCode;
  final String? message;
  final ThemeResult? data;
  final List<ThemePreviewSectionResult>? previewSections;

  ThemeDetailResponse({
    this.statusCode,
    this.message,
    this.data,
    this.previewSections,
  });

  factory ThemeDetailResponse.fromJson(Map<String, dynamic> json) {
    // The API may nest previewSections inside data or at the top level
    final rawData = json['data'];
    ThemeResult? theme;
    List<ThemePreviewSectionResult>? sections;

    if (rawData != null && rawData is Map<String, dynamic>) {
      theme = ThemeResult.fromJson(rawData);
      // Preview sections may come from the theme data itself
      sections = theme.previewSections;
    }

    // Also check top-level previewSections
    final rawSections = json['previewSections'];
    if (rawSections != null && rawSections is List) {
      sections = rawSections
          .map((e) => ThemePreviewSectionResult.fromJson(e))
          .toList();
    }

    return ThemeDetailResponse(
      statusCode: json["status_code"] ?? json["statusCode"],
      message: json["message"],
      data: theme,
      previewSections: sections,
    );
  }

  Map<String, dynamic> toJson() => {
    "status_code": statusCode,
    "message": message,
    "data": data?.toJson(),
    "previewSections": previewSections?.map((e) => e.toJson()).toList(),
  };
}
