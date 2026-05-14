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
  final String? userId;
  final String? name;
  final String? email;
  final String? role;

  LoginResult({this.token, this.userId, this.name, this.email, this.role});

  factory LoginResult.fromJson(Map<String, dynamic> json) => LoginResult(
    token: json["token"],
    userId: json["userId"]?.toString(),
    name: json["name"],
    email: json["email"],
    role: json["role"],
  );

  Map<String, dynamic> toJson() => {
    "token": token,
    "userId": userId,
    "name": name,
    "email": email,
    "role": role,
  };
}
