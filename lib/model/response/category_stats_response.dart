import '../../core/utils/parsers.dart';

class CategoryStatsResponse {
  final int? statusCode;
  final String? message;
  final List<CategoryStatsResult>? data;

  CategoryStatsResponse({this.statusCode, this.message, this.data});

  factory CategoryStatsResponse.fromJson(Map<String, dynamic> json) =>
      CategoryStatsResponse(
        statusCode: json["status_code"] ?? json["statusCode"],
        message: json["message"],
        data: json["data"] == null
            ? null
            : List<CategoryStatsResult>.from(
                (json["data"] as List).map(
                  (e) => CategoryStatsResult.fromJson(e),
                ),
              ),
      );

  Map<String, dynamic> toJson() => {
    "status_code": statusCode,
    "message": message,
    "data": data?.map((e) => e.toJson()).toList(),
  };
}

class CategoryStatsResult {
  final int? id;
  final String? name;
  final int? productCount;
  final int? totalSales;
  final int? totalViews;

  CategoryStatsResult({
    this.id,
    this.name,
    this.productCount,
    this.totalSales,
    this.totalViews,
  });

  factory CategoryStatsResult.fromJson(Map<String, dynamic> json) =>
      CategoryStatsResult(
        id: parseInt(json['id']),
        name: json['name']?.toString(),
        productCount: parseInt(json['productCount']),
        totalSales: parseInt(json['totalSales']),
        totalViews: parseInt(json['totalViews']),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "productCount": productCount,
    "totalSales": totalSales,
    "totalViews": totalViews,
  };
}
