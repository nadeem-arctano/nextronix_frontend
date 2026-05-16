/// Body of POST /auth/refresh
class RefreshTokenRequest {
  final String refreshToken;
  RefreshTokenRequest({required this.refreshToken});
  Map<String, dynamic> toJson() => {"refreshToken": refreshToken};
}

/// Body of POST /auth/logout
class LogoutRequest {
  final String? refreshToken;
  final bool? allDevices;

  LogoutRequest({this.refreshToken, this.allDevices});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (refreshToken != null) map['refreshToken'] = refreshToken;
    if (allDevices != null) map['allDevices'] = allDevices;
    return map;
  }
}
