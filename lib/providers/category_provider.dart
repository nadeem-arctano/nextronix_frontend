import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/services/api_service.dart';
import '../core/constants/api_constants.dart';
import '../models/category_model.dart';

class CategoryProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<CategoryModel> categories = [];
  bool isLoading = false;
  String? error;

  Future<void> loadCategories() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await _api.get(ApiConstants.categories);
      categories = (response.data['data'] as List)
          .map((e) => CategoryModel.fromJson(e))
          .toList();
    } catch (e) {
      error = 'Failed to load categories';
      debugPrint('Categories error: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  Future<bool> createCategory(FormData formData) async {
    try {
      await _api.upload(ApiConstants.categories, formData);
      await loadCategories();
      return true;
    } catch (e) {
      error = 'Failed to create category';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCategory(int id, FormData formData) async {
    try {
      await _api.uploadPut('${ApiConstants.categories}/$id', formData);
      await loadCategories();
      return true;
    } catch (e) {
      error = 'Failed to update category';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCategory(int id) async {
    try {
      await _api.delete('${ApiConstants.categories}/$id');
      await loadCategories();
      return true;
    } catch (e) {
      error = 'Failed to delete category';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCategoryStatus(int id, String status) async {
    try {
      await _api.patch(
        '${ApiConstants.categories}/$id/status',
        data: {'status': status},
      );
      await loadCategories();
      return true;
    } catch (e) {
      return false;
    }
  }
}
