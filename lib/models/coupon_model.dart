import '../core/utils/parsers.dart';

class CouponModel {
  final int id;
  final String code;
  final String discountType;
  final double discountValue;
  final double minOrderAmount;
  final String? expiryDate;
  final int usageLimit;
  final int usedCount;
  final String status;
  final String? createdAt;
  final String? updatedAt;

  CouponModel({
    required this.id,
    required this.code,
    required this.discountType,
    required this.discountValue,
    this.minOrderAmount = 0,
    this.expiryDate,
    this.usageLimit = 0,
    this.usedCount = 0,
    this.status = 'active',
    this.createdAt,
    this.updatedAt,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      id: parseInt(json['id']),
      code: json['code']?.toString() ?? '',
      discountType: json['discountType']?.toString() ?? 'percentage',
      discountValue: parseDouble(json['discountValue']),
      minOrderAmount: parseDouble(json['minOrderAmount']),
      expiryDate: json['expiryDate']?.toString(),
      usageLimit: parseInt(json['usageLimit']),
      usedCount: parseInt(json['usedCount']),
      status: json['status']?.toString() ?? 'active',
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  bool get isExpired => status == 'expired';
  bool get isActive => status == 'active';
  bool get hasUsageLimit => usageLimit > 0;
  bool get isUsageLimitReached => hasUsageLimit && usedCount >= usageLimit;

  String get discountDisplay => discountType == 'percentage'
      ? '${discountValue.toStringAsFixed(0)}%'
      : '₹${discountValue.toStringAsFixed(0)}';
}
