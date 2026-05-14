class BulkStatusRequest {
  final List<int>? ids;
  final String? status;

  BulkStatusRequest({this.ids, this.status});

  factory BulkStatusRequest.fromJson(Map<String, dynamic> json) =>
      BulkStatusRequest(
        ids: json["ids"] != null ? List<int>.from(json["ids"]) : null,
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {"ids": ids, "status": status};
}
