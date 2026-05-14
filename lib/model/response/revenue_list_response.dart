import '../../core/utils/parsers.dart';

class RevenueListResponse {
  final int? statusCode;
  final String? message;
  final List<RevenueResult>? data;

  RevenueListResponse({this.statusCode, this.message, this.data});

  factory RevenueListResponse.fromJson(Map<String, dynamic> json) =>
      RevenueListResponse(
        statusCode: json["status_code"] ?? json["statusCode"],
        message: json["message"],
        data: json["data"] == null
            ? null
            : List<RevenueResult>.from(
                (json["data"] as List).map((e) => RevenueResult.fromJson(e)),
              ),
      );

  Map<String, dynamic> toJson() => {
    "status_code": statusCode,
    "message": message,
    "data": data?.map((e) => e.toJson()).toList(),
  };
}

class RevenueResult {
  final String? date;
  final double? revenue;
  final int? orders;

  RevenueResult({this.date, this.revenue, this.orders});

  factory RevenueResult.fromJson(Map<String, dynamic> json) => RevenueResult(
    date: json['date']?.toString(),
    revenue: parseDouble(json['revenue']),
    orders: parseInt(json['orders']),
  );

  Map<String, dynamic> toJson() => {
    "date": date,
    "revenue": revenue,
    "orders": orders,
  };
}
