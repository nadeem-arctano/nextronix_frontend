/// Body of PUT /permissions/managers/:userId — replaces the full grant set.
class PermissionReplaceRequest {
  final List<String> keys;
  PermissionReplaceRequest({required this.keys});
  Map<String, dynamic> toJson() => {'keys': keys};
}

/// Body of POST /permissions/managers/:userId/{grant|revoke}
class PermissionKeyRequest {
  final String key;
  PermissionKeyRequest({required this.key});
  Map<String, dynamic> toJson() => {'key': key};
}
