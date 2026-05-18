import '../../core/utils/parsers.dart';

class MaterialListResponse {
  final int? statusCode;
  final String? message;
  final List<MaterialResult>? data;

  MaterialListResponse({this.statusCode, this.message, this.data});

  factory MaterialListResponse.fromJson(Map<String, dynamic> json) =>
      MaterialListResponse(
        statusCode: json["status_code"] ?? json["statusCode"],
        message: json["message"],
        data: json["data"] == null
            ? null
            : List<MaterialResult>.from(
                (json["data"] as List).map((e) => MaterialResult.fromJson(e)),
              ),
      );
}

class MaterialResult {
  final int? id;
  final String? name;
  final String? description;
  final String? status;
  final String? createdAt;
  final String? updatedAt;

  MaterialResult({
    this.id,
    this.name,
    this.description,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory MaterialResult.fromJson(Map<String, dynamic> json) => MaterialResult(
    id: parseInt(json['id']),
    name: json['name']?.toString(),
    description: json['description']?.toString(),
    status: json['status']?.toString(),
    createdAt: json['createdAt']?.toString(),
    updatedAt: json['updatedAt']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
    "status": status,
  };
}
