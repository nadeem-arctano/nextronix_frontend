import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../api/base_url.dart';
import '../model/response/response.dart';
import '../static_values/static_values.dart';

/// A single admin row returned by `GET /api/super-admin/admins`.
class AdminRow {
  final int id;
  final String name;
  final String email;
  final String? mobile;
  final String status;
  final int usersCount;
  final int managersCount;
  final int productsCount;
  final int todayOrdersCount;
  final double todaySalesAmount;
  final String? createdAt;

  AdminRow({
    required this.id,
    required this.name,
    required this.email,
    this.mobile,
    required this.status,
    required this.usersCount,
    required this.managersCount,
    required this.productsCount,
    required this.todayOrdersCount,
    required this.todaySalesAmount,
    this.createdAt,
  });

  factory AdminRow.fromJson(Map<String, dynamic> json) {
    return AdminRow(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      mobile: json['mobile'] as String?,
      status: json['status'] as String? ?? 'active',
      usersCount: _toInt(json['usersCount']),
      managersCount: _toInt(json['managersCount']),
      productsCount: _toInt(json['productsCount']),
      todayOrdersCount: _toInt(json['todayOrdersCount']),
      todaySalesAmount: _toDouble(json['todaySalesAmount']),
      createdAt: json['createdAt'] as String?,
    );
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }
}

/// Provider that fetches and exposes the paginated admins table from
/// `GET /api/super-admin/admins`.
///
/// Validates Requirements 10.1, 10.2, 10.3, 10.4, 10.5.
class AdminsTableProvider extends ChangeNotifier {
  List<AdminRow> _rows = [];
  int _totalCount = 0;
  int _page = 1;
  int _pageSize = 20;
  bool _isLoading = false;
  String? _error;

  // Filters
  String? _search;
  String? _statusFilter;

  // Field-level validation errors surfaced by 400 responses.
  Map<String, String> _fieldErrors = {};

  List<AdminRow> get rows => _rows;
  int get totalCount => _totalCount;
  int get page => _page;
  int get pageSize => _pageSize;
  int get totalPages => (_totalCount / _pageSize).ceil().clamp(1, 99999);
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get search => _search;
  String? get statusFilter => _statusFilter;
  Map<String, String> get fieldErrors => _fieldErrors;

  Dio get _dio {
    return Dio(
      BaseOptions(
        baseUrl: BaseUrl.baseurl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          if (globalAccessToken != null)
            'Authorization': 'Bearer $globalAccessToken',
        },
      ),
    );
  }

  /// Fetches the admins table from `GET /api/super-admin/admins`.
  Future<AlertErrorResponse?> loadAdmins({int? page}) async {
    if (page != null) _page = page;
    _isLoading = true;
    _error = null;
    _fieldErrors = {};
    notifyListeners();

    try {
      final queryParams = <String, dynamic>{
        'page': _page,
        'pageSize': _pageSize,
      };
      if (_search != null && _search!.isNotEmpty) {
        queryParams['search'] = _search;
      }
      if (_statusFilter != null && _statusFilter!.isNotEmpty) {
        queryParams['status'] = _statusFilter;
      }

      debugPrint(
        '[AdminsTableProvider] Fetching: ${BaseUrl.baseurl}super-admin/admins params=$queryParams token=${globalAccessToken?.substring(0, 20)}...',
      );

      final response = await _dio.get(
        'super-admin/admins',
        queryParameters: queryParams,
      );

      debugPrint(
        '[AdminsTableProvider] Response: ${response.statusCode} data=${response.data}',
      );

      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        final data = responseData['data'] as Map<String, dynamic>? ?? {};
        final rawRows = data['rows'] as List<dynamic>? ?? [];
        _rows = rawRows
            .map((e) => AdminRow.fromJson(e as Map<String, dynamic>))
            .toList();
        _totalCount = (data['totalCount'] as num?)?.toInt() ?? 0;
        _page = (data['page'] as num?)?.toInt() ?? _page;
        _pageSize = (data['pageSize'] as num?)?.toInt() ?? _pageSize;
      }

      debugPrint(
        '[AdminsTableProvider] Parsed ${_rows.length} rows, total=$_totalCount',
      );

      _isLoading = false;
      notifyListeners();
      return null;
    } on DioException catch (e) {
      _isLoading = false;
      debugPrint(
        '[AdminsTableProvider] DioException: ${e.response?.statusCode} ${e.message} ${e.response?.data}',
      );

      // Surface 400 errors with field info inline (Requirement 10.5).
      if (e.response?.statusCode == 400) {
        final body = e.response?.data;
        if (body is Map<String, dynamic>) {
          final field = body['field'] as String?;
          final message = body['message'] as String? ?? 'Invalid parameter';
          if (field != null) {
            _fieldErrors = {field: message};
          }
          _error = message;
        } else {
          _error = 'Invalid request';
        }
      } else {
        _error = 'Failed to load admins';
      }

      notifyListeners();
      return AlertErrorResponse.getErrorResponse(e);
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load admins';
      notifyListeners();
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  void setSearch(String? value) {
    _search = value;
    _page = 1;
    loadAdmins();
  }

  void setStatusFilter(String? value) {
    _statusFilter = value;
    _page = 1;
    loadAdmins();
  }

  void setPageSize(int value) {
    _pageSize = value;
    _page = 1;
    loadAdmins();
  }

  void clearFilters() {
    _search = null;
    _statusFilter = null;
    _page = 1;
    loadAdmins();
  }

  /// Soft-delete (block) an admin via `DELETE /api/super-admin/admins/:id`.
  Future<AlertErrorResponse?> deleteAdmin(int id) async {
    try {
      await _dio.delete('super-admin/admins/$id');
      await loadAdmins();
      return null;
    } catch (e) {
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  /// Suspend (block) an admin via `PUT /api/super-admin/admins/:id`.
  Future<AlertErrorResponse?> suspendAdmin(int id) async {
    try {
      await _dio.put('super-admin/admins/$id', data: {'status': 'blocked'});
      await loadAdmins();
      return null;
    } catch (e) {
      return AlertErrorResponse.getErrorResponse(e);
    }
  }
}
