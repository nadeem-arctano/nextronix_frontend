import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/services/api_service.dart';
import '../core/constants/api_constants.dart';
import '../models/product_model.dart';

class ProductProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<ProductModel> products = [];
  ProductModel? selectedProduct;
  bool isLoading = false;
  String? error;
  int currentPage = 1;
  int totalPages = 1;
  int totalItems = 0;

  // Filters
  String? searchQuery;
  String? categoryFilter;
  String? statusFilter;
  String? sortBy;

  Future<void> loadProducts({int page = 1}) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final params = <String, dynamic>{'page': page, 'limit': 10};
      if (searchQuery != null && searchQuery!.isNotEmpty)
        params['search'] = searchQuery;
      if (categoryFilter != null) params['category'] = categoryFilter;
      if (statusFilter != null) params['status'] = statusFilter;
      if (sortBy != null) params['sortBy'] = sortBy;

      final response = await _api.get(
        ApiConstants.products,
        queryParams: params,
      );
      final data = response.data;

      products = (data['data'] as List)
          .map((e) => ProductModel.fromJson(e))
          .toList();
      currentPage = data['pagination']['currentPage'];
      totalPages = data['pagination']['totalPages'];
      totalItems = data['pagination']['totalItems'];
    } catch (e) {
      error = 'Failed to load products';
      debugPrint('Products error: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> loadProductById(int id) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await _api.get('${ApiConstants.products}/$id');
      selectedProduct = ProductModel.fromJson(response.data['data']);
    } catch (e) {
      error = 'Failed to load product';
    }

    isLoading = false;
    notifyListeners();
  }

  Future<bool> createProduct(FormData formData) async {
    try {
      await _api.upload(ApiConstants.products, formData);
      await loadProducts();
      return true;
    } catch (e) {
      error = 'Failed to create product';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProduct(int id, FormData formData) async {
    try {
      await _api.uploadPut('${ApiConstants.products}/$id', formData);
      await loadProducts(page: currentPage);
      return true;
    } catch (e) {
      error = 'Failed to update product';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProduct(int id) async {
    try {
      await _api.delete('${ApiConstants.products}/$id');
      await loadProducts(page: currentPage);
      return true;
    } catch (e) {
      error = 'Failed to delete product';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProductStatus(int id, String status) async {
    try {
      await _api.patch(
        '${ApiConstants.products}/$id/status',
        data: {'status': status},
      );
      await loadProducts(page: currentPage);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> toggleFeatured(int id) async {
    try {
      await _api.patch('${ApiConstants.products}/$id/featured');
      await loadProducts(page: currentPage);
      return true;
    } catch (e) {
      return false;
    }
  }

  void setSearch(String? query) {
    searchQuery = query;
    loadProducts();
  }

  void setFilters({String? category, String? status, String? sort}) {
    categoryFilter = category;
    statusFilter = status;
    sortBy = sort;
    loadProducts();
  }

  void clearFilters() {
    searchQuery = null;
    categoryFilter = null;
    statusFilter = null;
    sortBy = null;
    loadProducts();
  }
}
