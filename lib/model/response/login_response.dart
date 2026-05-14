import '../../core/utils/parsers.dart';

class LoginResponse {
  final int? statusCode;
  final String? message;
  final LoginResult? data;

  LoginResponse({this.statusCode, this.message, this.data});

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    statusCode: json["status_code"] ?? json["statusCode"],
    message: json["message"],
    data: json["data"] == null ? null : LoginResult.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status_code": statusCode,
    "message": message,
    "data": data?.toJson(),
  };
}

class LoginResult {
  final String? token;
  final UserResult? user;

  LoginResult({this.token, this.user});

  factory LoginResult.fromJson(Map<String, dynamic> json) => LoginResult(
    token: json["token"],
    user: json["user"] == null ? null : UserResult.fromJson(json["user"]),
  );

  Map<String, dynamic> toJson() => {"token": token, "user": user?.toJson()};
}

class UserResult {
  final int? id;
  final String? name;
  final String? email;
  final String? mobile;
  final String? role;
  final String? status;
  final String? createdAt;
  final String? updatedAt;

  UserResult({
    this.id,
    this.name,
    this.email,
    this.mobile,
    this.role,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory UserResult.fromJson(Map<String, dynamic> json) => UserResult(
    id: parseInt(json['id']),
    name: json['name']?.toString(),
    email: json['email']?.toString(),
    mobile: json['mobile']?.toString(),
    role: json['role']?.toString(),
    status: json['status']?.toString(),
    createdAt: json['createdAt']?.toString(),
    updatedAt: json['updatedAt']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "mobile": mobile,
    "role": role,
    "status": status,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
  };
}
