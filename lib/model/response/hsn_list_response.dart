import '../../core/utils/parsers.dart';

class HsnListResponse {
  final int? statusCode;
  final String? message;
  final List<HsnResult>? data;

  HsnListResponse({this.statusCode, this.message, this.data});

  factory HsnListResponse.fromJson(Map<String, dynamic> json) =>
      HsnListResponse(
        statusCode: json["status_code"] ?? json["statusCode"],
        message: json["message"],
        data: json["data"] == null
            ? null
            : List<HsnResult>.from(
                (json["data"] as List).map((e) => HsnResult.fromJson(e)),
              ),
      );
}

class HsnResult {
  final int? id;
  final String? hsnCode;
  final double? gstPercent;
  final String? description;
  final String? createdAt;

  HsnResult({
    this.id,
    this.hsnCode,
    this.gstPercent,
    this.description,
    this.createdAt,
  });

  factory HsnResult.fromJson(Map<String, dynamic> json) => HsnResult(
    id: parseInt(json['id']),
    hsnCode: json['hsnCode']?.toString(),
    gstPercent: parseDouble(json['gstPercent']),
    description: json['description']?.toString(),
    createdAt: json['createdAt']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "hsnCode": hsnCode,
    "gstPercent": gstPercent,
    "description": description,
  };

  /// Display label for dropdown
  String get displayLabel =>
      '$hsnCode - ${description ?? ''} (${gstPercent?.toStringAsFixed(0)}% GST)';
}
