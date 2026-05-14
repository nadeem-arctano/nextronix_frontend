class CommonResponse {
  final int? statusCode;
  final String? message;
  final dynamic data;

  CommonResponse({this.statusCode, this.message, this.data});

  factory CommonResponse.fromJson(Map<String, dynamic> json) => CommonResponse(
    statusCode: json["status_code"] ?? json["statusCode"],
    message: json["message"],
    data: json["data"],
  );

  Map<String, dynamic> toJson() => {
    "status_code": statusCode,
    "message": message,
    "data": data,
  };
}
