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
  final String? id;
  final String? name;
  final String? email;
  final String? mobile;
  final String? role;
  final String? createdAt;

  ProfileResult({
    this.id,
    this.name,
    this.email,
    this.mobile,
    this.role,
    this.createdAt,
  });

  factory ProfileResult.fromJson(Map<String, dynamic> json) => ProfileResult(
    id: json["id"]?.toString(),
    name: json["name"],
    email: json["email"],
    mobile: json["mobile"],
    role: json["role"],
    createdAt: json["createdAt"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "mobile": mobile,
    "role": role,
    "createdAt": createdAt,
  };
}
