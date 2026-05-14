import '../../core/utils/parsers.dart';

class DashboardStatsResponse {
  final int? statusCode;
  final String? message;
  final DashboardStatsResult? data;

  DashboardStatsResponse({this.statusCode, this.message, this.data});

  factory DashboardStatsResponse.fromJson(Map<String, dynamic> json) =>
      DashboardStatsResponse(
        statusCode: json["status_code"] ?? json["statusCode"],
        message: json["message"],
        data: json["data"] == null
            ? null
            : DashboardStatsResult.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "status_code": statusCode,
    "message": message,
    "data": data?.toJson(),
  };
}

class DashboardStatsResult {
  final int? totalProducts;
  final int? totalOrders;
  final int? pendingOrders;
  final double? totalRevenue;
  final int? todayOrders;
  final double? todayRevenue;
  final int? totalCustomers;
  final int? lowStockProducts;

  DashboardStatsResult({
    this.totalProducts,
    this.totalOrders,
    this.pendingOrders,
    this.totalRevenue,
    this.todayOrders,
    this.todayRevenue,
    this.totalCustomers,
    this.lowStockProducts,
  });

  factory DashboardStatsResult.fromJson(Map<String, dynamic> json) =>
      DashboardStatsResult(
        totalProducts: parseInt(json['totalProducts']),
        totalOrders: parseInt(json['totalOrders']),
        pendingOrders: parseInt(json['pendingOrders']),
        totalRevenue: parseDouble(json['totalRevenue']),
        todayOrders: parseInt(json['todayOrders']),
        todayRevenue: parseDouble(json['todayRevenue']),
        totalCustomers: parseInt(json['totalCustomers']),
        lowStockProducts: parseInt(json['lowStockProducts']),
      );

  Map<String, dynamic> toJson() => {
    "totalProducts": totalProducts,
    "totalOrders": totalOrders,
    "pendingOrders": pendingOrders,
    "totalRevenue": totalRevenue,
    "todayOrders": todayOrders,
    "todayRevenue": todayRevenue,
    "totalCustomers": totalCustomers,
    "lowStockProducts": lowStockProducts,
  };
}
