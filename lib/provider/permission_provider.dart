import 'package:flutter/foundation.dart';

import '../model/response/response.dart';
import '../repository/nextronix_repository.dart';

class PermissionProvider extends ChangeNotifier {
  final NextronixRepository _repo = NextronixRepository();

  List<PermissionDef> _catalog = [];
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;

  // Per-manager grants we've fetched
  final Map<int, Set<String>> _grants = {};

  List<PermissionDef> get catalog => _catalog;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;

  /// Catalog grouped by module — handy for the matrix UI.
  Map<String, List<PermissionDef>> get catalogByModule {
    final grouped = <String, List<PermissionDef>>{};
    for (final p in _catalog) {
      grouped.putIfAbsent(p.module, () => []).add(p);
    }
    return grouped;
  }

  Set<String> grantsFor(int userId) =>
      Set<String>.from(_grants[userId] ?? const <String>{});

  Future<AlertErrorResponse?> loadCatalog() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final r = await _repo.getPermissionCatalog();
      _catalog = r.data ?? [];
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load permission catalog';
      notifyListeners();
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  Future<AlertErrorResponse?> loadGrantsFor(int userId) async {
    try {
      final r = await _repo.getManagerPermissions(userId: userId);
      _grants[userId] = r.data.toSet();
      notifyListeners();
      return null;
    } catch (e) {
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  Future<AlertErrorResponse?> save({
    required int userId,
    required Set<String> keys,
  }) async {
    _isSaving = true;
    notifyListeners();
    try {
      await _repo.replaceManagerPermissions(
        userId: userId,
        keys: keys.toList(),
      );
      _grants[userId] = Set<String>.from(keys);
      _isSaving = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isSaving = false;
      notifyListeners();
      return AlertErrorResponse.getErrorResponse(e);
    }
  }
}
