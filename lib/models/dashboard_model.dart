import '../core/utils/parsers.dart';

class DashboardStats {
  final int totalProducts;
  final int totalOrders;
  final int pendingOrders;
  final double totalRevenue;
  final int todayOrders;
  final double todayRevenue;
  final int totalCustomers;
  final int lowStockProducts;

  DashboardStats({
    this.totalProducts = 0,
    this.totalOrders = 0,
    this.pendingOrders = 0,
    this.totalRevenue = 0,
    this.todayOrders = 0,
    this.todayRevenue = 0,
    this.totalCustomers = 0,
    this.lowStockProducts = 0,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalProducts: parseInt(json['totalProducts']),
      totalOrders: parseInt(json['totalOrders']),
      pendingOrders: parseInt(json['pendingOrders']),
      totalRevenue: parseDouble(json['totalRevenue']),
      todayOrders: parseInt(json['todayOrders']),
      todayRevenue: parseDouble(json['todayRevenue']),
      totalCustomers: parseInt(json['totalCustomers']),
      lowStockProducts: parseInt(json['lowStockProducts']),
    );
  }
}

class RevenueData {
  final String date;
  final double revenue;
  final int orders;

  RevenueData({
    required this.date,
    required this.revenue,
    required this.orders,
  });

  factory RevenueData.fromJson(Map<String, dynamic> json) {
    return RevenueData(
      date: json['date']?.toString() ?? '',
      revenue: parseDouble(json['revenue']),
      orders: parseInt(json['orders']),
    );
  }
}
