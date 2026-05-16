import '../../core/utils/parsers.dart';
import 'support_models.dart' show PaginationInfo;

class AuditLog {
  final int id;
  final int? adminId;
  final int? userId;
  final String module;
  final String action;
  final int? entityId;
  final String? entityType;
  final dynamic oldData;
  final dynamic newData;
  final String? ipAddress;
  final String? userAgent;
  final String? createdAt;
  final String? userName;
  final String? userEmail;
  final String? userRole;

  AuditLog({
    required this.id,
    this.adminId,
    this.userId,
    required this.module,
    required this.action,
    this.entityId,
    this.entityType,
    this.oldData,
    this.newData,
    this.ipAddress,
    this.userAgent,
    this.createdAt,
    this.userName,
    this.userEmail,
    this.userRole,
  });

  factory AuditLog.fromJson(Map<String, dynamic> json) => AuditLog(
    id: parseInt(json['id']),
    adminId: json['adminId'] != null ? parseInt(json['adminId']) : null,
    userId: json['userId'] != null ? parseInt(json['userId']) : null,
    module: json['module']?.toString() ?? '',
    action: json['action']?.toString() ?? '',
    entityId: json['entityId'] != null ? parseInt(json['entityId']) : null,
    entityType: json['entityType']?.toString(),
    oldData: json['oldData'],
    newData: json['newData'],
    ipAddress: json['ipAddress']?.toString(),
    userAgent: json['userAgent']?.toString(),
    createdAt: json['createdAt']?.toString(),
    userName: json['userName']?.toString(),
    userEmail: json['userEmail']?.toString(),
    userRole: json['userRole']?.toString(),
  );
}

class AuditLogListResponse {
  final bool? success;
  final String? message;
  final List<AuditLog>? data;
  final PaginationInfo? pagination;

  AuditLogListResponse({
    this.success,
    this.message,
    this.data,
    this.pagination,
  });

  factory AuditLogListResponse.fromJson(Map<String, dynamic> json) =>
      AuditLogListResponse(
        success: json['success'],
        message: json['message']?.toString(),
        data: json['data'] != null
            ? (json['data'] as List).map((e) => AuditLog.fromJson(e)).toList()
            : null,
        pagination: json['pagination'] != null
            ? PaginationInfo.fromJson(json['pagination'])
            : null,
      );
}

class AuditLogDetailResponse {
  final bool? success;
  final String? message;
  final AuditLog? data;

  AuditLogDetailResponse({this.success, this.message, this.data});

  factory AuditLogDetailResponse.fromJson(Map<String, dynamic> json) =>
      AuditLogDetailResponse(
        success: json['success'],
        message: json['message']?.toString(),
        data: json['data'] != null ? AuditLog.fromJson(json['data']) : null,
      );
}

class AuditFiltersResponse {
  final bool? success;
  final String? message;
  final List<String> modules;
  final List<String> actions;

  AuditFiltersResponse({
    this.success,
    this.message,
    this.modules = const [],
    this.actions = const [],
  });

  factory AuditFiltersResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return AuditFiltersResponse(
      success: json['success'],
      message: json['message']?.toString(),
      modules: (data['modules'] is List)
          ? (data['modules'] as List).map((e) => e.toString()).toList()
          : const [],
      actions: (data['actions'] is List)
          ? (data['actions'] as List).map((e) => e.toString()).toList()
          : const [],
    );
  }
}
