import '../../core/utils/parsers.dart';

class OrderChartResponse {
  final int? statusCode;
  final String? message;
  final OrderChartResult? data;

  OrderChartResponse({this.statusCode, this.message, this.data});

  factory OrderChartResponse.fromJson(Map<String, dynamic> json) =>
      OrderChartResponse(
        statusCode: json["status_code"] ?? json["statusCode"],
        message: json["message"],
        data: json["data"] == null
            ? null
            : OrderChartResult.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "status_code": statusCode,
    "message": message,
    "data": data?.toJson(),
  };
}

class OrderChartResult {
  final List<OrderStatusData>? statusData;
  final List<MonthlyOrderData>? monthlyData;

  OrderChartResult({this.statusData, this.monthlyData});

  factory OrderChartResult.fromJson(Map<String, dynamic> json) =>
      OrderChartResult(
        statusData: json["statusData"] == null
            ? null
            : List<OrderStatusData>.from(
                (json["statusData"] as List).map(
                  (e) => OrderStatusData.fromJson(e),
                ),
              ),
        monthlyData: json["monthlyData"] == null
            ? null
            : List<MonthlyOrderData>.from(
                (json["monthlyData"] as List).map(
                  (e) => MonthlyOrderData.fromJson(e),
                ),
              ),
      );

  Map<String, dynamic> toJson() => {
    "statusData": statusData?.map((e) => e.toJson()).toList(),
    "monthlyData": monthlyData?.map((e) => e.toJson()).toList(),
  };
}

class OrderStatusData {
  final String? orderStatus;
  final int? count;

  OrderStatusData({this.orderStatus, this.count});

  factory OrderStatusData.fromJson(Map<String, dynamic> json) =>
      OrderStatusData(
        orderStatus: json['orderStatus']?.toString(),
        count: parseInt(json['count']),
      );

  Map<String, dynamic> toJson() => {"orderStatus": orderStatus, "count": count};
}

class MonthlyOrderData {
  final int? month;
  final int? year;
  final int? orders;
  final double? revenue;

  MonthlyOrderData({this.month, this.year, this.orders, this.revenue});

  factory MonthlyOrderData.fromJson(Map<String, dynamic> json) =>
      MonthlyOrderData(
        month: parseInt(json['month']),
        year: parseInt(json['year']),
        orders: parseInt(json['orders']),
        revenue: parseDouble(json['revenue']),
      );

  Map<String, dynamic> toJson() => {
    "month": month,
    "year": year,
    "orders": orders,
    "revenue": revenue,
  };
}
