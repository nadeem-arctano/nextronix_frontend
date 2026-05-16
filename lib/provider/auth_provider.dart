import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/services/auth_storage.dart';
import '../model/response/response.dart';
import '../repository/nextronix_repository.dart';
import '../static_values/static_values.dart';

/// Manages the authenticated session for the admin panel:
/// - Login / logout
/// - Token persistence (via AuthStorage) — access + refresh
/// - Current user info (admin or manager) + brand context
/// - Permission set (resolved from server, cached globally)
class AuthProvider extends ChangeNotifier {
  bool _isInitializing = true;
  bool _isLoading = false;
  String? _error;
  UserResult? _user;
  ProfileResult? _profile;

  StreamSubscription<SessionEvent>? _sessionSub;

  bool get isInitializing => _isInitializing;
  bool get isLoading => _isLoading;
  String? get error => _error;
  UserResult? get user => _user;
  ProfileResult? get profile => _profile;

  bool get isAuthenticated => globalAccessToken != null && _user != null;
  bool get isAdmin => _user?.role == 'admin';
  bool get isManager => _user?.role == 'manager';

  /// Reactive permission helper for the UI (sidebar gating, action buttons).
  bool can(String key) => hasPermission(key);

  AuthProvider() {
    _sessionSub = sessionEvents.stream.listen((evt) async {
      if (evt == SessionEvent.forceLogout) {
        await _clearLocalSession();
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _sessionSub?.cancel();
    super.dispose();
  }

  /// Restores any saved session from local storage on app start.
  Future<void> bootstrap() async {
    _isInitializing = true;
    try {
      final token = await AuthStorage.readToken();
      final refresh = await AuthStorage.readRefreshToken();
      final userJson = await AuthStorage.readUser();
      if (token != null && userJson != null) {
        globalAccessToken = token;
        globalRefreshToken = refresh;
        _user = UserResult.fromJson(userJson);
        // Fetch fresh profile in background to validate token and fetch perms
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
      final access = data?.accessToken ?? data?.token;
      if (access == null || data?.user == null) {
        _isLoading = false;
        _error = response.message ?? 'Login failed';
        notifyListeners();
        return AlertErrorResponse(
          alertHeading: 'Error!',
          alertMessage: _error!,
        );
      }

      globalAccessToken = access;
      globalRefreshToken = data!.refreshToken;
      globalPermissions = data.permissions;
      _user = data.user;

      await AuthStorage.saveSession(
        token: access,
        refreshToken: data.refreshToken,
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
      // Sync permissions from the profile (newer than what login returned)
      if (response.data?.permissions.isNotEmpty == true) {
        globalPermissions = response.data!.permissions;
      }
      notifyListeners();
    } catch (_) {
      // ignore — token might be expired; the interceptor handles 401
    }
  }

  Future<void> logout({bool allDevices = false}) async {
    final refresh = globalRefreshToken;
    try {
      if (refresh != null) {
        await NextronixRepository().logout(
          refreshToken: refresh,
          allDevices: allDevices,
        );
      }
    } catch (_) {
      // best-effort — local clear runs anyway
    }
    await _clearLocalSession();
    notifyListeners();
  }

  Future<void> _clearLocalSession() async {
    globalAccessToken = null;
    globalRefreshToken = null;
    globalPermissions = const [];
    _user = null;
    _profile = null;
    await AuthStorage.clear();
  }
}
