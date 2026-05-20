import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../model/request/request.dart';
import '../model/response/response.dart';
import '../repository/nextronix_repository.dart';

/// Provider for Super Admin theme catalog management.
/// Handles paginated listing, CRUD, set-default, toggle-status,
/// and preview section operations.
///
/// Validates: Requirements 12.1, 19.2, 19.3
class ThemeCatalogProvider extends ChangeNotifier {
  // ─── State ──────────────────────────────────────────────────────────────────

  List<ThemeResult> _themes = [];
  bool _isLoading = false;
  String? _error;
  PaginationResult? _pagination;

  // Filters
  int _page = 1;
  int _limit = 20;
  String? _modeFilter;
  String? _statusFilter;
  String? _search;

  // Detail state
  ThemeResult? _selectedTheme;
  List<ThemePreviewSectionResult> _previewSections = [];
  bool _isLoadingDetail = false;

  // ─── Getters ────────────────────────────────────────────────────────────────

  List<ThemeResult> get themes => _themes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  PaginationResult? get pagination => _pagination;
  int get page => _page;
  int get limit => _limit;
  String? get modeFilter => _modeFilter;
  String? get statusFilter => _statusFilter;
  String? get search => _search;
  ThemeResult? get selectedTheme => _selectedTheme;
  List<ThemePreviewSectionResult> get previewSections => _previewSections;
  bool get isLoadingDetail => _isLoadingDetail;

  // ─── Theme List ─────────────────────────────────────────────────────────────

  Future<AlertErrorResponse?> loadThemes({
    int? page,
    int? limit,
    String? mode,
    String? isActive,
    String? search,
  }) async {
    if (page != null) _page = page;
    if (limit != null) _limit = limit;
    if (mode != null) _modeFilter = mode;
    if (isActive != null) _statusFilter = isActive;
    if (search != null) _search = search;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await NextronixRepository().listThemes(
        page: _page,
        limit: _limit,
        mode: _modeFilter,
        status: _statusFilter,
        search: _search,
      );
      _themes = response.data ?? [];
      _pagination = response.pagination;
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load themes';
      notifyListeners();
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  // ─── Theme CRUD ─────────────────────────────────────────────────────────────

  Future<AlertErrorResponse?> createTheme({required FormData formData}) async {
    try {
      final response = await NextronixRepository().createTheme(
        formData: formData,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        await loadThemes();
        return null;
      } else {
        return AlertErrorResponse(
          alertHeading: "Error!",
          alertMessage: response.message ?? "Failed to create theme",
        );
      }
    } catch (e) {
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  Future<AlertErrorResponse?> updateTheme({
    required int id,
    required FormData formData,
  }) async {
    try {
      final response = await NextronixRepository().updateTheme(
        id: id,
        formData: formData,
      );
      if (response.statusCode == 200) {
        await loadThemes();
        return null;
      } else {
        return AlertErrorResponse(
          alertHeading: "Error!",
          alertMessage: response.message ?? "Failed to update theme",
        );
      }
    } catch (e) {
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  Future<AlertErrorResponse?> deleteTheme({required int id}) async {
    try {
      final response = await NextronixRepository().deleteTheme(id: id);
      if (response.statusCode == 200) {
        await loadThemes();
        return null;
      } else {
        return AlertErrorResponse(
          alertHeading: "Error!",
          alertMessage: response.message ?? "Failed to delete theme",
        );
      }
    } catch (e) {
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  // ─── Theme Actions ──────────────────────────────────────────────────────────

  Future<AlertErrorResponse?> setDefault({required int id}) async {
    try {
      final response = await NextronixRepository().setDefaultTheme(id: id);
      if (response.statusCode == 200) {
        await loadThemes();
        return null;
      } else {
        return AlertErrorResponse(
          alertHeading: "Error!",
          alertMessage: response.message ?? "Failed to set default theme",
        );
      }
    } catch (e) {
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  Future<AlertErrorResponse?> toggleStatus({required int id}) async {
    try {
      final response = await NextronixRepository().toggleThemeStatus(id: id);
      if (response.statusCode == 200) {
        await loadThemes();
        return null;
      } else {
        return AlertErrorResponse(
          alertHeading: "Error!",
          alertMessage: response.message ?? "Failed to toggle theme status",
        );
      }
    } catch (e) {
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  // ─── Theme Detail ───────────────────────────────────────────────────────────

  Future<AlertErrorResponse?> getThemeDetail({required int id}) async {
    _isLoadingDetail = true;
    notifyListeners();

    try {
      final response = await NextronixRepository().getTheme(id: id);
      _selectedTheme = response.data;
      _previewSections = response.previewSections ?? [];
      _isLoadingDetail = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoadingDetail = false;
      notifyListeners();
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  // ─── Preview Sections CRUD ──────────────────────────────────────────────────

  Future<AlertErrorResponse?> createPreviewSection({
    required int themeId,
    required ThemePreviewSectionRequest body,
  }) async {
    try {
      final response = await NextronixRepository().createPreviewSection(
        themeId: themeId,
        body: body,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        await loadPreviewSections(themeId: themeId);
        return null;
      } else {
        return AlertErrorResponse(
          alertHeading: "Error!",
          alertMessage: response.message ?? "Failed to create preview section",
        );
      }
    } catch (e) {
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  Future<AlertErrorResponse?> loadPreviewSections({
    required int themeId,
  }) async {
    try {
      // Refresh sections by reloading the full theme detail
      await getThemeDetail(id: themeId);
      return null;
    } catch (e) {
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  Future<AlertErrorResponse?> updatePreviewSection({
    required int themeId,
    required int id,
    required ThemePreviewSectionRequest body,
  }) async {
    try {
      final response = await NextronixRepository().updatePreviewSection(
        themeId: themeId,
        id: id,
        body: body,
      );
      if (response.statusCode == 200) {
        await getThemeDetail(id: themeId);
        return null;
      } else {
        return AlertErrorResponse(
          alertHeading: "Error!",
          alertMessage: response.message ?? "Failed to update preview section",
        );
      }
    } catch (e) {
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  Future<AlertErrorResponse?> deletePreviewSection({
    required int themeId,
    required int id,
  }) async {
    try {
      final response = await NextronixRepository().deletePreviewSection(
        themeId: themeId,
        id: id,
      );
      if (response.statusCode == 200) {
        await getThemeDetail(id: themeId);
        return null;
      } else {
        return AlertErrorResponse(
          alertHeading: "Error!",
          alertMessage: response.message ?? "Failed to delete preview section",
        );
      }
    } catch (e) {
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  // ─── Filter Helpers ─────────────────────────────────────────────────────────

  void setSearch(String? value) {
    _search = value;
    _page = 1;
    loadThemes();
  }

  void setModeFilter(String? value) {
    _modeFilter = value;
    _page = 1;
    loadThemes();
  }

  void setStatusFilter(String? value) {
    _statusFilter = value;
    _page = 1;
    loadThemes();
  }

  void setPage(int value) {
    _page = value;
    loadThemes();
  }

  void setLimit(int value) {
    _limit = value;
    _page = 1;
    loadThemes();
  }

  void clearFilters() {
    _search = null;
    _modeFilter = null;
    _statusFilter = null;
    _page = 1;
    loadThemes();
  }

  void clearDetail() {
    _selectedTheme = null;
    _previewSections = [];
    notifyListeners();
  }
}
