class StockUpdateRequest {
  final int stockQuantity;

  StockUpdateRequest({required this.stockQuantity});

  factory StockUpdateRequest.fromJson(Map<String, dynamic> json) =>
      StockUpdateRequest(stockQuantity: json['stockQuantity'] as int);

  Map<String, dynamic> toJson() => {"stockQuantity": stockQuantity};
}
