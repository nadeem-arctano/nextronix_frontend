class PriceUpdateRequest {
  final double mrpPrice;
  final double sellingPrice;

  PriceUpdateRequest({required this.mrpPrice, required this.sellingPrice});

  factory PriceUpdateRequest.fromJson(Map<String, dynamic> json) =>
      PriceUpdateRequest(
        mrpPrice: (json['mrpPrice'] as num).toDouble(),
        sellingPrice: (json['sellingPrice'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
    "mrpPrice": mrpPrice,
    "sellingPrice": sellingPrice,
  };
}
