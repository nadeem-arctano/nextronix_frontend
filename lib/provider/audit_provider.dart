import 'package:flutter/foundation.dart';

import '../model/response/response.dart';
import '../repository/nextronix_repository.dart';

class AuditProvider extends ChangeNotifier {
  final NextronixRepository _repo = NextronixRepository();

  List<AuditLog> _items = [];
  PaginationInfo? _pagination;
  bool _isLoading = false;
  String? _error;

  // Filters
  String? _module;
  String? _action;
  String? _search;
  String? _startDate;
  String? _endDate;
  int _currentPage = 1;
  static const int _pageSize = 20;

  // Filter dropdown source
  List<String> _knownModules = const [];
  List<String> _knownActions = const [];

  List<AuditLog> get items => _items;
  PaginationInfo? get pagination => _pagination;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get moduleFilter => _module;
  String? get actionFilter => _action;
  String? get searchTerm => _search;
  String? get startDate => _startDate;
  String? get endDate => _endDate;
  int get currentPage => _currentPage;
  List<String> get knownModules => _knownModules;
  List<String> get knownActions => _knownActions;

  Future<AlertErrorResponse?> loadFilters() async {
    try {
      final r = await _repo.getAuditFilters();
      _knownModules = r.modules;
      _knownActions = r.actions;
      notifyListeners();
      return null;
    } catch (e) {
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  Future<AlertErrorResponse?> load({int? page}) async {
    _isLoading = true;
    _error = null;
    if (page != null) _currentPage = page;
    notifyListeners();
    try {
      final r = await _repo.getAuditLogs(
        page: _currentPage,
        limit: _pageSize,
        module: _module,
        action: _action,
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
      _error = 'Failed to load audit logs';
      notifyListeners();
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  void setModule(String? value) {
    _module = value;
    _currentPage = 1;
    load();
  }

  void setAction(String? value) {
    _action = value;
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
    _module = null;
    _action = null;
    _search = null;
    _startDate = null;
    _endDate = null;
    _currentPage = 1;
    load();
  }
}
