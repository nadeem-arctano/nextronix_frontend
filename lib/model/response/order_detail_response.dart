import 'order_list_response.dart';

class OrderDetailResponse {
  final int? statusCode;
  final String? message;
  final OrderResult? data;

  OrderDetailResponse({this.statusCode, this.message, this.data});

  factory OrderDetailResponse.fromJson(Map<String, dynamic> json) =>
      OrderDetailResponse(
        statusCode: json["status_code"] ?? json["statusCode"],
        message: json["message"],
        data: json["data"] == null ? null : OrderResult.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "status_code": statusCode,
    "message": message,
    "data": data?.toJson(),
  };
}
