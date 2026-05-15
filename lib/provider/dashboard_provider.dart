import 'package:flutter/material.dart';

import '../model/response/response.dart';
import '../repository/nextronix_repository.dart';

class DashboardProvider extends ChangeNotifier {
  DashboardStatsResult? _stats;
  List<OrderResult> _recentOrders = [];
  List<ProductResult> _topProducts = [];
  List<ProductResult> _lowStockProducts = [];
  List<RevenueResult> _revenueData = [];
  List<RevenueResult> _weeklyData = [];
  bool _isLoading = false;
  String? _error;

  DashboardStatsResult? get stats => _stats;
  List<OrderResult> get recentOrders => _recentOrders;
  List<ProductResult> get topProducts => _topProducts;
  List<ProductResult> get lowStockProducts => _lowStockProducts;
  List<RevenueResult> get revenueData => _revenueData;
  List<RevenueResult> get weeklyData => _weeklyData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<AlertErrorResponse?> loadDashboard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final repo = NextronixRepository();

      final responses = await Future.wait([
        repo.getDashboardStats(),
        repo.getDashboardRecentOrders(limit: 5),
        repo.getDashboardTopProducts(limit: 5),
        repo.getDashboardLowStock(),
        repo.getDashboardRevenue(period: 30),
        repo.getDashboardRevenue(period: 7),
      ]);

      _stats = (responses[0] as DashboardStatsResponse).data;
      _recentOrders = (responses[1] as OrderListResponse).data ?? [];
      _topProducts = (responses[2] as ProductListResponse).data ?? [];
      _lowStockProducts = (responses[3] as ProductListResponse).data ?? [];
      _revenueData = (responses[4] as RevenueListResponse).data ?? [];
      _weeklyData = (responses[5] as RevenueListResponse).data ?? [];

      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load dashboard data';
      notifyListeners();
      return AlertErrorResponse.getErrorResponse(e);
    }
  }
}
