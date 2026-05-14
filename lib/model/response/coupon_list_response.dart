import '../../core/utils/parsers.dart';

class CouponListResponse {
  final int? statusCode;
  final String? message;
  final List<CouponResult>? data;

  CouponListResponse({this.statusCode, this.message, this.data});

  factory CouponListResponse.fromJson(Map<String, dynamic> json) =>
      CouponListResponse(
        statusCode: json["status_code"] ?? json["statusCode"],
        message: json["message"],
        data: json["data"] == null
            ? null
            : List<CouponResult>.from(
                (json["data"] as List).map((e) => CouponResult.fromJson(e)),
              ),
      );

  Map<String, dynamic> toJson() => {
    "status_code": statusCode,
    "message": message,
    "data": data?.map((e) => e.toJson()).toList(),
  };
}

class CouponResult {
  final int? id;
  final String? code;
  final String? discountType;
  final double? discountValue;
  final double? minOrderAmount;
  final String? expiryDate;
  final int? usageLimit;
  final int? usedCount;
  final String? status;
  final String? createdAt;
  final String? updatedAt;

  CouponResult({
    this.id,
    this.code,
    this.discountType,
    this.discountValue,
    this.minOrderAmount,
    this.expiryDate,
    this.usageLimit,
    this.usedCount,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory CouponResult.fromJson(Map<String, dynamic> json) => CouponResult(
    id: parseInt(json['id']),
    code: json['code']?.toString(),
    discountType: json['discountType']?.toString(),
    discountValue: parseDouble(json['discountValue']),
    minOrderAmount: parseDouble(json['minOrderAmount']),
    expiryDate: json['expiryDate']?.toString(),
    usageLimit: parseInt(json['usageLimit']),
    usedCount: parseInt(json['usedCount']),
    status: json['status']?.toString() ?? 'active',
    createdAt: json['createdAt']?.toString(),
    updatedAt: json['updatedAt']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "code": code,
    "discountType": discountType,
    "discountValue": discountValue,
    "minOrderAmount": minOrderAmount,
    "expiryDate": expiryDate,
    "usageLimit": usageLimit,
    "usedCount": usedCount,
    "status": status,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
  };

  bool get isExpired => status == 'expired';
  bool get isActive => status == 'active';

  String get discountDisplay => discountType == 'percentage'
      ? '${discountValue?.toStringAsFixed(0)}%'
      : '₹${discountValue?.toStringAsFixed(0)}';
}
