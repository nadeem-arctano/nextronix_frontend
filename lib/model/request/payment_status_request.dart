class PaymentStatusRequest {
  final String? paymentStatus;

  PaymentStatusRequest({this.paymentStatus});

  factory PaymentStatusRequest.fromJson(Map<String, dynamic> json) =>
      PaymentStatusRequest(paymentStatus: json["paymentStatus"]);

  Map<String, dynamic> toJson() => {"paymentStatus": paymentStatus};
}
