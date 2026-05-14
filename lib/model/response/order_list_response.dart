import '../../core/utils/parsers.dart';
import 'product_list_response.dart';

class OrderListResponse {
  final int? statusCode;
  final String? message;
  final List<OrderResult>? data;
  final PaginationResult? pagination;

  OrderListResponse({
    this.statusCode,
    this.message,
    this.data,
    this.pagination,
  });

  factory OrderListResponse.fromJson(Map<String, dynamic> json) =>
      OrderListResponse(
        statusCode: json["status_code"] ?? json["statusCode"],
        message: json["message"],
        data: json["data"] == null
            ? null
            : List<OrderResult>.from(
                (json["data"] as List).map((e) => OrderResult.fromJson(e)),
              ),
        pagination: json["pagination"] == null
            ? null
            : PaginationResult.fromJson(json["pagination"]),
      );

  Map<String, dynamic> toJson() => {
    "status_code": statusCode,
    "message": message,
    "data": data?.map((e) => e.toJson()).toList(),
    "pagination": pagination?.toJson(),
  };
}

class OrderResult {
  final int? id;
  final int? userId;
  final String? orderNumber;
  final double? subtotal;
  final double? gstAmount;
  final double? shippingCharge;
  final double? discountAmount;
  final double? totalAmount;
  final String? paymentMethod;
  final String? paymentStatus;
  final String? orderStatus;
  final String? customerName;
  final String? customerEmail;
  final String? customerMobile;
  final String? placedAt;
  final String? deliveredAt;
  final String? createdAt;
  final List<OrderItemResult>? items;

  OrderResult({
    this.id,
    this.userId,
    this.orderNumber,
    this.subtotal,
    this.gstAmount,
    this.shippingCharge,
    this.discountAmount,
    this.totalAmount,
    this.paymentMethod,
    this.paymentStatus,
    this.orderStatus,
    this.customerName,
    this.customerEmail,
    this.customerMobile,
    this.placedAt,
    this.deliveredAt,
    this.createdAt,
    this.items,
  });

  factory OrderResult.fromJson(Map<String, dynamic> json) {
    List<OrderItemResult>? items;
    if (json['items'] != null && json['items'] is List) {
      items = (json['items'] as List)
          .map((e) => OrderItemResult.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return OrderResult(
      id: parseInt(json['id']),
      userId: parseInt(json['userId']),
      orderNumber: json['orderNumber']?.toString(),
      subtotal: parseDouble(json['subtotal']),
      gstAmount: parseDouble(json['gstAmount']),
      shippingCharge: parseDouble(json['shippingCharge']),
      discountAmount: parseDouble(json['discountAmount']),
      totalAmount: parseDouble(json['totalAmount']),
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
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "userId": userId,
    "orderNumber": orderNumber,
    "subtotal": subtotal,
    "gstAmount": gstAmount,
    "shippingCharge": shippingCharge,
    "discountAmount": discountAmount,
    "totalAmount": totalAmount,
    "paymentMethod": paymentMethod,
    "paymentStatus": paymentStatus,
    "orderStatus": orderStatus,
    "customerName": customerName,
    "customerEmail": customerEmail,
    "customerMobile": customerMobile,
    "placedAt": placedAt,
    "deliveredAt": deliveredAt,
    "createdAt": createdAt,
    "items": items?.map((e) => e.toJson()).toList(),
  };
}

class OrderItemResult {
  final int? id;
  final int? productId;
  final String? productName;
  final int? quantity;
  final double? price;
  final double? gstPercent;
  final double? totalPrice;
  final String? thumbnailImage;

  OrderItemResult({
    this.id,
    this.productId,
    this.productName,
    this.quantity,
    this.price,
    this.gstPercent,
    this.totalPrice,
    this.thumbnailImage,
  });

  factory OrderItemResult.fromJson(Map<String, dynamic> json) =>
      OrderItemResult(
        id: parseInt(json['id']),
        productId: parseInt(json['productId']),
        productName: json['productName']?.toString(),
        quantity: parseInt(json['quantity'], defaultValue: 1),
        price: parseDouble(json['price']),
        gstPercent: parseDouble(json['gstPercent']),
        totalPrice: parseDouble(json['totalPrice']),
        thumbnailImage: json['thumbnailImage']?.toString(),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "productId": productId,
    "productName": productName,
    "quantity": quantity,
    "price": price,
    "gstPercent": gstPercent,
    "totalPrice": totalPrice,
    "thumbnailImage": thumbnailImage,
  };
}
