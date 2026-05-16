import '../../core/utils/parsers.dart';
import 'support_models.dart' show PaginationInfo;

class InventoryLog {
  final int id;
  final int? adminId;
  final int? productId;
  final int? variantId;
  final int previousStock;
  final int newStock;
  final int quantityChanged;
  final String reason;
  final String? note;
  final int? userId;
  final String? referenceType;
  final int? referenceId;
  final String? createdAt;
  // Joined fields
  final String? productName;
  final String? productSku;
  final String? productThumbnail;
  final String? variantName;
  final String? variantSku;
  final String? userName;
  final String? userEmail;

  InventoryLog({
    required this.id,
    this.adminId,
    this.productId,
    this.variantId,
    this.previousStock = 0,
    this.newStock = 0,
    this.quantityChanged = 0,
    required this.reason,
    this.note,
    this.userId,
    this.referenceType,
    this.referenceId,
    this.createdAt,
    this.productName,
    this.productSku,
    this.productThumbnail,
    this.variantName,
    this.variantSku,
    this.userName,
    this.userEmail,
  });

  factory InventoryLog.fromJson(Map<String, dynamic> json) => InventoryLog(
    id: parseInt(json['id']),
    adminId: json['adminId'] != null ? parseInt(json['adminId']) : null,
    productId: json['productId'] != null ? parseInt(json['productId']) : null,
    variantId: json['variantId'] != null ? parseInt(json['variantId']) : null,
    previousStock: parseInt(json['previousStock']),
    newStock: parseInt(json['newStock']),
    quantityChanged: parseInt(json['quantityChanged']),
    reason: json['reason']?.toString() ?? '',
    note: json['note']?.toString(),
    userId: json['userId'] != null ? parseInt(json['userId']) : null,
    referenceType: json['referenceType']?.toString(),
    referenceId: json['referenceId'] != null
        ? parseInt(json['referenceId'])
        : null,
    createdAt: json['createdAt']?.toString(),
    productName: json['productName']?.toString(),
    productSku: json['productSku']?.toString(),
    productThumbnail: json['productThumbnail']?.toString(),
    variantName: json['variantName']?.toString(),
    variantSku: json['variantSku']?.toString(),
    userName: json['userName']?.toString(),
    userEmail: json['userEmail']?.toString(),
  );
}

class InventoryLogListResponse {
  final bool? success;
  final String? message;
  final List<InventoryLog>? data;
  final PaginationInfo? pagination;

  InventoryLogListResponse({
    this.success,
    this.message,
    this.data,
    this.pagination,
  });

  factory InventoryLogListResponse.fromJson(Map<String, dynamic> json) =>
      InventoryLogListResponse(
        success: json['success'],
        message: json['message']?.toString(),
        data: json['data'] != null
            ? (json['data'] as List)
                  .map((e) => InventoryLog.fromJson(e))
                  .toList()
            : null,
        pagination: json['pagination'] != null
            ? PaginationInfo.fromJson(json['pagination'])
            : null,
      );
}

class InventoryLogHistoryResponse {
  final bool? success;
  final String? message;
  final List<InventoryLog>? data;

  InventoryLogHistoryResponse({this.success, this.message, this.data});

  factory InventoryLogHistoryResponse.fromJson(Map<String, dynamic> json) =>
      InventoryLogHistoryResponse(
        success: json['success'],
        message: json['message']?.toString(),
        data: json['data'] != null
            ? (json['data'] as List)
                  .map((e) => InventoryLog.fromJson(e))
                  .toList()
            : null,
      );
}
