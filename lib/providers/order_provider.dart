import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../core/constants/api_constants.dart';
import '../models/order_model.dart';

class OrderProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<OrderModel> orders = [];
  OrderModel? selectedOrder;
  bool isLoading = false;
  String? error;
  int currentPage = 1;
  int totalPages = 1;
  int totalItems = 0;
  String? statusFilter;

  Future<void> loadOrders({int page = 1, String? status}) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final params = <String, dynamic>{'page': page, 'limit': 10};
      if (status != null) params['status'] = status;
      if (statusFilter != null) params['status'] = statusFilter;

      final response = await _api.get(ApiConstants.orders, queryParams: params);
      final data = response.data;

      orders = (data['data'] as List)
          .map((e) => OrderModel.fromJson(e))
          .toList();
      currentPage = data['pagination']['currentPage'];
      totalPages = data['pagination']['totalPages'];
      totalItems = data['pagination']['totalItems'];
    } catch (e) {
      error = 'Failed to load orders';
      debugPrint('Orders error: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> loadOrderById(int id) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await _api.get('${ApiConstants.orders}/$id');
      selectedOrder = OrderModel.fromJson(response.data['data']);
    } catch (e) {
      error = 'Failed to load order';
    }

    isLoading = false;
    notifyListeners();
  }

  Future<bool> updateOrderStatus(int id, String status) async {
    try {
      await _api.patch(
        '${ApiConstants.orders}/$id/status',
        data: {'status': status},
      );
      await loadOrders(page: currentPage);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updatePaymentStatus(int id, String status) async {
    try {
      await _api.patch(
        '${ApiConstants.orders}/$id/payment-status',
        data: {'paymentStatus': status},
      );
      await loadOrders(page: currentPage);
      return true;
    } catch (e) {
      return false;
    }
  }

  void setStatusFilter(String? status) {
    statusFilter = status;
    loadOrders();
  }
}
