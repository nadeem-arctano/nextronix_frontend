class ReturnStatusUpdateRequest {
  final String? status;
  final String? adminRemark;
  final double? refundAmount;
  final String? refundMethod;

  ReturnStatusUpdateRequest({
    this.status,
    this.adminRemark,
    this.refundAmount,
    this.refundMethod,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (status != null) map['status'] = status;
    if (adminRemark != null) map['adminRemark'] = adminRemark;
    if (refundAmount != null) map['refundAmount'] = refundAmount;
    if (refundMethod != null) map['refundMethod'] = refundMethod;
    return map;
  }
}
