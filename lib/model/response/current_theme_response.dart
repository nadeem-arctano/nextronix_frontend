import '../../core/utils/parsers.dart';
import 'theme_list_response.dart';

class CurrentThemeResponse {
  final int? statusCode;
  final String? message;
  final ThemeResult? theme;
  final bool isFallback;

  CurrentThemeResponse({
    this.statusCode,
    this.message,
    this.theme,
    required this.isFallback,
  });

  factory CurrentThemeResponse.fromJson(Map<String, dynamic> json) {
    // The theme data may be nested under "data" or "theme"
    final rawData = json['data'];
    ThemeResult? theme;
    bool isFallback = false;

    if (rawData != null && rawData is Map<String, dynamic>) {
      // Check if data contains "theme" key (nested structure)
      if (rawData.containsKey('theme') &&
          rawData['theme'] is Map<String, dynamic>) {
        theme = ThemeResult.fromJson(rawData['theme']);
        isFallback = parseBool(rawData['isFallback']);
      } else {
        // data IS the theme directly
        theme = ThemeResult.fromJson(rawData);
        isFallback = parseBool(json['isFallback']);
      }
    }

    return CurrentThemeResponse(
      statusCode: json["status_code"] ?? json["statusCode"],
      message: json["message"],
      theme: theme,
      isFallback: isFallback,
    );
  }

  Map<String, dynamic> toJson() => {
    "status_code": statusCode,
    "message": message,
    "data": {"theme": theme?.toJson(), "isFallback": isFallback},
  };
}
