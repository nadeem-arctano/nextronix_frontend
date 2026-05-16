import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';

import '../api/base_url.dart';
import '../model/response/report_models.dart';
import '../model/response/alert_error_response.dart';
import '../static_values/static_values.dart';

class ReportProvider extends ChangeNotifier {
  // ─── State ──────────────────────────────────────────────────────────────────
  bool _isLoading = false;
  String? _error;
  bool _isExporting = false;

  // Daily Sales
  DailySalesData? _dailySalesData;
  // Monthly Sales
  List<MonthlySalesItem> _monthlySales = [];
  // GST Report
  GstReportData? _gstReportData;
  // Coupon Report
  List<CouponReportItem> _couponReport = [];
  // Top Customers
  List<TopCustomerItem> _topCustomers = [];
  // Best Products
  List<BestProductItem> _bestProducts = [];

  // Filters
  DateTime? _startDate;
  DateTime? _endDate;
  int _selectedYear = DateTime.now().year;

  // ─── Getters ────────────────────────────────────────────────────────────────
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isExporting => _isExporting;

  DailySalesData? get dailySalesData => _dailySalesData;
  List<MonthlySalesItem> get monthlySales => _monthlySales;
  GstReportData? get gstReportData => _gstReportData;
  List<CouponReportItem> get couponReport => _couponReport;
  List<TopCustomerItem> get topCustomers => _topCustomers;
  List<BestProductItem> get bestProducts => _bestProducts;

  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  int get selectedYear => _selectedYear;

  Dio get _dio {
    final dio = Dio(
      BaseOptions(
        baseUrl: BaseUrl.baseurl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
    if (globalAccessToken != null) {
      dio.options.headers['Authorization'] = 'Bearer $globalAccessToken';
    }
    return dio;
  }

  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  // ─── Filters ────────────────────────────────────────────────────────────────
  void setDateRange(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    notifyListeners();
  }

  void setYear(int year) {
    _selectedYear = year;
    notifyListeners();
  }

  void clearFilters() {
    _startDate = null;
    _endDate = null;
    _selectedYear = DateTime.now().year;
    notifyListeners();
  }

  // ─── Daily Sales ────────────────────────────────────────────────────────────
  Future<AlertErrorResponse?> loadDailySales({int page = 1}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final params = <String, dynamic>{'page': page, 'limit': 15};
      if (_startDate != null)
        params['startDate'] = _dateFormat.format(_startDate!);
      if (_endDate != null) params['endDate'] = _dateFormat.format(_endDate!);

      final response = await _dio.get(
        'reports/daily-sales',
        queryParameters: params,
      );
      final parsed = DailySalesResponse.fromJson(response.data);
      _dailySalesData = parsed.data;
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load daily sales report';
      notifyListeners();
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  // ─── Monthly Sales ──────────────────────────────────────────────────────────
  Future<AlertErrorResponse?> loadMonthlySales() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final params = <String, dynamic>{'year': _selectedYear};
      final response = await _dio.get(
        'reports/monthly-sales',
        queryParameters: params,
      );
      final parsed = MonthlySalesResponse.fromJson(response.data);
      _monthlySales = parsed.data ?? [];
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load monthly sales report';
      notifyListeners();
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  // ─── GST Report ─────────────────────────────────────────────────────────────
  Future<AlertErrorResponse?> loadGstReport() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final params = <String, dynamic>{};
      if (_startDate != null)
        params['startDate'] = _dateFormat.format(_startDate!);
      if (_endDate != null) params['endDate'] = _dateFormat.format(_endDate!);

      final response = await _dio.get(
        'reports/gst-report',
        queryParameters: params,
      );
      final parsed = GstReportResponse.fromJson(response.data);
      _gstReportData = parsed.data;
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load GST report';
      notifyListeners();
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  // ─── Coupon Report ──────────────────────────────────────────────────────────
  Future<AlertErrorResponse?> loadCouponReport() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _dio.get('reports/coupon-report');
      final parsed = CouponReportResponse.fromJson(response.data);
      _couponReport = parsed.data ?? [];
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load coupon report';
      notifyListeners();
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  // ─── Top Customers ──────────────────────────────────────────────────────────
  Future<AlertErrorResponse?> loadTopCustomers({int limit = 20}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final params = <String, dynamic>{'limit': limit};
      if (_startDate != null)
        params['startDate'] = _dateFormat.format(_startDate!);
      if (_endDate != null) params['endDate'] = _dateFormat.format(_endDate!);

      final response = await _dio.get(
        'reports/top-customers',
        queryParameters: params,
      );
      final parsed = TopCustomersResponse.fromJson(response.data);
      _topCustomers = parsed.data ?? [];
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load top customers report';
      notifyListeners();
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  // ─── Best Products ──────────────────────────────────────────────────────────
  Future<AlertErrorResponse?> loadBestProducts({int limit = 20}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final params = <String, dynamic>{'limit': limit};
      if (_startDate != null)
        params['startDate'] = _dateFormat.format(_startDate!);
      if (_endDate != null) params['endDate'] = _dateFormat.format(_endDate!);

      final response = await _dio.get(
        'reports/best-products',
        queryParameters: params,
      );
      final parsed = BestProductsResponse.fromJson(response.data);
      _bestProducts = parsed.data ?? [];
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load best products report';
      notifyListeners();
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  // ─── Export ─────────────────────────────────────────────────────────────────
  Future<Uint8List?> exportReport({
    required String reportType,
    required String format,
  }) async {
    _isExporting = true;
    notifyListeners();

    try {
      final params = <String, dynamic>{'format': format};
      if (_startDate != null)
        params['startDate'] = _dateFormat.format(_startDate!);
      if (_endDate != null) params['endDate'] = _dateFormat.format(_endDate!);
      if (reportType == 'monthly-sales') params['year'] = _selectedYear;

      final response = await _dio.get(
        'reports/$reportType/export',
        queryParameters: params,
        options: Options(responseType: ResponseType.bytes),
      );

      _isExporting = false;
      notifyListeners();
      return Uint8List.fromList(response.data);
    } catch (e) {
      _isExporting = false;
      notifyListeners();
      return null;
    }
  }
}
