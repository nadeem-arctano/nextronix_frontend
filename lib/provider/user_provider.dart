import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/response/response.dart';
import '../repository/nextronix_repository.dart';

class UserProvider extends ChangeNotifier {
  List<UserListResult> _users = [];
  PaginationResult? _pagination;
  bool _isLoading = false;
  String? _error;

  // Filters
  String _search = '';
  String? _roleFilter;
  String? _statusFilter;
  DateTime? _startDate;
  DateTime? _endDate;
  int _currentPage = 1;

  List<UserListResult> get users => _users;
  PaginationResult? get pagination => _pagination;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get search => _search;
  String? get roleFilter => _roleFilter;
  String? get statusFilter => _statusFilter;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  int get currentPage => _currentPage;

  Future<AlertErrorResponse?> loadUsers({int page = 1}) async {
    _isLoading = true;
    _error = null;
    _currentPage = page;
    notifyListeners();

    try {
      final repo = NextronixRepository();
      final dateFormat = DateFormat('yyyy-MM-dd');

      final response = await repo.getUsers(
        page: page,
        limit: 10,
        search: _search.isNotEmpty ? _search : null,
        startDate: _startDate != null ? dateFormat.format(_startDate!) : null,
        endDate: _endDate != null ? dateFormat.format(_endDate!) : null,
        role: _roleFilter,
        status: _statusFilter,
      );

      _users = response.data ?? [];
      _pagination = response.pagination;
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load users';
      notifyListeners();
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  void setSearch(String value) {
    _search = value;
  }

  void setRoleFilter(String? value) {
    _roleFilter = value;
    loadUsers();
  }

  void setStatusFilter(String? value) {
    _statusFilter = value;
    loadUsers();
  }

  void setDateRange(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    loadUsers();
  }

  void clearFilters() {
    _search = '';
    _roleFilter = null;
    _statusFilter = null;
    _startDate = null;
    _endDate = null;
    loadUsers();
  }

  Future<AlertErrorResponse?> updateUserStatus({
    required int id,
    required String status,
  }) async {
    try {
      final repo = NextronixRepository();
      await repo.updateUserStatus(id: id, status: status);
      await loadUsers(page: _currentPage);
      return null;
    } catch (e) {
      return AlertErrorResponse.getErrorResponse(e);
    }
  }
}
