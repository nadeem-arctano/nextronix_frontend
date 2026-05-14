class CouponRequest {
  final String? code;
  final String? discountType;
  final double? discountValue;
  final double? minOrderAmount;
  final String? expiryDate;
  final int? usageLimit;
  final String? status;

  CouponRequest({
    this.code,
    this.discountType,
    this.discountValue,
    this.minOrderAmount,
    this.expiryDate,
    this.usageLimit,
    this.status,
  });

  factory CouponRequest.fromJson(Map<String, dynamic> json) => CouponRequest(
    code: json["code"],
    discountType: json["discountType"],
    discountValue: json["discountValue"]?.toDouble(),
    minOrderAmount: json["minOrderAmount"]?.toDouble(),
    expiryDate: json["expiryDate"],
    usageLimit: json["usageLimit"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (code != null) map["code"] = code;
    if (discountType != null) map["discountType"] = discountType;
    if (discountValue != null) map["discountValue"] = discountValue;
    if (minOrderAmount != null) map["minOrderAmount"] = minOrderAmount;
    if (expiryDate != null) map["expiryDate"] = expiryDate;
    if (usageLimit != null) map["usageLimit"] = usageLimit;
    if (status != null) map["status"] = status;
    return map;
  }
}
