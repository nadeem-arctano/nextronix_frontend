import 'package:flutter/foundation.dart';

import '../model/response/response.dart';
import '../repository/nextronix_repository.dart';

class InventoryProvider extends ChangeNotifier {
  final NextronixRepository _repo = NextronixRepository();

  List<InventoryLog> _items = [];
  PaginationInfo? _pagination;
  bool _isLoading = false;
  bool _isAdjusting = false;
  String? _error;

  // Filters
  int? _productId;
  int? _variantId;
  String? _reason;
  String? _search;
  String? _startDate;
  String? _endDate;
  int _currentPage = 1;
  static const int _pageSize = 20;

  List<InventoryLog> get items => _items;
  PaginationInfo? get pagination => _pagination;
  bool get isLoading => _isLoading;
  bool get isAdjusting => _isAdjusting;
  String? get error => _error;
  int? get productIdFilter => _productId;
  String? get reasonFilter => _reason;
  int get currentPage => _currentPage;

  Future<AlertErrorResponse?> load({int? page}) async {
    _isLoading = true;
    _error = null;
    if (page != null) _currentPage = page;
    notifyListeners();
    try {
      final r = await _repo.getInventoryLogs(
        page: _currentPage,
        limit: _pageSize,
        productId: _productId,
        variantId: _variantId,
        reason: _reason,
        search: _search,
        startDate: _startDate,
        endDate: _endDate,
      );
      _items = r.data ?? [];
      _pagination = r.pagination;
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load inventory logs';
      notifyListeners();
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  void setReason(String? value) {
    _reason = value;
    _currentPage = 1;
    load();
  }

  void setProduct(int? id) {
    _productId = id;
    _currentPage = 1;
    load();
  }

  void setSearch(String? value) {
    _search = (value ?? '').trim().isEmpty ? null : value!.trim();
    _currentPage = 1;
    load();
  }

  void setDateRange({String? start, String? end}) {
    _startDate = start;
    _endDate = end;
    _currentPage = 1;
    load();
  }

  void clearFilters() {
    _productId = null;
    _variantId = null;
    _reason = null;
    _search = null;
    _startDate = null;
    _endDate = null;
    _currentPage = 1;
    load();
  }

  Future<AlertErrorResponse?> adjustStock({
    required int productId,
    int? variantId,
    required int quantityChanged,
    required String reason,
    String? note,
  }) async {
    _isAdjusting = true;
    notifyListeners();
    try {
      await _repo.adjustStock(
        productId: productId,
        variantId: variantId,
        quantityChanged: quantityChanged,
        reason: reason,
        note: note,
      );
      _isAdjusting = false;
      await load();
      return null;
    } catch (e) {
      _isAdjusting = false;
      notifyListeners();
      return AlertErrorResponse.getErrorResponse(e);
    }
  }
}
