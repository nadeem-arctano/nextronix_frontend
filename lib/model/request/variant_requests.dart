/// Body of PATCH /variants/:id/stock
class VariantStockRequest {
  final int stock;
  VariantStockRequest({required this.stock});
  Map<String, dynamic> toJson() => {'stock': stock};
}

/// Body of POST /variants/bulk
/// op: 'status' | 'stock' | 'price'
class VariantBulkRequest {
  final List<int> ids;
  final String op;
  final dynamic value; // status string OR stock int
  final double? mrp;
  final double? sellingPrice;

  VariantBulkRequest({
    required this.ids,
    required this.op,
    this.value,
    this.mrp,
    this.sellingPrice,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'ids': ids, 'op': op};
    if (value != null) map['value'] = value;
    if (mrp != null) map['mrp'] = mrp;
    if (sellingPrice != null) map['sellingPrice'] = sellingPrice;
    return map;
  }
}
