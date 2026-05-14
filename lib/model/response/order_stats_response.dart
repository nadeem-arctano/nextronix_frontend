import '../../core/utils/parsers.dart';

class OrderStatsResponse {
  final int? statusCode;
  final String? message;
  final OrderStatsResult? data;

  OrderStatsResponse({this.statusCode, this.message, this.data});

  factory OrderStatsResponse.fromJson(Map<String, dynamic> json) =>
      OrderStatsResponse(
        statusCode: json["status_code"] ?? json["statusCode"],
        message: json["message"],
        data: json["data"] == null
            ? null
            : OrderStatsResult.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "status_code": statusCode,
    "message": message,
    "data": data?.toJson(),
  };
}

class OrderStatsResult {
  final int? totalOrders;
  final int? pendingOrders;
  final int? confirmedOrders;
  final int? shippedOrders;
  final int? deliveredOrders;
  final int? cancelledOrders;
  final int? returnedOrders;

  OrderStatsResult({
    this.totalOrders,
    this.pendingOrders,
    this.confirmedOrders,
    this.shippedOrders,
    this.deliveredOrders,
    this.cancelledOrders,
    this.returnedOrders,
  });

  factory OrderStatsResult.fromJson(Map<String, dynamic> json) =>
      OrderStatsResult(
        totalOrders: parseInt(json['totalOrders']),
        pendingOrders: parseInt(json['pendingOrders']),
        confirmedOrders: parseInt(json['confirmedOrders']),
        shippedOrders: parseInt(json['shippedOrders']),
        deliveredOrders: parseInt(json['deliveredOrders']),
        cancelledOrders: parseInt(json['cancelledOrders']),
        returnedOrders: parseInt(json['returnedOrders']),
      );

  Map<String, dynamic> toJson() => {
    "totalOrders": totalOrders,
    "pendingOrders": pendingOrders,
    "confirmedOrders": confirmedOrders,
    "shippedOrders": shippedOrders,
    "deliveredOrders": deliveredOrders,
    "cancelledOrders": cancelledOrders,
    "returnedOrders": returnedOrders,
  };
}
