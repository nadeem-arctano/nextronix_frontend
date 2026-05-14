class StatusRequest {
  final String? status;

  StatusRequest({this.status});

  factory StatusRequest.fromJson(Map<String, dynamic> json) =>
      StatusRequest(status: json["status"]);

  Map<String, dynamic> toJson() => {"status": status};
}
