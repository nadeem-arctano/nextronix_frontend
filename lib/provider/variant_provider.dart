import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../model/response/response.dart';
import '../repository/nextronix_repository.dart';

class VariantProvider extends ChangeNotifier {
  final NextronixRepository _repo = NextronixRepository();

  int? _productId;
  List<ProductVariant> _items = [];
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;

  int? get productId => _productId;
  List<ProductVariant> get items => _items;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;

  Future<AlertErrorResponse?> loadFor(int productId) async {
    _productId = productId;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final r = await _repo.getVariantsForProduct(productId: productId);
      _items = r.data ?? [];
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load variants';
      notifyListeners();
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  Future<AlertErrorResponse?> create({
    required int productId,
    required Map<String, dynamic> fields,
    MultipartFile? image,
  }) async {
    _isSaving = true;
    notifyListeners();
    try {
      await _repo.createVariant(
        productId: productId,
        fields: fields,
        image: image,
      );
      _isSaving = false;
      await loadFor(productId);
      return null;
    } catch (e) {
      _isSaving = false;
      notifyListeners();
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  Future<AlertErrorResponse?> update({
    required int id,
    required Map<String, dynamic> fields,
    MultipartFile? image,
  }) async {
    _isSaving = true;
    notifyListeners();
    try {
      await _repo.updateVariant(id: id, fields: fields, image: image);
      _isSaving = false;
      if (_productId != null) await loadFor(_productId!);
      return null;
    } catch (e) {
      _isSaving = false;
      notifyListeners();
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  Future<AlertErrorResponse?> delete(int id) async {
    try {
      await _repo.deleteVariant(id: id);
      if (_productId != null) await loadFor(_productId!);
      return null;
    } catch (e) {
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  Future<AlertErrorResponse?> updateStock({
    required int id,
    required int stock,
  }) async {
    try {
      await _repo.updateVariantStock(id: id, stock: stock);
      if (_productId != null) await loadFor(_productId!);
      return null;
    } catch (e) {
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  Future<AlertErrorResponse?> bulkUpdate({
    required List<int> ids,
    required String op,
    dynamic value,
    double? mrp,
    double? sellingPrice,
  }) async {
    try {
      await _repo.bulkUpdateVariants(
        ids: ids,
        op: op,
        value: value,
        mrp: mrp,
        sellingPrice: sellingPrice,
      );
      if (_productId != null) await loadFor(_productId!);
      return null;
    } catch (e) {
      return AlertErrorResponse.getErrorResponse(e);
    }
  }
}
