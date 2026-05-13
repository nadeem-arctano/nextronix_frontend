import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../core/constants/api_constants.dart';
import '../models/dashboard_model.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';

class DashboardProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  DashboardStats? stats;
  List<OrderModel> recentOrders = [];
  List<ProductModel> topProducts = [];
  List<ProductModel> lowStockProducts = [];
  List<RevenueData> revenueData = [];
  bool isLoading = false;
  String? error;

  Future<void> loadDashboard() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final responses = await Future.wait([
        _api.get(ApiConstants.dashboardStats),
        _api.get(ApiConstants.dashboardRecentOrders, queryParams: {'limit': 5}),
        _api.get(ApiConstants.dashboardTopProducts, queryParams: {'limit': 5}),
        _api.get(ApiConstants.dashboardLowStock),
        _api.get(ApiConstants.dashboardRevenue, queryParams: {'period': 30}),
      ]);

      stats = DashboardStats.fromJson(responses[0].data['data']);
      recentOrders = (responses[1].data['data'] as List)
          .map((e) => OrderModel.fromJson(e))
          .toList();
      topProducts = (responses[2].data['data'] as List)
          .map((e) => ProductModel.fromJson(e))
          .toList();
      lowStockProducts = (responses[3].data['data'] as List)
          .map((e) => ProductModel.fromJson(e))
          .toList();
      revenueData = (responses[4].data['data'] as List)
          .map((e) => RevenueData.fromJson(e))
          .toList();
    } catch (e) {
      error = 'Failed to load dashboard data';
      debugPrint('Dashboard error: $e');
    }

    isLoading = false;
    notifyListeners();
  }
}
