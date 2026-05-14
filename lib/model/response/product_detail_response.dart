import 'product_list_response.dart';

class ProductDetailResponse {
  final int? statusCode;
  final String? message;
  final ProductResult? data;

  ProductDetailResponse({this.statusCode, this.message, this.data});

  factory ProductDetailResponse.fromJson(Map<String, dynamic> json) =>
      ProductDetailResponse(
        statusCode: json["status_code"] ?? json["statusCode"],
        message: json["message"],
        data: json["data"] == null
            ? null
            : ProductResult.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "status_code": statusCode,
    "message": message,
    "data": data?.toJson(),
  };
}
