/// Body of `POST /api/products/groups`
///
/// Creates a new variant group from N existing standalone products.
/// `optionsByProduct` is a map keyed by product id (as a string because
/// dart:convert serialises int map keys oddly through Dio): each value
/// holds the color/size labels that product carries within the group.
class CreateVariantGroupRequest {
  final int parentId;
  final List<int> childIds;
  final Map<String, VariantGroupOption> optionsByProduct;

  CreateVariantGroupRequest({
    required this.parentId,
    required this.childIds,
    required this.optionsByProduct,
  });

  Map<String, dynamic> toJson() => {
    'parentId': parentId,
    'childIds': childIds,
    'options': optionsByProduct.map((k, v) => MapEntry(k, v.toJson())),
  };
}

/// Body of `POST /api/products/:id/group/add`
class AddToVariantGroupRequest {
  final int childId;
  final String? color;
  final String? size;

  AddToVariantGroupRequest({required this.childId, this.color, this.size});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'childId': childId};
    if (color != null) map['color'] = color;
    if (size != null) map['size'] = size;
    return map;
  }
}

/// Body of `PUT /api/products/:id/group/options`
class VariantGroupOption {
  final String? color;
  final String? size;
  VariantGroupOption({this.color, this.size});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (color != null) map['color'] = color;
    if (size != null) map['size'] = size;
    return map;
  }
}
