import 'package:flutter/foundation.dart';

import '../core/services/auth_storage.dart';
import '../model/response/response.dart';
import '../repository/nextronix_repository.dart';
import '../static_values/static_values.dart';

/// Manages the authenticated session for the admin panel:
/// - Login / logout
/// - Token persistence (via AuthStorage)
/// - Current user info (admin or manager) + brand context
class AuthProvider extends ChangeNotifier {
  bool _isInitializing = true;
  bool _isLoading = false;
  String? _error;
  UserResult? _user;
  ProfileResult? _profile;

  bool get isInitializing => _isInitializing;
  bool get isLoading => _isLoading;
  String? get error => _error;
  UserResult? get user => _user;
  ProfileResult? get profile => _profile;

  bool get isAuthenticated => globalAccessToken != null && _user != null;
  bool get isAdmin => _user?.role == 'admin';
  bool get isManager => _user?.role == 'manager';

  /// Restores any saved session from local storage on app start.
  Future<void> bootstrap() async {
    _isInitializing = true;
    try {
      final token = await AuthStorage.readToken();
      final userJson = await AuthStorage.readUser();
      if (token != null && userJson != null) {
        globalAccessToken = token;
        _user = UserResult.fromJson(userJson);
        // Fetch fresh profile in background to validate token
        // (if token is invalid the interceptor will clear it)
        _refreshProfile();
      }
    } catch (_) {
      await _clearLocalSession();
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  Future<AlertErrorResponse?> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await NextronixRepository().userLogin(
        email: email,
        password: password,
      );
      final data = response.data;
      if (data?.token == null || data?.user == null) {
        _isLoading = false;
        _error = response.message ?? 'Login failed';
        notifyListeners();
        return AlertErrorResponse(
          alertHeading: 'Error!',
          alertMessage: _error!,
        );
      }

      globalAccessToken = data!.token;
      _user = data.user;

      await AuthStorage.saveSession(
        token: data.token!,
        user: data.user!.toJson(),
      );

      // Pull full profile (with brand summary) for the UI
      await _refreshProfile();

      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      _error = 'Login failed';
      notifyListeners();
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  Future<void> _refreshProfile() async {
    try {
      final response = await NextronixRepository().getProfile();
      _profile = response.data;
      notifyListeners();
    } catch (_) {
      // ignore — token might be expired; the interceptor handles 401
    }
  }

  Future<void> logout() async {
    await _clearLocalSession();
    notifyListeners();
  }

  Future<void> _clearLocalSession() async {
    globalAccessToken = null;
    _user = null;
    _profile = null;
    await AuthStorage.clear();
  }
}
