class RegisterRequest {
  final String? name;
  final String? email;
  final String? password;
  final String? mobile;

  RegisterRequest({this.name, this.email, this.password, this.mobile});

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      RegisterRequest(
        name: json["name"],
        email: json["email"],
        password: json["password"],
        mobile: json["mobile"],
      );

  Map<String, dynamic> toJson() => {
    "name": name,
    "email": email,
    "password": password,
    "mobile": mobile,
  };
}
