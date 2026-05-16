import '../../core/utils/parsers.dart';

class Manager {
  final int id;
  final int? parentAdminId;
  final String? name;
  final String? email;
  final String? mobile;
  final String? role;
  final String? status;
  final String? createdAt;
  final String? updatedAt;

  Manager({
    this.id = 0,
    this.parentAdminId,
    this.name,
    this.email,
    this.mobile,
    this.role,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Manager.fromJson(Map<String, dynamic> json) => Manager(
    id: parseInt(json['id']),
    parentAdminId: json['parentAdminId'] != null
        ? parseInt(json['parentAdminId'])
        : null,
    name: json['name']?.toString(),
    email: json['email']?.toString(),
    mobile: json['mobile']?.toString(),
    role: json['role']?.toString(),
    status: json['status']?.toString(),
    createdAt: json['createdAt']?.toString(),
    updatedAt: json['updatedAt']?.toString(),
  );
}

class ManagerListResponse {
  final bool? success;
  final String? message;
  final List<Manager>? data;

  ManagerListResponse({this.success, this.message, this.data});

  factory ManagerListResponse.fromJson(Map<String, dynamic> json) =>
      ManagerListResponse(
        success: json['success'],
        message: json['message']?.toString(),
        data: json['data'] != null
            ? (json['data'] as List).map((e) => Manager.fromJson(e)).toList()
            : null,
      );
}

class ManagerDetailResponse {
  final bool? success;
  final String? message;
  final Manager? data;

  ManagerDetailResponse({this.success, this.message, this.data});

  factory ManagerDetailResponse.fromJson(Map<String, dynamic> json) =>
      ManagerDetailResponse(
        success: json['success'],
        message: json['message']?.toString(),
        data: json['data'] != null ? Manager.fromJson(json['data']) : null,
      );
}
