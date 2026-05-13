import '../core/utils/parsers.dart';

class OrderModel {
  final int id;
  final int userId;
  final String orderNumber;
  final double subtotal;
  final double gstAmount;
  final double shippingCharge;
  final double discountAmount;
  final double totalAmount;
  final String paymentMethod;
  final String paymentStatus;
  final String orderStatus;
  final String? customerName;
  final String? customerEmail;
  final String? customerMobile;
  final String? placedAt;
  final String? deliveredAt;
  final String? createdAt;
  final List<OrderItemModel>? items;

  OrderModel({
    required this.id,
    required this.userId,
    required this.orderNumber,
    required this.subtotal,
    this.gstAmount = 0,
    this.shippingCharge = 0,
    this.discountAmount = 0,
    required this.totalAmount,
    this.paymentMethod = 'cod',
    this.paymentStatus = 'pending',
    this.orderStatus = 'pending',
    this.customerName,
    this.customerEmail,
    this.customerMobile,
    this.placedAt,
    this.deliveredAt,
    this.createdAt,
    this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    List<OrderItemModel>? items;
    if (json['items'] != null && json['items'] is List) {
      items = (json['items'] as List)
          .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return OrderModel(
      id: parseInt(json['id']),
      userId: parseInt(json['userId']),
      orderNumber: json['orderNumber']?.toString() ?? '',
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
}

class OrderItemModel {
  final int id;
  final int productId;
  final String productName;
  final int quantity;
  final double price;
  final double gstPercent;
  final double totalPrice;
  final String? thumbnailImage;

  OrderItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    this.gstPercent = 0,
    required this.totalPrice,
    this.thumbnailImage,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: parseInt(json['id']),
      productId: parseInt(json['productId']),
      productName: json['productName']?.toString() ?? '',
      quantity: parseInt(json['quantity'], defaultValue: 1),
      price: parseDouble(json['price']),
      gstPercent: parseDouble(json['gstPercent']),
      totalPrice: parseDouble(json['totalPrice']),
      thumbnailImage: json['thumbnailImage']?.toString(),
    );
  }
}
