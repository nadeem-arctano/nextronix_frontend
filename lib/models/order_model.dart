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
    if (json['items'] != null) {
      items = (json['items'] as List)
          .map((e) => OrderItemModel.fromJson(e))
          .toList();
    }

    return OrderModel(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      orderNumber: json['orderNumber'] ?? '',
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      gstAmount: (json['gstAmount'] ?? 0).toDouble(),
      shippingCharge: (json['shippingCharge'] ?? 0).toDouble(),
      discountAmount: (json['discountAmount'] ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      paymentMethod: json['paymentMethod'] ?? 'cod',
      paymentStatus: json['paymentStatus'] ?? 'pending',
      orderStatus: json['orderStatus'] ?? 'pending',
      customerName: json['customerName'],
      customerEmail: json['customerEmail'],
      customerMobile: json['customerMobile'],
      placedAt: json['placedAt'],
      deliveredAt: json['deliveredAt'],
      createdAt: json['createdAt'],
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
      id: json['id'] ?? 0,
      productId: json['productId'] ?? 0,
      productName: json['productName'] ?? '',
      quantity: json['quantity'] ?? 1,
      price: (json['price'] ?? 0).toDouble(),
      gstPercent: (json['gstPercent'] ?? 0).toDouble(),
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      thumbnailImage: json['thumbnailImage'],
    );
  }
}
