import 'package:flutter_test/flutter_test.dart';
import 'package:nextronix_frontend/utils/sidebar_entry_resolver.dart';

/// **Validates: Requirements 11.1, 11.2, 11.3**
///
/// Property 4: Sidebar entry resolver
///
/// For any user role in {super_admin, admin, manager}, the set of sidebar
/// entries computed by the resolver equals the canonical entry set defined
/// in the spec table for that role:
/// - super_admin sees Dashboard/Admins/Categories/HSN/Colors/Materials/Settings
/// - admin and manager see brand-management entries with Categories, HSN,
///   Colors, Materials, and Admins absent.
void main() {
  group('Property 4: Sidebar entry resolver', () {
    // --- Requirement 11.1 ---
    // WHEN the Sidebar renders for a user with role='super_admin', THE Frontend
    // SHALL show: Dashboard, Admins, Categories, HSN, Colors, Materials, Settings.

    group('super_admin sidebar entries (Req 11.1)', () {
      test(
        'super_admin sees exactly the canonical 7 entries in correct order',
        () {
          final entries = resolveSidebarEntries(role: 'super_admin');
          final labels = entries.map((e) => e.label).toList();

          expect(labels, [
            'Dashboard',
            'Admins',
            'Categories',
            'HSN',
            'Colors',
            'Materials',
            'Settings',
          ]);
        },
      );

      test('super_admin entries use /super-admin/* paths', () {
        final entries = resolveSidebarEntries(role: 'super_admin');
        for (final entry in entries) {
          expect(
            entry.path.startsWith('/super-admin'),
            isTrue,
            reason: '${entry.label} should use /super-admin path prefix',
          );
        }
      });

      test('super_admin entry count is exactly 7 for all permission sets', () {
        // Property: regardless of permissions argument, super_admin always
        // gets the same fixed set.
        final permSets = <List<String>>[
          ['*'],
          [],
          ['canViewProducts', 'canViewOrders'],
          ['canViewCategories', 'canViewHsn'],
        ];

        for (final perms in permSets) {
          final entries = resolveSidebarEntries(
            role: 'super_admin',
            permissions: perms,
          );
          expect(
            entries.length,
            7,
            reason:
                'super_admin should always have 7 entries regardless of permissions=$perms',
          );
        }
      });
    });

    // --- Requirement 11.2 ---
    // WHEN the Sidebar renders for admin or manager, THE Frontend SHALL HIDE:
    // Categories, HSN, Colors, Materials, and Admins entries.

    group('admin/manager hidden entries (Req 11.2)', () {
      const hiddenLabels = [
        'Categories',
        'HSN Codes',
        'Colors',
        'Materials',
        'Admins',
      ];

      for (final role in ['admin', 'manager']) {
        test(
          '$role does NOT see Categories, HSN Codes, Colors, Materials, or Admins',
          () {
            final labels = resolveEntryLabels(role: role);
            for (final hidden in hiddenLabels) {
              expect(
                labels.contains(hidden),
                isFalse,
                reason: '$role should not see "$hidden" in sidebar',
              );
            }
          },
        );
      }

      test('property: no brand role ever sees hidden entries', () {
        // Exhaustive check across both brand roles
        for (final role in ['admin', 'manager']) {
          final entries = resolveSidebarEntries(role: role);
          final labels = entries.map((e) => e.label).toSet();

          // None of the hidden entries should appear
          final intersection = labels.intersection(hiddenForBrandRoles);
          expect(
            intersection,
            isEmpty,
            reason:
                '$role should have no hidden entries but found: $intersection',
          );
        }
      });
    });

    // --- Requirement 11.3 ---
    // WHEN the Sidebar renders for admin, THE Frontend SHALL preserve all
    // existing brand-management entries (Products, Orders, Customers, Managers,
    // Reports, Settings, etc.) other than those listed in criterion 2.

    group('admin preserves brand-management entries (Req 11.3)', () {
      test('admin sees Products, Orders, Customers, Reports, Settings', () {
        final labels = resolveEntryLabels(role: 'admin');

        const expectedBrandEntries = [
          'Dashboard',
          'Products',
          'Orders',
          'Customers',
          'Reports',
          'Settings',
        ];

        for (final entry in expectedBrandEntries) {
          expect(
            labels.contains(entry),
            isTrue,
            reason: 'admin should see "$entry" in sidebar',
          );
        }
      });

      test('admin sees Team and Permissions (admin-only entries)', () {
        final labels = resolveEntryLabels(role: 'admin');
        expect(labels.contains('Team'), isTrue);
        expect(labels.contains('Permissions'), isTrue);
      });

      test('manager does NOT see Team and Permissions', () {
        final labels = resolveEntryLabels(role: 'manager');
        expect(labels.contains('Team'), isFalse);
        expect(labels.contains('Permissions'), isFalse);
      });

      test('admin entry paths all use /admin/* prefix', () {
        final entries = resolveSidebarEntries(role: 'admin');
        for (final entry in entries) {
          expect(
            entry.path.startsWith('/admin'),
            isTrue,
            reason: '${entry.label} should use /admin path prefix',
          );
        }
      });
    });

    // --- Cross-role invariant property ---
    group('Cross-role invariants', () {
      test('every role gets at least Dashboard and Settings', () {
        for (final role in ['super_admin', 'admin', 'manager']) {
          final labels = resolveEntryLabels(role: role);
          expect(
            labels.contains('Dashboard'),
            isTrue,
            reason: '$role must have Dashboard',
          );
          expect(
            labels.contains('Settings'),
            isTrue,
            reason: '$role must have Settings',
          );
        }
      });

      test(
        'super_admin and admin/manager entry sets are disjoint by path prefix',
        () {
          final superPaths = resolveSidebarEntries(
            role: 'super_admin',
          ).map((e) => e.path).toSet();
          final adminPaths = resolveSidebarEntries(
            role: 'admin',
          ).map((e) => e.path).toSet();

          // No path should appear in both sets
          expect(superPaths.intersection(adminPaths), isEmpty);
        },
      );

      test('admin entries are a superset of manager entries', () {
        final adminLabels = resolveEntryLabels(role: 'admin');
        final managerLabels = resolveEntryLabels(role: 'manager');

        // Every manager entry should also be in admin
        for (final label in managerLabels) {
          expect(
            adminLabels.contains(label),
            isTrue,
            reason:
                'admin should have all entries manager has, including "$label"',
          );
        }
      });
    });
  });
}
