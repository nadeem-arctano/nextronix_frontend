import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../api/base_url.dart';
import '../model/response/response.dart';
import '../static_values/static_values.dart';

/// A single master table's count entry returned by the dashboard endpoint.
class MasterCount {
  final String master;
  final int total;

  MasterCount({required this.master, required this.total});

  factory MasterCount.fromJson(Map<String, dynamic> json) {
    return MasterCount(
      master: json['master'] as String? ?? '',
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }
}

/// A single master table's in-use count entry.
class MasterInUseCount {
  final String master;
  final int used;

  MasterInUseCount({required this.master, required this.used});

  factory MasterInUseCount.fromJson(Map<String, dynamic> json) {
    return MasterInUseCount(
      master: json['master'] as String? ?? '',
      used: (json['used'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Dashboard KPI data from `GET /api/super-admin/dashboard`.
class SuperAdminDashboardData {
  final int adminCount;
  final int managerCount;
  final int customerCount;
  final int activeProductCount;
  final int todayOrderCount;
  final double todaySalesAmount;
  final List<MasterCount> masterTotals;
  final List<MasterInUseCount> masterInUse;
  final String? asOf;

  SuperAdminDashboardData({
    required this.adminCount,
    required this.managerCount,
    required this.customerCount,
    required this.activeProductCount,
    required this.todayOrderCount,
    required this.todaySalesAmount,
    required this.masterTotals,
    required this.masterInUse,
    this.asOf,
  });

  factory SuperAdminDashboardData.fromJson(Map<String, dynamic> json) {
    final counts = json['counts'] as Map<String, dynamic>? ?? {};
    final today = json['today'] as Map<String, dynamic>? ?? {};
    final masters = json['masters'] as Map<String, dynamic>? ?? {};

    final totalsRaw = masters['totals'] as List<dynamic>? ?? [];
    final inUseRaw = masters['inUse'] as List<dynamic>? ?? [];

    return SuperAdminDashboardData(
      adminCount: (counts['adminCount'] as num?)?.toInt() ?? 0,
      managerCount: (counts['managerCount'] as num?)?.toInt() ?? 0,
      customerCount: (counts['customerCount'] as num?)?.toInt() ?? 0,
      activeProductCount: (counts['activeProductCount'] as num?)?.toInt() ?? 0,
      todayOrderCount: (today['orderCount'] as num?)?.toInt() ?? 0,
      todaySalesAmount: (today['salesAmount'] as num?)?.toDouble() ?? 0.0,
      masterTotals: totalsRaw
          .map((e) => MasterCount.fromJson(e as Map<String, dynamic>))
          .toList(),
      masterInUse: inUseRaw
          .map((e) => MasterInUseCount.fromJson(e as Map<String, dynamic>))
          .toList(),
      asOf: json['asOf'] as String?,
    );
  }
}

/// Provider that fetches and exposes Super Admin dashboard KPI data.
///
/// Validates Requirements 9.1, 9.3.
class SuperAdminDashboardProvider extends ChangeNotifier {
  SuperAdminDashboardData? _data;
  bool _isLoading = false;
  String? _error;

  SuperAdminDashboardData? get data => _data;
  bool get isLoading => _isLoading;
  String? get error => _error;

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

  /// Fetches dashboard KPIs from `GET /api/super-admin/dashboard`.
  Future<AlertErrorResponse?> loadDashboard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _dio.get('super-admin/dashboard');
      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        final payload =
            responseData['data'] as Map<String, dynamic>? ?? responseData;
        _data = SuperAdminDashboardData.fromJson(payload);
      }
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load dashboard';
      notifyListeners();
      return AlertErrorResponse.getErrorResponse(e);
    }
  }
}
