class ThemeSelectRequest {
  final int themeId;

  ThemeSelectRequest({required this.themeId});

  factory ThemeSelectRequest.fromJson(Map<String, dynamic> json) =>
      ThemeSelectRequest(themeId: json["themeId"]);

  Map<String, dynamic> toJson() => {'themeId': themeId};
}
