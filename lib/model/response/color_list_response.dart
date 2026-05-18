import '../../core/utils/parsers.dart';

class ColorListResponse {
  final int? statusCode;
  final String? message;
  final List<ColorResult>? data;

  ColorListResponse({this.statusCode, this.message, this.data});

  factory ColorListResponse.fromJson(Map<String, dynamic> json) =>
      ColorListResponse(
        statusCode: json["status_code"] ?? json["statusCode"],
        message: json["message"],
        data: json["data"] == null
            ? null
            : List<ColorResult>.from(
                (json["data"] as List).map((e) => ColorResult.fromJson(e)),
              ),
      );
}

class ColorResult {
  final int? id;
  final String? name;
  final String? hexCode;
  final String? status;
  final String? createdAt;
  final String? updatedAt;

  ColorResult({
    this.id,
    this.name,
    this.hexCode,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory ColorResult.fromJson(Map<String, dynamic> json) => ColorResult(
    id: parseInt(json['id']),
    name: json['name']?.toString(),
    hexCode: json['hexCode']?.toString(),
    status: json['status']?.toString(),
    createdAt: json['createdAt']?.toString(),
    updatedAt: json['updatedAt']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "hexCode": hexCode,
    "status": status,
  };
}
