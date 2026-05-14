import '../../core/utils/parsers.dart';

class PaymentResult {
  final int? id;
  final int? orderId;
  final String? transactionId;
  final String? paymentGateway;
  final double? amount;
  final String? paymentStatus;
  final String? paidAt;
  final String? createdAt;

  PaymentResult({
    this.id,
    this.orderId,
    this.transactionId,
    this.paymentGateway,
    this.amount,
    this.paymentStatus,
    this.paidAt,
    this.createdAt,
  });

  factory PaymentResult.fromJson(Map<String, dynamic> json) => PaymentResult(
    id: parseInt(json['id']),
    orderId: parseInt(json['orderId']),
    transactionId: json['transactionId']?.toString(),
    paymentGateway: json['paymentGateway']?.toString(),
    amount: parseDouble(json['amount']),
    paymentStatus: json['paymentStatus']?.toString() ?? 'pending',
    paidAt: json['paidAt']?.toString(),
    createdAt: json['createdAt']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "orderId": orderId,
    "transactionId": transactionId,
    "paymentGateway": paymentGateway,
    "amount": amount,
    "paymentStatus": paymentStatus,
    "paidAt": paidAt,
    "createdAt": createdAt,
  };
}
