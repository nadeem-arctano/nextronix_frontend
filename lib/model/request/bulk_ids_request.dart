class BulkIdsRequest {
  final List<int>? ids;

  BulkIdsRequest({this.ids});

  factory BulkIdsRequest.fromJson(Map<String, dynamic> json) => BulkIdsRequest(
    ids: json["ids"] != null ? List<int>.from(json["ids"]) : null,
  );

  Map<String, dynamic> toJson() => {"ids": ids};
}
