import 'package:flutter/foundation.dart';

import '../model/response/response.dart';
import '../repository/nextronix_repository.dart';

class TeamProvider extends ChangeNotifier {
  List<Manager> _managers = [];
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;

  final NextronixRepository _repo = NextronixRepository();

  List<Manager> get managers => _managers;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;

  Future<AlertErrorResponse?> loadManagers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _repo.getManagers();
      _managers = response.data ?? [];
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load managers';
      notifyListeners();
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  Future<AlertErrorResponse?> createManager({
    required String name,
    required String email,
    required String password,
    String? mobile,
  }) async {
    _isSaving = true;
    notifyListeners();
    try {
      await _repo.createManager(
        name: name,
        email: email,
        password: password,
        mobile: mobile,
      );
      await loadManagers();
      _isSaving = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isSaving = false;
      notifyListeners();
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  Future<AlertErrorResponse?> updateManager({
    required int id,
    String? name,
    String? email,
    String? mobile,
    String? password,
    String? status,
  }) async {
    _isSaving = true;
    notifyListeners();
    try {
      await _repo.updateManager(
        id: id,
        name: name,
        email: email,
        mobile: mobile,
        password: password,
        status: status,
      );
      await loadManagers();
      _isSaving = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isSaving = false;
      notifyListeners();
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  Future<AlertErrorResponse?> deleteManager(int id) async {
    try {
      await _repo.deleteManager(id: id);
      await loadManagers();
      return null;
    } catch (e) {
      return AlertErrorResponse.getErrorResponse(e);
    }
  }
}
