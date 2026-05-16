import 'package:flutter/material.dart';

import '../model/response/response.dart';
import '../repository/nextronix_repository.dart';

class HsnProvider extends ChangeNotifier {
  List<HsnResult> _hsnCodes = [];
  bool _isLoading = false;
  String? _error;

  List<HsnResult> get hsnCodes => _hsnCodes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<AlertErrorResponse?> loadHsnCodes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      HsnListResponse response = await NextronixRepository().getHsnCodes();
      _hsnCodes = response.data ?? [];
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load HSN codes';
      notifyListeners();
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  Future<AlertErrorResponse?> createHsn({
    required String hsnCode,
    required double gstPercent,
    String? description,
  }) async {
    try {
      CommonResponse response = await NextronixRepository().createHsn(
        hsnCode: hsnCode,
        gstPercent: gstPercent,
        description: description,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        await loadHsnCodes();
        return null;
      } else {
        return AlertErrorResponse(
          alertHeading: "Error!",
          alertMessage: response.message ?? "Failed to create HSN code",
        );
      }
    } catch (e) {
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  Future<AlertErrorResponse?> updateHsn({
    required int id,
    required String hsnCode,
    required double gstPercent,
    String? description,
  }) async {
    try {
      CommonResponse response = await NextronixRepository().updateHsn(
        id: id,
        hsnCode: hsnCode,
        gstPercent: gstPercent,
        description: description,
      );
      if (response.statusCode == 200) {
        await loadHsnCodes();
        return null;
      } else {
        return AlertErrorResponse(
          alertHeading: "Error!",
          alertMessage: response.message ?? "Failed to update HSN code",
        );
      }
    } catch (e) {
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  Future<AlertErrorResponse?> deleteHsn({required int id}) async {
    try {
      CommonResponse response = await NextronixRepository().deleteHsn(id: id);
      if (response.statusCode == 200) {
        await loadHsnCodes();
        return null;
      } else {
        return AlertErrorResponse(
          alertHeading: "Error!",
          alertMessage: response.message ?? "Failed to delete HSN code",
        );
      }
    } catch (e) {
      return AlertErrorResponse.getErrorResponse(e);
    }
  }
}
