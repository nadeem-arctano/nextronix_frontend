/// Pure redirect resolver logic for role-based routing.
///
/// This module extracts the redirect decision logic from the GoRouter so it
/// can be unit-tested independently without a running Flutter application.

/// Returns the default dashboard path for a given user role.
///
/// - `super_admin` → `/super-admin/dashboard`
/// - `admin` or `manager` → `/admin/dashboard`
/// - `customer` → `/storefront`
/// - unknown/null → `/login`
String defaultDashboardForRole(String? role) {
  switch (role) {
    case 'super_admin':
      return '/super-admin/dashboard';
    case 'admin':
    case 'manager':
      return '/admin/dashboard';
    case 'customer':
      return '/storefront';
    default:
      return '/login';
  }
}

/// Resolves the redirect target for a given [role] navigating to [requestedPath].
///
/// Returns `null` if no redirect is needed (user is allowed to visit the path).
/// Returns a path string if the user should be redirected elsewhere.
///
/// Rules:
/// 1. If the user is not authenticated ([role] is null), redirect to `/login`
///    unless they are already on `/login`.
/// 2. If authenticated and on `/login`, redirect to the role's default dashboard.
/// 3. If a non-super_admin requests a `/super-admin/*` URL, redirect to their
///    role's default dashboard.
/// 4. If a super_admin requests an `/admin/*` URL, redirect to
///    `/super-admin/dashboard`.
/// 5. Otherwise, no redirect (return null).
String? resolveRedirect({
  required String? role,
  required String requestedPath,
  required bool isAuthenticated,
}) {
  // Unauthenticated users can only be on /login
  if (!isAuthenticated) {
    return requestedPath.startsWith('/login') ? null : '/login';
  }

  // Authenticated user sitting on /login → go to default dashboard
  if (requestedPath.startsWith('/login')) {
    return defaultDashboardForRole(role);
  }

  // Cross-role URL guards
  final isSuperPath = requestedPath.startsWith('/super-admin');
  final isAdminPath = requestedPath.startsWith('/admin');

  // Non-super_admin trying to access /super-admin/* → redirect to their dashboard
  if (isSuperPath && role != 'super_admin') {
    return defaultDashboardForRole(role);
  }

  // Super_admin trying to access /admin/* → redirect to super-admin dashboard
  if (isAdminPath && role == 'super_admin') {
    return '/super-admin/dashboard';
  }

  // No redirect needed
  return null;
}
