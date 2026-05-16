import 'dart:async';

/// Global access token for API authentication
String? globalAccessToken;

/// Global refresh token (rotated on every refresh call)
String? globalRefreshToken;

/// Cached resolved permissions for the current user.
/// Admins receive `['*']`; managers receive their explicit grant set.
List<String> globalPermissions = const [];

/// Convenience: returns true if the current user holds the given key.
/// Admins (with `*`) always pass.
bool hasPermission(String key) =>
    globalPermissions.contains('*') || globalPermissions.contains(key);

/// Global user ID
String? globalUserId;

/// Uploads base URL for images
const String uploadsBaseUrl = "http://localhost:8080/uploads";

/// Lightweight global event bus for cross-cutting auth events.
///
/// The repository's interceptor publishes `SessionEvent.forceLogout` here when
/// a refresh attempt fails, and AuthProvider listens to clean up its in-memory
/// state without creating a hard dependency on the Dio layer.
enum SessionEvent { forceLogout }

final StreamController<SessionEvent> sessionEvents =
    StreamController<SessionEvent>.broadcast();
