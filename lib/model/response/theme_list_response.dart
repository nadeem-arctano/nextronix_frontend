import 'dart:convert';
import '../../core/utils/parsers.dart';
import 'product_list_response.dart';
import 'theme_preview_section_result.dart';

class ThemeListResponse {
  final int? statusCode;
  final String? message;
  final List<ThemeResult>? data;
  final PaginationResult? pagination;

  ThemeListResponse({
    this.statusCode,
    this.message,
    this.data,
    this.pagination,
  });

  factory ThemeListResponse.fromJson(Map<String, dynamic> json) =>
      ThemeListResponse(
        statusCode: json["status_code"] ?? json["statusCode"],
        message: json["message"],
        data: json["data"] == null
            ? null
            : List<ThemeResult>.from(
                (json["data"] as List).map((e) => ThemeResult.fromJson(e)),
              ),
        pagination: json["pagination"] == null
            ? null
            : PaginationResult.fromJson(json["pagination"]),
      );

  Map<String, dynamic> toJson() => {
    "status_code": statusCode,
    "message": message,
    "data": data?.map((e) => e.toJson()).toList(),
    "pagination": pagination?.toJson(),
  };
}

class ThemeResult {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final String mode;
  final int? pairedThemeId;
  final Map<String, dynamic> themeConfig;
  final Map<String, dynamic>? previewConfig;
  final String? previewImage;
  final bool isPermanent;
  final bool isDefault;
  final bool isActive;
  final List<ThemePreviewSectionResult>? previewSections;
  final String? createdAt;
  final String? updatedAt;

  ThemeResult({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    required this.mode,
    this.pairedThemeId,
    required this.themeConfig,
    this.previewConfig,
    this.previewImage,
    required this.isPermanent,
    required this.isDefault,
    required this.isActive,
    this.previewSections,
    this.createdAt,
    this.updatedAt,
  });

  factory ThemeResult.fromJson(Map<String, dynamic> json) {
    // Parse themeConfig — can be JSON string or Map
    Map<String, dynamic> themeConfig = {};
    final rawThemeConfig = json['themeConfig'];
    if (rawThemeConfig != null) {
      if (rawThemeConfig is Map<String, dynamic>) {
        themeConfig = rawThemeConfig;
      } else if (rawThemeConfig is String && rawThemeConfig.isNotEmpty) {
        try {
          final decoded = jsonDecode(rawThemeConfig);
          if (decoded is Map<String, dynamic>) {
            themeConfig = decoded;
          }
        } catch (_) {}
      }
    }

    // Parse previewConfig — can be JSON string or Map
    Map<String, dynamic>? previewConfig;
    final rawPreviewConfig = json['previewConfig'];
    if (rawPreviewConfig != null) {
      if (rawPreviewConfig is Map<String, dynamic>) {
        previewConfig = rawPreviewConfig;
      } else if (rawPreviewConfig is String && rawPreviewConfig.isNotEmpty) {
        try {
          final decoded = jsonDecode(rawPreviewConfig);
          if (decoded is Map<String, dynamic>) {
            previewConfig = decoded;
          }
        } catch (_) {
          previewConfig = null;
        }
      }
    }

    // Parse previewSections list
    List<ThemePreviewSectionResult>? previewSections;
    final rawSections = json['previewSections'];
    if (rawSections != null && rawSections is List) {
      previewSections = rawSections
          .map((e) => ThemePreviewSectionResult.fromJson(e))
          .toList();
    }

    return ThemeResult(
      id: parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString(),
      mode: json['mode']?.toString() ?? 'light',
      pairedThemeId: json['pairedThemeId'] != null
          ? parseInt(json['pairedThemeId'])
          : null,
      themeConfig: themeConfig,
      previewConfig: previewConfig,
      previewImage: json['previewImage']?.toString(),
      isPermanent: parseBool(json['isPermanent']),
      isDefault: parseBool(json['isDefault']),
      isActive: parseBool(json['isActive']),
      previewSections: previewSections,
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "slug": slug,
    "description": description,
    "mode": mode,
    "pairedThemeId": pairedThemeId,
    "themeConfig": themeConfig,
    "previewConfig": previewConfig,
    "previewImage": previewImage,
    "isPermanent": isPermanent,
    "isDefault": isDefault,
    "isActive": isActive,
    "previewSections": previewSections?.map((e) => e.toJson()).toList(),
    "createdAt": createdAt,
    "updatedAt": updatedAt,
  };
}
