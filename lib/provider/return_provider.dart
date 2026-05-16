import 'package:flutter/foundation.dart';

import '../model/response/response.dart';
import '../repository/nextronix_repository.dart';

class ReturnProvider extends ChangeNotifier {
  List<ReturnRequest> _returns = [];
  ReturnRequest? _selected;
  ReturnStats? _stats;
  PaginationInfo? _pagination;
  bool _isLoading = false;
  String? _error;
  String? _statusFilter;
  String? _search;
  int _currentPage = 1;

  final NextronixRepository _repo = NextronixRepository();

  List<ReturnRequest> get returns => _returns;
  ReturnRequest? get selected => _selected;
  ReturnStats? get stats => _stats;
  PaginationInfo? get pagination => _pagination;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get statusFilter => _statusFilter;
  String? get search => _search;
  int get currentPage => _currentPage;

  Future<AlertErrorResponse?> loadReturns({int page = 1}) async {
    _isLoading = true;
    _error = null;
    _currentPage = page;
    notifyListeners();
    try {
      final response = await _repo.getReturns(
        page: page,
        status: _statusFilter,
        search: _search,
      );
      _returns = response.data ?? [];
      _pagination = response.pagination;
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load returns';
      notifyListeners();
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  Future<AlertErrorResponse?> loadStats() async {
    try {
      final response = await _repo.getReturnStats();
      _stats = response.data;
      notifyListeners();
      return null;
    } catch (e) {
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  Future<AlertErrorResponse?> loadReturnById(int id) async {
    _isLoading = true;
    _selected = null;
    notifyListeners();
    try {
      final response = await _repo.getReturnById(id: id);
      _selected = response.data;
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  Future<AlertErrorResponse?> updateStatus(
    int id, {
    required String status,
    String? adminRemark,
    double? refundAmount,
    String? refundMethod,
  }) async {
    try {
      await _repo.updateReturnStatus(
        id: id,
        status: status,
        adminRemark: adminRemark,
        refundAmount: refundAmount,
        refundMethod: refundMethod,
      );
      await loadReturnById(id);
      await loadStats();
      return null;
    } catch (e) {
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  void setStatusFilter(String? value) {
    _statusFilter = value;
    loadReturns();
  }

  void setSearch(String? value) {
    _search = value;
    loadReturns();
  }
}
