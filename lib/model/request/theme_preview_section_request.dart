class ThemePreviewSectionRequest {
  final String sectionKey;
  final String label;
  final int sortOrder;
  final Map<String, dynamic>? configOverride;

  ThemePreviewSectionRequest({
    required this.sectionKey,
    required this.label,
    required this.sortOrder,
    this.configOverride,
  });

  factory ThemePreviewSectionRequest.fromJson(Map<String, dynamic> json) =>
      ThemePreviewSectionRequest(
        sectionKey: json["sectionKey"],
        label: json["label"],
        sortOrder: json["sortOrder"],
        configOverride: json["configOverride"],
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'sectionKey': sectionKey,
      'label': label,
      'sortOrder': sortOrder,
    };
    if (configOverride != null) map['configOverride'] = configOverride;
    return map;
  }
}
