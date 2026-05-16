class CreateManagerRequest {
  final String? name;
  final String? email;
  final String? password;
  final String? mobile;

  CreateManagerRequest({this.name, this.email, this.password, this.mobile});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (name != null) map['name'] = name;
    if (email != null) map['email'] = email;
    if (password != null) map['password'] = password;
    if (mobile != null) map['mobile'] = mobile;
    return map;
  }
}

class UpdateManagerRequest {
  final String? name;
  final String? email;
  final String? mobile;
  final String? password;
  final String? status;

  UpdateManagerRequest({
    this.name,
    this.email,
    this.mobile,
    this.password,
    this.status,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (name != null) map['name'] = name;
    if (email != null) map['email'] = email;
    if (mobile != null) map['mobile'] = mobile;
    if (password != null) map['password'] = password;
    if (status != null) map['status'] = status;
    return map;
  }
}
