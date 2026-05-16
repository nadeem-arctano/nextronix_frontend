import 'package:flutter/material.dart';

import '../model/response/response.dart';
import '../repository/nextronix_repository.dart';

class CouponProvider extends ChangeNotifier {
  List<CouponResult> _coupons = [];
  bool _isLoading = false;
  String? _error;

  List<CouponResult> get coupons => _coupons;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<AlertErrorResponse?> loadCoupons() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      CouponListResponse response = await NextronixRepository().getCoupons();
      _coupons = response.data ?? [];
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load coupons';
      notifyListeners();
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  Future<AlertErrorResponse?> createCoupon({
    required String code,
    required String discountType,
    required double discountValue,
    double? minOrderAmount,
    String? expiryDate,
    int? usageLimit,
    String? status,
  }) async {
    try {
      CommonResponse response = await NextronixRepository().createCoupon(
        code: code,
        discountType: discountType,
        discountValue: discountValue,
        minOrderAmount: minOrderAmount,
        expiryDate: expiryDate,
        usageLimit: usageLimit,
        status: status,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        await loadCoupons();
        return null;
      } else {
        return AlertErrorResponse(
          alertHeading: "Error!",
          alertMessage: response.message ?? "Failed to create coupon",
        );
      }
    } catch (e) {
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  Future<AlertErrorResponse?> updateCoupon({
    required int id,
    required String code,
    required String discountType,
    required double discountValue,
    double? minOrderAmount,
    String? expiryDate,
    int? usageLimit,
    String? status,
  }) async {
    try {
      CommonResponse response = await NextronixRepository().updateCoupon(
        id: id,
        code: code,
        discountType: discountType,
        discountValue: discountValue,
        minOrderAmount: minOrderAmount,
        expiryDate: expiryDate,
        usageLimit: usageLimit,
        status: status,
      );
      if (response.statusCode == 200) {
        await loadCoupons();
        return null;
      } else {
        return AlertErrorResponse(
          alertHeading: "Error!",
          alertMessage: response.message ?? "Failed to update coupon",
        );
      }
    } catch (e) {
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  Future<AlertErrorResponse?> deleteCoupon({required int id}) async {
    try {
      CommonResponse response = await NextronixRepository().deleteCoupon(
        id: id,
      );
      if (response.statusCode == 200) {
        await loadCoupons();
        return null;
      } else {
        return AlertErrorResponse(
          alertHeading: "Error!",
          alertMessage: response.message ?? "Failed to delete coupon",
        );
      }
    } catch (e) {
      return AlertErrorResponse.getErrorResponse(e);
    }
  }
}
