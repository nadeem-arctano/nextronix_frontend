import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../api/base_url.dart';
import '../model/response/response.dart';
import '../model/response/color_list_response.dart';
import '../static_values/static_values.dart';
import 'material_master_provider.dart' show MasterInUseError;

/// Provider for the colors master list with full CRUD support.
///
/// Fetches active colors from `GET /api/masters/colors` for use in the
/// Add Product wizard and other brand-user flows. Also provides
/// create/update/delete operations for the Super Admin CRUD screens.
class ColorMasterProvider extends ChangeNotifier {
  List<ColorResult> _colors = [];
  bool _isLoading = false;
  String? _error;

  List<ColorResult> get colors => _colors;
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

  /// Loads active colors from the read-only masters endpoint.
  Future<AlertErrorResponse?> loadColors() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _dio.get('super-admin/masters/colors');
      final data = response.data;
      final List<dynamic> rows = data is Map<String, dynamic>
          ? (data['data'] ?? [])
          : [];
      _colors = rows
          .map((e) => ColorResult.fromJson(e as Map<String, dynamic>))
          .toList();
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load colors';
      notifyListeners();
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  /// Creates a new color. Returns null on success, [AlertErrorResponse] on failure.
  Future<AlertErrorResponse?> createColor({
    required String name,
    String? hexCode,
    String? status,
  }) async {
    try {
      final body = <String, dynamic>{'name': name};
      if (hexCode != null && hexCode.isNotEmpty) body['hexCode'] = hexCode;
      if (status != null) body['status'] = status;

      await _dio.post('super-admin/masters/colors', data: body);
      await loadColors();
      return null;
    } catch (e) {
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  /// Updates an existing color. Returns null on success, [AlertErrorResponse] on failure.
  Future<AlertErrorResponse?> updateColor({
    required int id,
    required String name,
    String? hexCode,
    String? status,
  }) async {
    try {
      final body = <String, dynamic>{'name': name};
      if (hexCode != null) body['hexCode'] = hexCode;
      if (status != null) body['status'] = status;

      await _dio.put('super-admin/masters/colors/$id', data: body);
      await loadColors();
      return null;
    } catch (e) {
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  /// Deletes a color. Returns null on success, an [AlertErrorResponse] on
  /// failure, or a [MasterInUseError] when the backend responds with 409
  /// MASTER_IN_USE.
  Future<dynamic> deleteColor({required int id}) async {
    try {
      await _dio.delete('super-admin/masters/colors/$id');
      await loadColors();
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
                'Cannot delete: products reference this color',
          );
        }
      }
      return AlertErrorResponse.getErrorResponse(e);
    } catch (e) {
      return AlertErrorResponse.getErrorResponse(e);
    }
  }
}
