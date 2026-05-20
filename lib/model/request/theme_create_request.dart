class ThemeCreateRequest {
  final String name;
  final String slug;
  final String mode;
  final Map<String, dynamic> themeConfig;
  final Map<String, dynamic>? previewConfig;
  final int? pairedThemeId;

  ThemeCreateRequest({
    required this.name,
    required this.slug,
    required this.mode,
    required this.themeConfig,
    this.previewConfig,
    this.pairedThemeId,
  });

  factory ThemeCreateRequest.fromJson(Map<String, dynamic> json) =>
      ThemeCreateRequest(
        name: json["name"],
        slug: json["slug"],
        mode: json["mode"],
        themeConfig: json["themeConfig"],
        previewConfig: json["previewConfig"],
        pairedThemeId: json["pairedThemeId"],
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name,
      'slug': slug,
      'mode': mode,
      'themeConfig': themeConfig,
    };
    if (previewConfig != null) map['previewConfig'] = previewConfig;
    if (pairedThemeId != null) map['pairedThemeId'] = pairedThemeId;
    return map;
  }
}
