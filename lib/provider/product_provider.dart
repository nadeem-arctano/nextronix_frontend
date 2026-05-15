import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../model/response/response.dart';
import '../repository/nextronix_repository.dart';

class ProductProvider extends ChangeNotifier {
  List<ProductResult> _products = [];
  List<HsnResult> _hsnCodes = [];
  ProductResult? _selectedProduct;
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;

  // Filters
  String? _searchQuery;
  String? _categoryFilter;
  String? _statusFilter;
  String? _sortBy;
  String? _stockFilter; // low, out, in
  bool? _featuredFilter;
  double? _minPrice;
  double? _maxPrice;

  List<ProductResult> get products => _products;
  List<HsnResult> get hsnCodes => _hsnCodes;
  ProductResult? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalItems => _totalItems;
  String? get searchQuery => _searchQuery;
  String? get categoryFilter => _categoryFilter;
  String? get statusFilter => _statusFilter;
  String? get sortBy => _sortBy;
  String? get stockFilter => _stockFilter;
  bool? get featuredFilter => _featuredFilter;
  double? get minPrice => _minPrice;
  double? get maxPrice => _maxPrice;

  Future<AlertErrorResponse?> loadProducts({int page = 1}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      ProductListResponse response = await NextronixRepository().getProducts(
        page: page,
        search: _searchQuery,
        category: _categoryFilter,
        status: _statusFilter,
        sortBy: _sortBy,
        stock: _stockFilter,
        featured: _featuredFilter,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
      );

      _products = response.data ?? [];
      _currentPage = response.pagination?.currentPage ?? 1;
      _totalPages = response.pagination?.totalPages ?? 1;
      _totalItems = response.pagination?.totalItems ?? 0;
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load products';
      notifyListeners();
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  Future<AlertErrorResponse?> loadProductById({required int id}) async {
    _isLoading = true;
    notifyListeners();

    try {
      ProductDetailResponse response = await NextronixRepository()
          .getProductById(id: id);
      _selectedProduct = response.data;
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load product';
      notifyListeners();
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  Future<AlertErrorResponse?> createProduct({
    required FormData formData,
  }) async {
    try {
      CommonResponse response = await NextronixRepository().createProduct(
        formData: formData,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        await loadProducts();
        return null;
      } else {
        return AlertErrorResponse(
          alertHeading: "Error!",
          alertMessage: response.message ?? "Failed to create product",
        );
      }
    } catch (e) {
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  Future<AlertErrorResponse?> updateProduct({
    required int id,
    required FormData formData,
  }) async {
    try {
      CommonResponse response = await NextronixRepository().updateProduct(
        id: id,
        formData: formData,
      );
      if (response.statusCode == 200) {
        await loadProducts(page: _currentPage);
        return null;
      } else {
        return AlertErrorResponse(
          alertHeading: "Error!",
          alertMessage: response.message ?? "Failed to update product",
        );
      }
    } catch (e) {
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  Future<AlertErrorResponse?> deleteProduct({required int id}) async {
    try {
      CommonResponse response = await NextronixRepository().deleteProduct(
        id: id,
      );
      if (response.statusCode == 200) {
        await loadProducts(page: _currentPage);
        return null;
      } else {
        return AlertErrorResponse(
          alertHeading: "Error!",
          alertMessage: response.message ?? "Failed to delete product",
        );
      }
    } catch (e) {
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  Future<AlertErrorResponse?> updateProductStatus({
    required int id,
    required String status,
  }) async {
    try {
      CommonResponse response = await NextronixRepository().updateProductStatus(
        id: id,
        status: status,
      );
      if (response.statusCode == 200) {
        await loadProducts(page: _currentPage);
        return null;
      } else {
        return AlertErrorResponse(
          alertHeading: "Error!",
          alertMessage: response.message ?? "Failed to update status",
        );
      }
    } catch (e) {
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  Future<AlertErrorResponse?> toggleFeatured({required int id}) async {
    try {
      CommonResponse response = await NextronixRepository()
          .toggleProductFeatured(id: id);
      if (response.statusCode == 200) {
        await loadProducts(page: _currentPage);
        return null;
      } else {
        return AlertErrorResponse(
          alertHeading: "Error!",
          alertMessage: response.message ?? "Failed to toggle featured",
        );
      }
    } catch (e) {
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  void setSearch(String? query) {
    _searchQuery = query;
    loadProducts();
  }

  /// Updates only the filters explicitly passed; others stay unchanged
  void setFilters({
    String? search,
    String? category,
    String? status,
    String? sort,
    String? stock,
    bool? featured,
    double? minPrice,
    double? maxPrice,
    bool clearOthers = false,
  }) {
    if (clearOthers) {
      _searchQuery = search;
      _categoryFilter = category;
      _statusFilter = status;
      _sortBy = sort;
      _stockFilter = stock;
      _featuredFilter = featured;
      _minPrice = minPrice;
      _maxPrice = maxPrice;
    } else {
      _searchQuery = search ?? _searchQuery;
      _categoryFilter = category ?? _categoryFilter;
      _statusFilter = status ?? _statusFilter;
      _sortBy = sort ?? _sortBy;
      _stockFilter = stock ?? _stockFilter;
      _featuredFilter = featured ?? _featuredFilter;
      _minPrice = minPrice ?? _minPrice;
      _maxPrice = maxPrice ?? _maxPrice;
    }
    loadProducts();
  }

  /// Set status filter (passing null clears it)
  void setStatus(String? status) {
    _statusFilter = status;
    loadProducts();
  }

  /// Set category filter (passing null clears it)
  void setCategory(String? category) {
    _categoryFilter = category;
    loadProducts();
  }

  /// Set stock filter (low/out/in/null)
  void setStock(String? stock) {
    _stockFilter = stock;
    loadProducts();
  }

  /// Toggle featured filter
  void setFeatured(bool? featured) {
    _featuredFilter = featured;
    loadProducts();
  }

  /// Set sort order
  void setSort(String? sort) {
    _sortBy = sort;
    loadProducts();
  }

  void setPriceRange(double? min, double? max) {
    _minPrice = min;
    _maxPrice = max;
    loadProducts();
  }

  void clearFilters() {
    _searchQuery = null;
    _categoryFilter = null;
    _statusFilter = null;
    _sortBy = null;
    _stockFilter = null;
    _featuredFilter = null;
    _minPrice = null;
    _maxPrice = null;
    loadProducts();
  }

  Future<void> loadHsnCodes() async {
    try {
      final response = await NextronixRepository().getHsnCodes();
      _hsnCodes = response.data ?? [];
      notifyListeners();
    } catch (_) {
      // Silent fail - HSN is optional
    }
  }
}
