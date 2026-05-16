class PermissionDef {
  final String key;
  final String label;
  final String module;
  final String? description;

  PermissionDef({
    required this.key,
    required this.label,
    required this.module,
    this.description,
  });

  factory PermissionDef.fromJson(Map<String, dynamic> json) => PermissionDef(
    key: json['key']?.toString() ?? '',
    label: json['label']?.toString() ?? '',
    module: json['module']?.toString() ?? '',
    description: json['description']?.toString(),
  );
}

class PermissionCatalogResponse {
  final bool? success;
  final String? message;
  final List<PermissionDef>? data;

  PermissionCatalogResponse({this.success, this.message, this.data});

  factory PermissionCatalogResponse.fromJson(Map<String, dynamic> json) =>
      PermissionCatalogResponse(
        success: json['success'],
        message: json['message']?.toString(),
        data: json['data'] != null
            ? (json['data'] as List)
                  .map((e) => PermissionDef.fromJson(e))
                  .toList()
            : null,
      );
}

class ManagerPermissionsResponse {
  final bool? success;
  final String? message;
  final List<String> data;

  ManagerPermissionsResponse({
    this.success,
    this.message,
    this.data = const [],
  });

  factory ManagerPermissionsResponse.fromJson(Map<String, dynamic> json) =>
      ManagerPermissionsResponse(
        success: json['success'],
        message: json['message']?.toString(),
        data: json['data'] != null
            ? (json['data'] as List).map((e) => e.toString()).toList()
            : const [],
      );
}
