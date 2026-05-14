import 'coupon_list_response.dart';

class CouponDetailResponse {
  final int? statusCode;
  final String? message;
  final CouponResult? data;

  CouponDetailResponse({this.statusCode, this.message, this.data});

  factory CouponDetailResponse.fromJson(Map<String, dynamic> json) =>
      CouponDetailResponse(
        statusCode: json["status_code"] ?? json["statusCode"],
        message: json["message"],
        data: json["data"] == null ? null : CouponResult.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "status_code": statusCode,
    "message": message,
    "data": data?.toJson(),
  };
}
