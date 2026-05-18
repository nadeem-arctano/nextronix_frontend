/// Sidebar entry resolver logic.
///
/// Encapsulates the rules that determine which sidebar navigation entries
/// are visible for a given user role. This mirrors the behavior in
/// `admin_layout.dart` and `super_admin_layout.dart`.
///
/// See Requirements 11.1, 11.2, 11.3.

/// Represents a single sidebar navigation entry.
class SidebarEntry {
  final String label;
  final String path;

  const SidebarEntry({required this.label, required this.path});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SidebarEntry &&
          runtimeType == other.runtimeType &&
          label == other.label &&
          path == other.path;

  @override
  int get hashCode => label.hashCode ^ path.hashCode;

  @override
  String toString() => 'SidebarEntry($label, $path)';
}

/// The fixed sidebar entries for super_admin role (Requirement 11.1).
const List<SidebarEntry> superAdminEntries = [
  SidebarEntry(label: 'Dashboard', path: '/super-admin/dashboard'),
  SidebarEntry(label: 'Admins', path: '/super-admin/admins'),
  SidebarEntry(label: 'Categories', path: '/super-admin/masters/categories'),
  SidebarEntry(label: 'HSN', path: '/super-admin/masters/hsn'),
  SidebarEntry(label: 'Colors', path: '/super-admin/masters/colors'),
  SidebarEntry(label: 'Materials', path: '/super-admin/masters/materials'),
];

/// Entries that are hidden from admin/manager sidebars (Requirement 11.2).
/// These are the entries that moved to the super_admin shell.
const Set<String> hiddenForBrandRoles = {
  'Categories',
  'HSN Codes',
  'Colors',
  'Materials',
  'Admins',
};

/// The brand-management entries that admin sees (Requirement 11.3).
/// These are preserved for admin/manager regardless of the master data move.
const List<SidebarEntry> adminBrandEntries = [
  SidebarEntry(label: 'Dashboard', path: '/admin/dashboard'),
  SidebarEntry(label: 'Products', path: '/admin/products'),
  SidebarEntry(label: 'Orders', path: '/admin/orders'),
  SidebarEntry(label: 'Customers', path: '/admin/users'),
  SidebarEntry(label: 'Coupons', path: '/admin/coupons'),
  SidebarEntry(label: 'Support', path: '/admin/support'),
  SidebarEntry(label: 'Returns', path: '/admin/returns'),
  SidebarEntry(label: 'Reports', path: '/admin/reports'),
  SidebarEntry(label: 'GST', path: '/admin/gst'),
  SidebarEntry(label: 'Inventory', path: '/admin/inventory-logs'),
  SidebarEntry(label: 'Audit Logs', path: '/admin/audit-logs'),
  SidebarEntry(label: 'Team', path: '/admin/team'),
  SidebarEntry(label: 'Permissions', path: '/admin/permissions'),
  SidebarEntry(label: 'Settings', path: '/admin/settings'),
];

/// Resolves the sidebar entries for a given [role].
///
/// - `super_admin`: Returns the fixed super admin entry set.
/// - `admin`: Returns brand-management entries minus [hiddenForBrandRoles].
/// - `manager`: Same as admin but without Team and Permissions (admin-only).
///
/// The [permissions] list is used for admin/manager to filter entries based
/// on granted permissions. Admins always have all permissions (`['*']`).
List<SidebarEntry> resolveSidebarEntries({
  required String role,
  List<String> permissions = const ['*'],
}) {
  if (role == 'super_admin') {
    return List.unmodifiable(superAdminEntries);
  }

  // For admin/manager: start with all brand entries, filter out hidden ones
  final entries = <SidebarEntry>[];

  for (final entry in adminBrandEntries) {
    // Skip entries that are hidden for brand roles (Req 11.2)
    if (hiddenForBrandRoles.contains(entry.label)) {
      continue;
    }

    // Team and Permissions are admin-only
    if (role == 'manager' &&
        (entry.label == 'Team' || entry.label == 'Permissions')) {
      continue;
    }

    entries.add(entry);
  }

  return entries;
}

/// Returns the set of entry labels for a given role.
Set<String> resolveEntryLabels({
  required String role,
  List<String> permissions = const ['*'],
}) {
  return resolveSidebarEntries(
    role: role,
    permissions: permissions,
  ).map((e) => e.label).toSet();
}
