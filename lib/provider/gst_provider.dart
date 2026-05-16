import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../model/response/response.dart';
import '../repository/nextronix_repository.dart';

class GstProvider extends ChangeNotifier {
  // Dashboard
  GstDashboard? _dashboard;
  // State-wise
  List<StateGstItem> _stateData = [];
  // Invoice breakup
  List<InvoiceBreakupItem> _invoiceData = [];
  PaginationInfo? _invoicePagination;
  // HSN Summary
  List<HsnSummaryItem> _hsnData = [];
  // GSTR-1 / 3B
  Gstr1Data? _gstr1;
  Gstr3bData? _gstr3b;
  // Tax settings
  TaxSettings? _taxSettings;
  final Map<String, String> _taxFormValues = {};
  final Map<String, String> _taxInitialValues = {};

  // Filters
  DateTime? _startDate;
  DateTime? _endDate;
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;

  bool _isLoading = false;
  bool _isExporting = false;
  bool _isSavingSettings = false;
  String? _error;

  final NextronixRepository _repo = NextronixRepository();
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  // ─── Getters ────────────────────────────────────────────────────────────────
  GstDashboard? get dashboard => _dashboard;
  List<StateGstItem> get stateData => _stateData;
  List<InvoiceBreakupItem> get invoiceData => _invoiceData;
  PaginationInfo? get invoicePagination => _invoicePagination;
  List<HsnSummaryItem> get hsnData => _hsnData;
  Gstr1Data? get gstr1 => _gstr1;
  Gstr3bData? get gstr3b => _gstr3b;
  TaxSettings? get taxSettings => _taxSettings;

  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  int get selectedYear => _selectedYear;
  int get selectedMonth => _selectedMonth;

  bool get isLoading => _isLoading;
  bool get isExporting => _isExporting;
  bool get isSavingSettings => _isSavingSettings;
  String? get error => _error;

  bool get hasUnsavedTaxChanges {
    if (_taxFormValues.isEmpty) return false;
    for (final entry in _taxFormValues.entries) {
      final initial = _taxInitialValues[entry.key] ?? '';
      if (entry.value != initial) return true;
    }
    return false;
  }

  String getTaxValue(String key) => _taxFormValues[key] ?? '';

  void setTaxValue(String key, String value) {
    _taxFormValues[key] = value;
    notifyListeners();
  }

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

  void setMonth(int month) {
    _selectedMonth = month;
    notifyListeners();
  }

  String? get _startDateStr =>
      _startDate != null ? _dateFormat.format(_startDate!) : null;
  String? get _endDateStr =>
      _endDate != null ? _dateFormat.format(_endDate!) : null;

  // ─── Dashboard ──────────────────────────────────────────────────────────────
  Future<AlertErrorResponse?> loadDashboard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _repo.getGstDashboard(
        startDate: _startDateStr,
        endDate: _endDateStr,
      );
      _dashboard = response.data;
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

  // ─── State-wise ─────────────────────────────────────────────────────────────
  Future<AlertErrorResponse?> loadStateWise() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _repo.getStateWiseGst(
        startDate: _startDateStr,
        endDate: _endDateStr,
      );
      _stateData = response.data ?? [];
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  // ─── Invoice Breakup ────────────────────────────────────────────────────────
  Future<AlertErrorResponse?> loadInvoiceBreakup({int page = 1}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _repo.getInvoiceBreakup(
        page: page,
        startDate: _startDateStr,
        endDate: _endDateStr,
      );
      _invoiceData = response.data ?? [];
      _invoicePagination = response.pagination;
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  // ─── HSN Summary ────────────────────────────────────────────────────────────
  Future<AlertErrorResponse?> loadHsnSummary() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _repo.getHsnSummary(
        startDate: _startDateStr,
        endDate: _endDateStr,
      );
      _hsnData = response.data ?? [];
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  // ─── GSTR-1 / 3B ────────────────────────────────────────────────────────────
  Future<AlertErrorResponse?> loadGstr1() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _repo.getGstr1(
        year: _selectedYear,
        month: _selectedMonth,
      );
      _gstr1 = response.data;
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  Future<AlertErrorResponse?> loadGstr3b() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _repo.getGstr3b(
        year: _selectedYear,
        month: _selectedMonth,
      );
      _gstr3b = response.data;
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  // ─── Monthly export (CA-friendly) ───────────────────────────────────────────
  Future<bool> exportMonthly(String format) async {
    _isExporting = true;
    notifyListeners();
    try {
      final bytes = await _repo.exportGstMonthly(
        year: _selectedYear,
        month: _selectedMonth,
        format: format,
      );
      _downloadFile(
        Uint8List.fromList(bytes),
        format,
        'GST_${_selectedYear}_$_selectedMonth',
      );
      _isExporting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isExporting = false;
      notifyListeners();
      return false;
    }
  }

  void _downloadFile(Uint8List data, String format, String name) {
    final mimeMap = {
      'excel':
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'csv': 'text/csv',
      'pdf': 'application/pdf',
    };
    final extMap = {'excel': 'xlsx', 'csv': 'csv', 'pdf': 'pdf'};
    final mime = mimeMap[format];
    final ext = extMap[format];
    if (mime == null || ext == null) return;

    final blob = html.Blob([data], mime);
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', '$name.$ext')
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  // ─── Tax Settings ───────────────────────────────────────────────────────────
  Future<AlertErrorResponse?> loadTaxSettings() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _repo.getTaxSettings();
      _taxSettings = response.data;
      _hydrateTaxForm(_taxSettings);
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  void _hydrateTaxForm(TaxSettings? s) {
    _taxFormValues.clear();
    _taxInitialValues.clear();
    if (s == null) return;
    _taxFormValues['defaultGstPercent'] = s.defaultGstPercent.toString();
    _taxFormValues['invoiceTaxNote'] = s.invoiceTaxNote ?? '';
    _taxFormValues['gstInvoiceFooter'] = s.gstInvoiceFooter ?? '';
    _taxFormValues['gstDeclaration'] = s.gstDeclaration ?? '';
    _taxInitialValues.addAll(_taxFormValues);
  }

  Future<AlertErrorResponse?> saveTaxSettings() async {
    _isSavingSettings = true;
    notifyListeners();
    try {
      await _repo.updateTaxSettings(
        defaultGstPercent:
            double.tryParse(_taxFormValues['defaultGstPercent'] ?? '') ?? 18,
        invoiceTaxNote: _taxFormValues['invoiceTaxNote'],
        gstInvoiceFooter: _taxFormValues['gstInvoiceFooter'],
        gstDeclaration: _taxFormValues['gstDeclaration'],
      );
      await loadTaxSettings();
      _isSavingSettings = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isSavingSettings = false;
      notifyListeners();
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  void resetTaxChanges() {
    _taxFormValues.clear();
    _taxFormValues.addAll(_taxInitialValues);
    notifyListeners();
  }
}
