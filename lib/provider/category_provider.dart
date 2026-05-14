import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../model/response/response.dart';
import '../repository/nextronix_repository.dart';

class CategoryProvider extends ChangeNotifier {
  List<CategoryResult> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<CategoryResult> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<AlertErrorResponse?> loadCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      CategoryListResponse response = await NextronixRepository()
          .getCategories();
      _categories = response.data ?? [];
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load categories';
      notifyListeners();
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  Future<AlertErrorResponse?> createCategory({
    required String name,
    String? description,
    String? status,
    MultipartFile? image,
  }) async {
    try {
      CommonResponse response = await NextronixRepository().createCategory(
        name: name,
        description: description,
        status: status,
        image: image,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        await loadCategories();
        return null;
      } else {
        return AlertErrorResponse(
          alertHeading: "Error!",
          alertMessage: response.message ?? "Failed to create category",
        );
      }
    } catch (e) {
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  Future<AlertErrorResponse?> updateCategory({
    required int id,
    required String name,
    String? description,
    String? status,
    MultipartFile? image,
  }) async {
    try {
      CommonResponse response = await NextronixRepository().updateCategory(
        id: id,
        name: name,
        description: description,
        status: status,
        image: image,
      );
      if (response.statusCode == 200) {
        await loadCategories();
        return null;
      } else {
        return AlertErrorResponse(
          alertHeading: "Error!",
          alertMessage: response.message ?? "Failed to update category",
        );
      }
    } catch (e) {
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  Future<AlertErrorResponse?> deleteCategory({required int id}) async {
    try {
      CommonResponse response = await NextronixRepository().deleteCategory(
        id: id,
      );
      if (response.statusCode == 200) {
        await loadCategories();
        return null;
      } else {
        return AlertErrorResponse(
          alertHeading: "Error!",
          alertMessage: response.message ?? "Failed to delete category",
        );
      }
    } catch (e) {
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  Future<AlertErrorResponse?> updateCategoryStatus({
    required int id,
    required String status,
  }) async {
    try {
      CommonResponse response = await NextronixRepository()
          .updateCategoryStatus(id: id, status: status);
      if (response.statusCode == 200) {
        await loadCategories();
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
}
