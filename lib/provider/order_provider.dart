import 'package:flutter/material.dart';

import '../model/response/response.dart';
import '../repository/nextronix_repository.dart';

class OrderProvider extends ChangeNotifier {
  List<OrderResult> _orders = [];
  OrderResult? _selectedOrder;
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;
  String? _statusFilter;

  List<OrderResult> get orders => _orders;
  OrderResult? get selectedOrder => _selectedOrder;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalItems => _totalItems;
  String? get statusFilter => _statusFilter;

  Future<AlertErrorResponse?> loadOrders({int page = 1, String? status}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      OrderListResponse response = await NextronixRepository().getOrders(
        page: page,
        status: status ?? _statusFilter,
      );

      _orders = response.data ?? [];
      _currentPage = response.pagination?.currentPage ?? 1;
      _totalPages = response.pagination?.totalPages ?? 1;
      _totalItems = response.pagination?.totalItems ?? 0;
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load orders';
      notifyListeners();
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  Future<AlertErrorResponse?> loadOrderById({required int id}) async {
    _isLoading = true;
    notifyListeners();

    try {
      OrderDetailResponse response = await NextronixRepository().getOrderById(
        id: id,
      );
      _selectedOrder = response.data;
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load order';
      notifyListeners();
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  Future<AlertErrorResponse?> updateOrderStatus({
    required int id,
    required String status,
  }) async {
    try {
      CommonResponse response = await NextronixRepository().updateOrderStatus(
        id: id,
        status: status,
      );
      if (response.statusCode == 200) {
        await loadOrders(page: _currentPage);
        return null;
      } else {
        return AlertErrorResponse(
          alertHeading: "Error!",
          alertMessage: response.message ?? "Failed to update order status",
        );
      }
    } catch (e) {
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  Future<AlertErrorResponse?> updatePaymentStatus({
    required int id,
    required String paymentStatus,
  }) async {
    try {
      CommonResponse response = await NextronixRepository().updatePaymentStatus(
        id: id,
        paymentStatus: paymentStatus,
      );
      if (response.statusCode == 200) {
        await loadOrders(page: _currentPage);
        return null;
      } else {
        return AlertErrorResponse(
          alertHeading: "Error!",
          alertMessage: response.message ?? "Failed to update payment status",
        );
      }
    } catch (e) {
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  void setStatusFilter(String? status) {
    _statusFilter = status;
    loadOrders();
  }
}
