class ThemeUpdateRequest {
  final String? name;
  final String? slug;
  final String? mode;
  final Map<String, dynamic>? themeConfig;
  final Map<String, dynamic>? previewConfig;
  final int? pairedThemeId;

  ThemeUpdateRequest({
    this.name,
    this.slug,
    this.mode,
    this.themeConfig,
    this.previewConfig,
    this.pairedThemeId,
  });

  factory ThemeUpdateRequest.fromJson(Map<String, dynamic> json) =>
      ThemeUpdateRequest(
        name: json["name"],
        slug: json["slug"],
        mode: json["mode"],
        themeConfig: json["themeConfig"],
        previewConfig: json["previewConfig"],
        pairedThemeId: json["pairedThemeId"],
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (name != null) map['name'] = name;
    if (slug != null) map['slug'] = slug;
    if (mode != null) map['mode'] = mode;
    if (themeConfig != null) map['themeConfig'] = themeConfig;
    if (previewConfig != null) map['previewConfig'] = previewConfig;
    if (pairedThemeId != null) map['pairedThemeId'] = pairedThemeId;
    return map;
  }
}
