class ProfileResponse {
  final int? statusCode;
  final String? message;
  final ProfileResult? data;

  ProfileResponse({this.statusCode, this.message, this.data});

  factory ProfileResponse.fromJson(Map<String, dynamic> json) =>
      ProfileResponse(
        statusCode: json["status_code"] ?? json["statusCode"],
        message: json["message"],
        data: json["data"] == null
            ? null
            : ProfileResult.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "status_code": statusCode,
    "message": message,
    "data": data?.toJson(),
  };
}

class ProfileResult {
  final int? id;
  final int? parentAdminId;
  final String? name;
  final String? email;
  final String? mobile;
  final String? role;
  final String? status;
  final String? createdAt;
  final BrandSummary? brand;
  final List<String> permissions;

  ProfileResult({
    this.id,
    this.parentAdminId,
    this.name,
    this.email,
    this.mobile,
    this.role,
    this.status,
    this.createdAt,
    this.brand,
    this.permissions = const [],
  });

  /// Effective brand id this user operates under.
  /// - Admin → own id
  /// - Manager → parentAdminId
  int? get effectiveAdminId {
    if (role == 'admin') return id;
    return parentAdminId;
  }

  factory ProfileResult.fromJson(Map<String, dynamic> json) => ProfileResult(
    id: json["id"] is int
        ? json["id"]
        : int.tryParse(json["id"]?.toString() ?? ''),
    parentAdminId: json["parentAdminId"] is int
        ? json["parentAdminId"]
        : int.tryParse(json["parentAdminId"]?.toString() ?? ''),
    name: json["name"]?.toString(),
    email: json["email"]?.toString(),
    mobile: json["mobile"]?.toString(),
    role: json["role"]?.toString(),
    status: json["status"]?.toString(),
    createdAt: json["createdAt"]?.toString(),
    brand: json["brand"] != null ? BrandSummary.fromJson(json["brand"]) : null,
    permissions: (json["permissions"] is List)
        ? (json["permissions"] as List).map((e) => e.toString()).toList()
        : const [],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "parentAdminId": parentAdminId,
    "name": name,
    "email": email,
    "mobile": mobile,
    "role": role,
    "status": status,
    "createdAt": createdAt,
    "brand": brand?.toJson(),
    "permissions": permissions,
  };
}

class BrandSummary {
  final int? adminId;
  final String? businessName;
  final String? gstNumber;

  BrandSummary({this.adminId, this.businessName, this.gstNumber});

  factory BrandSummary.fromJson(Map<String, dynamic> json) => BrandSummary(
    adminId: json["adminId"] is int
        ? json["adminId"]
        : int.tryParse(json["adminId"]?.toString() ?? ''),
    businessName: json["businessName"]?.toString(),
    gstNumber: json["gstNumber"]?.toString(),
  );

  Map<String, dynamic> toJson() => {
    "adminId": adminId,
    "businessName": businessName,
    "gstNumber": gstNumber,
  };
}
