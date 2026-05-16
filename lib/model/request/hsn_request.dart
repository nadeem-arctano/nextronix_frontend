class HsnRequest {
  final String? hsnCode;
  final double? gstPercent;
  final String? description;

  HsnRequest({this.hsnCode, this.gstPercent, this.description});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (hsnCode != null) map['hsnCode'] = hsnCode;
    if (gstPercent != null) map['gstPercent'] = gstPercent;
    if (description != null) map['description'] = description;
    return map;
  }
}
