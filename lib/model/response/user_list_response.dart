import '../../core/utils/parsers.dart';
import 'product_list_response.dart';

class UserListResponse {
  final int? statusCode;
  final String? message;
  final List<UserListResult>? data;
  final PaginationResult? pagination;

  UserListResponse({this.statusCode, this.message, this.data, this.pagination});

  factory UserListResponse.fromJson(Map<String, dynamic> json) =>
      UserListResponse(
        statusCode: json["status_code"] ?? json["statusCode"],
        message: json["message"],
        data: json["data"] == null
            ? null
            : List<UserListResult>.from(
                (json["data"] as List).map((e) => UserListResult.fromJson(e)),
              ),
        pagination: json["pagination"] == null
            ? null
            : PaginationResult.fromJson(json["pagination"]),
      );

  Map<String, dynamic> toJson() => {
    "status_code": statusCode,
    "message": message,
    "data": data?.map((e) => e.toJson()).toList(),
    "pagination": pagination?.toJson(),
  };
}

class UserListResult {
  final int? id;
  final String? name;
  final String? email;
  final String? mobile;
  final String? role;
  final String? status;
  final String? createdAt;

  UserListResult({
    this.id,
    this.name,
    this.email,
    this.mobile,
    this.role,
    this.status,
    this.createdAt,
  });

  factory UserListResult.fromJson(Map<String, dynamic> json) => UserListResult(
    id: parseInt(json['id']),
    name: json['name']?.toString(),
    email: json['email']?.toString(),
    mobile: json['mobile']?.toString(),
    role: json['role']?.toString(),
    status: json['status']?.toString() ?? 'active',
    createdAt: json['createdAt']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "mobile": mobile,
    "role": role,
    "status": status,
    "createdAt": createdAt,
  };
}
