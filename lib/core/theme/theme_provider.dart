import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../model/request/theme_select_request.dart';
import '../../model/response/theme_list_response.dart';
import '../../repository/nextronix_repository.dart';
import 'app_theme.dart';
import 'dynamic_theme_builder.dart';

/// Manages theme mode (light/dark) and dynamic theme state for the app.
///
/// Extended to support:
/// - Fetching the current resolved theme on auth success
/// - Selecting a new theme via the API
/// - Toggling between paired themes
/// - Falling back to AppTheme baselines on any failure
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  // ─── Dynamic Theme State ────────────────────────────────────────────────
  int? _selectedThemeId;
  ThemeResult? _currentTheme;
  ShadThemeData _compiledLightTheme = AppTheme.lightTheme;
  ShadThemeData _compiledDarkTheme = AppTheme.darkTheme;
  bool _isLoadingCurrentTheme = false;

  // ─── Getters ────────────────────────────────────────────────────────────
  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;

  int? get selectedThemeId => _selectedThemeId;
  ThemeResult? get currentTheme => _currentTheme;
  ShadThemeData get compiledLightTheme => _compiledLightTheme;
  ShadThemeData get compiledDarkTheme => _compiledDarkTheme;
  bool get isLoadingCurrentTheme => _isLoadingCurrentTheme;

  // ─── Load Current Theme (called on auth success) ────────────────────────

  /// Called after successful authentication.
  ///
  /// For Admin/Manager: fetches the current resolved theme from the API.
  /// For Super Admin: loads the default theme without calling admin-theme/current.
  Future<void> loadCurrentTheme({required bool isSuperAdmin}) async {
    if (isSuperAdmin) {
      _loadDefaultThemeForSuperAdmin();
      return;
    }

    _isLoadingCurrentTheme = true;
    notifyListeners();

    try {
      final repo = NextronixRepository();
      final response = await repo.getCurrentTheme();

      if (response.theme != null) {
        _applyThemeFromResult(response.theme!);
      } else {
        _fallbackToBaselines();
      }
    } catch (e) {
      debugPrint('[ThemeProvider] loadCurrentTheme failed: $e');
      _fallbackToBaselines();
    } finally {
      _isLoadingCurrentTheme = false;
      notifyListeners();
    }
  }

  // ─── Select Theme ───────────────────────────────────────────────────────

  /// Selects a new theme by ID. Posts to the API, then re-fetches current theme.
  ///
  /// Ignores the call if a theme operation is already in progress.
  Future<void> selectTheme(int themeId) async {
    if (_isLoadingCurrentTheme) {
      debugPrint(
        '[ThemeProvider] selectTheme($themeId) ignored — already loading',
      );
      return;
    }

    _isLoadingCurrentTheme = true;
    notifyListeners();

    try {
      final repo = NextronixRepository();

      // POST select
      await repo.selectTheme(body: ThemeSelectRequest(themeId: themeId));

      // Re-fetch current theme to get the fully resolved result
      final response = await repo.getCurrentTheme();

      if (response.theme != null) {
        _applyThemeFromResult(response.theme!);
      }
    } catch (e) {
      debugPrint('[ThemeProvider] selectTheme($themeId) failed: $e');
      // Retain previously resolved theme on selection failure (Req 10.9)
    } finally {
      _isLoadingCurrentTheme = false;
      notifyListeners();
    }
  }

  // ─── Toggle Theme ───────────────────────────────────────────────────────

  /// Toggles theme mode, constrained by the current theme's mode and pairing.
  ///
  /// If the current theme has a paired theme, selects the paired theme.
  /// If no paired theme exists, toggles only when mode allows.
  void toggleTheme() {
    if (_currentTheme == null) {
      // No dynamic theme loaded — use legacy toggle behavior
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
      notifyListeners();
      return;
    }

    final pairedId = _currentTheme!.pairedThemeId;

    if (pairedId != null) {
      // Switch to the paired theme via API
      selectTheme(pairedId);
      return;
    }

    // No paired theme — toggle is a no-op if constrained by mode
    // A light-only theme can't switch to dark, and vice versa
    debugPrint(
      '[ThemeProvider] toggleTheme no-op — no paired theme available for '
      'mode=${_currentTheme!.mode}',
    );
  }

  // ─── Set Theme Mode (legacy compat) ────────────────────────────────────

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  // ─── Private Helpers ────────────────────────────────────────────────────

  /// Applies a ThemeResult from the API response: compiles config, updates state.
  void _applyThemeFromResult(ThemeResult theme) {
    _selectedThemeId = theme.id;
    _currentTheme = theme;

    // Compile themeConfig into ShadThemeData instances
    final compiled = DynamicThemeBuilder.compile(theme.themeConfig);
    _compiledLightTheme = compiled.light;
    _compiledDarkTheme = compiled.dark;

    // Set themeMode based on the theme's declared mode
    _themeMode = theme.mode == 'dark' ? ThemeMode.dark : ThemeMode.light;
  }

  /// Resets compiled themes to AppTheme baselines (fallback path).
  void _fallbackToBaselines() {
    _compiledLightTheme = AppTheme.lightTheme;
    _compiledDarkTheme = AppTheme.darkTheme;
  }

  /// Loads the default theme for Super Admin without calling admin-theme/current.
  void _loadDefaultThemeForSuperAdmin() {
    // Super Admin uses the default (baseline) themes directly.
    // No API call needed — AppTheme baselines ARE the default theme.
    _selectedThemeId = null;
    _currentTheme = null;
    _compiledLightTheme = AppTheme.lightTheme;
    _compiledDarkTheme = AppTheme.darkTheme;
    _themeMode = ThemeMode.light;
    notifyListeners();
  }
}
