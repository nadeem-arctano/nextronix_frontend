import '../../core/utils/parsers.dart';
import 'support_models.dart' show PaginationInfo;

class ReturnRequest {
  final int id;
  final String returnNumber;
  final int orderId;
  final int userId;
  final String? orderNumber;
  final double orderTotal;
  final String? customerName;
  final String? customerEmail;
  final String? customerMobile;
  final String? reason;
  final String? description;
  final String status;
  final double refundAmount;
  final String refundMethod;
  final String? adminRemark;
  final String? createdAt;
  final List<ReturnItem> items;

  ReturnRequest({
    this.id = 0,
    this.returnNumber = '',
    this.orderId = 0,
    this.userId = 0,
    this.orderNumber,
    this.orderTotal = 0,
    this.customerName,
    this.customerEmail,
    this.customerMobile,
    this.reason,
    this.description,
    this.status = 'requested',
    this.refundAmount = 0,
    this.refundMethod = 'original',
    this.adminRemark,
    this.createdAt,
    this.items = const [],
  });

  factory ReturnRequest.fromJson(Map<String, dynamic> json) => ReturnRequest(
    id: parseInt(json['id']),
    returnNumber: json['returnNumber']?.toString() ?? '',
    orderId: parseInt(json['orderId']),
    userId: parseInt(json['userId']),
    orderNumber: json['orderNumber']?.toString(),
    orderTotal: parseDouble(json['orderTotal']),
    customerName: json['customerName']?.toString(),
    customerEmail: json['customerEmail']?.toString(),
    customerMobile: json['customerMobile']?.toString(),
    reason: json['reason']?.toString(),
    description: json['description']?.toString(),
    status: json['status']?.toString() ?? 'requested',
    refundAmount: parseDouble(json['refundAmount']),
    refundMethod: json['refundMethod']?.toString() ?? 'original',
    adminRemark: json['adminRemark']?.toString(),
    createdAt: json['createdAt']?.toString(),
    items: json['items'] != null
        ? (json['items'] as List).map((e) => ReturnItem.fromJson(e)).toList()
        : [],
  );
}

class ReturnItem {
  final int id;
  final int productId;
  final String? productName;
  final int quantity;
  final String? thumbnailImage;
  final String? sku;

  ReturnItem({
    this.id = 0,
    this.productId = 0,
    this.productName,
    this.quantity = 1,
    this.thumbnailImage,
    this.sku,
  });

  factory ReturnItem.fromJson(Map<String, dynamic> json) => ReturnItem(
    id: parseInt(json['id']),
    productId: parseInt(json['productId']),
    productName: json['productName']?.toString(),
    quantity: parseInt(json['quantity'], defaultValue: 1),
    thumbnailImage: json['thumbnailImage']?.toString(),
    sku: json['sku']?.toString(),
  );
}

class ReturnListResponse {
  final List<ReturnRequest>? data;
  final PaginationInfo? pagination;

  ReturnListResponse({this.data, this.pagination});

  factory ReturnListResponse.fromJson(Map<String, dynamic> json) =>
      ReturnListResponse(
        data: json['data'] != null
            ? (json['data'] as List)
                  .map((e) => ReturnRequest.fromJson(e))
                  .toList()
            : null,
        pagination: json['pagination'] != null
            ? PaginationInfo.fromJson(json['pagination'])
            : null,
      );
}

class ReturnDetailResponse {
  final ReturnRequest? data;
  ReturnDetailResponse({this.data});
  factory ReturnDetailResponse.fromJson(Map<String, dynamic> json) =>
      ReturnDetailResponse(
        data: json['data'] != null
            ? ReturnRequest.fromJson(json['data'])
            : null,
      );
}

class ReturnStats {
  final int totalReturns;
  final int pendingReturns;
  final int approvedReturns;
  final int rejectedReturns;
  final int completedReturns;
  final double totalRefundAmount;
  final double pendingRefundAmount;

  ReturnStats({
    this.totalReturns = 0,
    this.pendingReturns = 0,
    this.approvedReturns = 0,
    this.rejectedReturns = 0,
    this.completedReturns = 0,
    this.totalRefundAmount = 0,
    this.pendingRefundAmount = 0,
  });

  factory ReturnStats.fromJson(Map<String, dynamic> json) => ReturnStats(
    totalReturns: parseInt(json['totalReturns']),
    pendingReturns: parseInt(json['pendingReturns']),
    approvedReturns: parseInt(json['approvedReturns']),
    rejectedReturns: parseInt(json['rejectedReturns']),
    completedReturns: parseInt(json['completedReturns']),
    totalRefundAmount: parseDouble(json['totalRefundAmount']),
    pendingRefundAmount: parseDouble(json['pendingRefundAmount']),
  );
}

class ReturnStatsResponse {
  final ReturnStats? data;
  ReturnStatsResponse({this.data});
  factory ReturnStatsResponse.fromJson(Map<String, dynamic> json) =>
      ReturnStatsResponse(
        data: json['data'] != null ? ReturnStats.fromJson(json['data']) : null,
      );
}
