import 'order_list_response.dart';
import 'address_model.dart';
import 'payment_result.dart';

class OrderDetailResponse {
  final int? statusCode;
  final String? message;
  final OrderDetailResult? data;

  OrderDetailResponse({this.statusCode, this.message, this.data});

  factory OrderDetailResponse.fromJson(Map<String, dynamic> json) =>
      OrderDetailResponse(
        statusCode: json["status_code"] ?? json["statusCode"],
        message: json["message"],
        data: json["data"] == null
            ? null
            : OrderDetailResult.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "status_code": statusCode,
    "message": message,
    "data": data?.toJson(),
  };
}

class OrderDetailResult extends OrderResult {
  final AddressResult? shippingAddress;
  final List<PaymentResult>? payments;

  OrderDetailResult({
    super.id,
    super.userId,
    super.orderNumber,
    super.subtotal,
    super.gstAmount,
    super.shippingCharge,
    super.discountAmount,
    super.totalAmount,
    super.paymentMethod,
    super.paymentStatus,
    super.orderStatus,
    super.customerName,
    super.customerEmail,
    super.customerMobile,
    super.placedAt,
    super.deliveredAt,
    super.createdAt,
    super.items,
    this.shippingAddress,
    this.payments,
  });

  factory OrderDetailResult.fromJson(Map<String, dynamic> json) {
    List<OrderItemResult>? items;
    if (json['items'] != null && json['items'] is List) {
      items = (json['items'] as List)
          .map((e) => OrderItemResult.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    List<PaymentResult>? payments;
    if (json['payments'] != null && json['payments'] is List) {
      payments = (json['payments'] as List)
          .map((e) => PaymentResult.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return OrderDetailResult(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      userId: json['userId'] is int
          ? json['userId']
          : int.tryParse(json['userId']?.toString() ?? ''),
      orderNumber: json['orderNumber']?.toString(),
      subtotal: json['subtotal']?.toDouble(),
      gstAmount: json['gstAmount']?.toDouble(),
      shippingCharge: json['shippingCharge']?.toDouble(),
      discountAmount: json['discountAmount']?.toDouble(),
      totalAmount: json['totalAmount']?.toDouble(),
      paymentMethod: json['paymentMethod']?.toString() ?? 'cod',
      paymentStatus: json['paymentStatus']?.toString() ?? 'pending',
      orderStatus: json['orderStatus']?.toString() ?? 'pending',
      customerName: json['customerName']?.toString(),
      customerEmail: json['customerEmail']?.toString(),
      customerMobile: json['customerMobile']?.toString(),
      placedAt: json['placedAt']?.toString(),
      deliveredAt: json['deliveredAt']?.toString(),
      createdAt: json['createdAt']?.toString(),
      items: items,
      shippingAddress: json['shippingAddress'] == null
          ? null
          : AddressResult.fromJson(json['shippingAddress']),
      payments: payments,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    "shippingAddress": shippingAddress?.toJson(),
    "payments": payments?.map((e) => e.toJson()).toList(),
  };
}
