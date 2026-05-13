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
      totalProducts: json['totalProducts'] ?? 0,
      totalOrders: json['totalOrders'] ?? 0,
      pendingOrders: json['pendingOrders'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      todayOrders: json['todayOrders'] ?? 0,
      todayRevenue: (json['todayRevenue'] ?? 0).toDouble(),
      totalCustomers: json['totalCustomers'] ?? 0,
      lowStockProducts: json['lowStockProducts'] ?? 0,
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
      date: json['date'] ?? '',
      revenue: (json['revenue'] ?? 0).toDouble(),
      orders: json['orders'] ?? 0,
    );
  }
}
