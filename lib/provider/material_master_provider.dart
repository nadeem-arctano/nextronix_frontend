import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../api/base_url.dart';
import '../model/response/response.dart';
import '../static_values/static_values.dart';

/// A single material type record from the backend.
class MaterialMasterItem {
  final int id;
  final String name;
  final String? description;
  final String status;

  MaterialMasterItem({
    required this.id,
    required this.name,
    this.description,
    required this.status,
  });

  factory MaterialMasterItem.fromJson(Map<String, dynamic> json) {
    return MaterialMasterItem(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      status: (json['status'] as String?) ?? 'active',
    );
  }
}

/// Returned when the backend responds with HTTP 409 and code MASTER_IN_USE.
class MasterInUseError {
  final int referencingProductCount;
  final String message;

  MasterInUseError({
    required this.referencingProductCount,
    required this.message,
  });
}

class MaterialMasterProvider extends ChangeNotifier {
  List<MaterialMasterItem> _materials = [];
  bool _isLoading = false;
  String? _error;

  List<MaterialMasterItem> get materials => _materials;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Dio get _dio {
    final dio = Dio(
      BaseOptions(
        baseUrl: BaseUrl.baseurl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          if (globalAccessToken != null)
            'Authorization': 'Bearer $globalAccessToken',
        },
      ),
    );
    return dio;
  }

  Future<AlertErrorResponse?> loadMaterials() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _dio.get('super-admin/masters/materials');
      final data = response.data;
      final List<dynamic> rows = data is Map<String, dynamic>
          ? (data['data'] ?? [])
          : [];
      _materials = rows
          .map((e) => MaterialMasterItem.fromJson(e as Map<String, dynamic>))
          .toList();
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load materials';
      notifyListeners();
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  Future<AlertErrorResponse?> createMaterial({
    required String name,
    String? description,
    String? status,
  }) async {
    try {
      final body = <String, dynamic>{'name': name};
      if (description != null && description.isNotEmpty) {
        body['description'] = description;
      }
      if (status != null) body['status'] = status;

      await _dio.post('super-admin/masters/materials', data: body);
      await loadMaterials();
      return null;
    } catch (e) {
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  Future<AlertErrorResponse?> updateMaterial({
    required int id,
    required String name,
    String? description,
    String? status,
  }) async {
    try {
      final body = <String, dynamic>{'name': name};
      if (description != null) body['description'] = description;
      if (status != null) body['status'] = status;

      await _dio.put('super-admin/masters/materials/$id', data: body);
      await loadMaterials();
      return null;
    } catch (e) {
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  /// Deletes a material. Returns null on success, an [AlertErrorResponse] on
  /// failure, or a [MasterInUseError] when the backend responds with 409
  /// MASTER_IN_USE.
  Future<dynamic> deleteMaterial({required int id}) async {
    try {
      await _dio.delete('super-admin/masters/materials/$id');
      await loadMaterials();
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        final data = e.response?.data;
        if (data is Map<String, dynamic> && data['code'] == 'MASTER_IN_USE') {
          return MasterInUseError(
            referencingProductCount:
                data['referencingProductCount'] as int? ?? 0,
            message:
                data['message'] as String? ??
                'Cannot delete: products reference this material',
          );
        }
      }
      return AlertErrorResponse.getErrorResponse(e);
    } catch (e) {
      return AlertErrorResponse.getErrorResponse(e);
    }
  }
}
