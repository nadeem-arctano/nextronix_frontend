import 'package:flutter_test/flutter_test.dart';
import 'package:nextronix_frontend/core/router/redirect_resolver.dart';

/// **Validates: Requirements 2.2, 11.4**
///
/// Property 3: Role-based redirect resolver
///
/// For any user role in {super_admin, admin, manager, customer} and any URL the
/// user attempts to navigate to that does not match their role's allowed prefix,
/// the router's redirect function returns the role's default dashboard path.
void main() {
  group('Property 3: Role-based redirect resolver', () {
    // All recognized roles
    const roles = ['super_admin', 'admin', 'manager', 'customer'];

    // Sample super-admin paths
    const superAdminPaths = [
      '/super-admin/dashboard',
      '/super-admin/admins',
      '/super-admin/admins/42',
      '/super-admin/masters/categories',
      '/super-admin/masters/hsn',
      '/super-admin/masters/colors',
      '/super-admin/masters/materials',
      '/super-admin/settings',
    ];

    // Sample admin paths
    const adminPaths = [
      '/admin/dashboard',
      '/admin/products',
      '/admin/orders',
      '/admin/categories',
      '/admin/settings',
      '/admin/team',
      '/admin/reports',
      '/admin/products/add',
    ];

    group('defaultDashboardForRole', () {
      test('super_admin → /super-admin/dashboard', () {
        expect(
          defaultDashboardForRole('super_admin'),
          '/super-admin/dashboard',
        );
      });

      test('admin → /admin/dashboard', () {
        expect(defaultDashboardForRole('admin'), '/admin/dashboard');
      });

      test('manager → /admin/dashboard', () {
        expect(defaultDashboardForRole('manager'), '/admin/dashboard');
      });

      test('customer → /storefront', () {
        expect(defaultDashboardForRole('customer'), '/storefront');
      });

      test('null → /login', () {
        expect(defaultDashboardForRole(null), '/login');
      });

      test('unknown role → /login', () {
        expect(defaultDashboardForRole('unknown'), '/login');
      });
    });

    group('super_admin redirect to /super-admin/dashboard', () {
      test(
        'when role=super_admin, redirect goes to /super-admin/dashboard on login',
        () {
          final result = resolveRedirect(
            role: 'super_admin',
            requestedPath: '/login',
            isAuthenticated: true,
          );
          expect(result, '/super-admin/dashboard');
        },
      );

      test('super_admin on /super-admin/* paths → no redirect', () {
        for (final path in superAdminPaths) {
          final result = resolveRedirect(
            role: 'super_admin',
            requestedPath: path,
            isAuthenticated: true,
          );
          expect(result, isNull, reason: 'super_admin should stay on $path');
        }
      });

      test(
        'super_admin requesting /admin/* → redirected to /super-admin/dashboard',
        () {
          for (final path in adminPaths) {
            final result = resolveRedirect(
              role: 'super_admin',
              requestedPath: path,
              isAuthenticated: true,
            );
            expect(
              result,
              '/super-admin/dashboard',
              reason: 'super_admin should be redirected away from $path',
            );
          }
        },
      );
    });

    group('admin/manager redirect to /admin/dashboard', () {
      for (final role in ['admin', 'manager']) {
        test(
          'when role=$role, redirect from /login goes to /admin/dashboard',
          () {
            final result = resolveRedirect(
              role: role,
              requestedPath: '/login',
              isAuthenticated: true,
            );
            expect(result, '/admin/dashboard');
          },
        );

        test('$role on /admin/* paths → no redirect', () {
          for (final path in adminPaths) {
            final result = resolveRedirect(
              role: role,
              requestedPath: path,
              isAuthenticated: true,
            );
            expect(result, isNull, reason: '$role should stay on $path');
          }
        });

        test(
          '$role requesting /super-admin/* → redirected to /admin/dashboard',
          () {
            for (final path in superAdminPaths) {
              final result = resolveRedirect(
                role: role,
                requestedPath: path,
                isAuthenticated: true,
              );
              expect(
                result,
                '/admin/dashboard',
                reason: '$role should be redirected away from $path',
              );
            }
          },
        );
      }
    });

    group('customer redirect to /storefront', () {
      test('when role=customer, redirect from /login goes to /storefront', () {
        final result = resolveRedirect(
          role: 'customer',
          requestedPath: '/login',
          isAuthenticated: true,
        );
        expect(result, '/storefront');
      });

      test(
        'customer requesting /super-admin/* → redirected to /storefront',
        () {
          for (final path in superAdminPaths) {
            final result = resolveRedirect(
              role: 'customer',
              requestedPath: path,
              isAuthenticated: true,
            );
            expect(
              result,
              '/storefront',
              reason: 'customer should be redirected away from $path',
            );
          }
        },
      );
    });

    group('unauthenticated user redirects to /login', () {
      test('unauthenticated on /login → no redirect', () {
        final result = resolveRedirect(
          role: null,
          requestedPath: '/login',
          isAuthenticated: false,
        );
        expect(result, isNull);
      });

      test('unauthenticated on any other path → /login', () {
        const paths = [
          '/admin/dashboard',
          '/super-admin/dashboard',
          '/storefront',
          '/',
          '/admin/products',
        ];
        for (final path in paths) {
          final result = resolveRedirect(
            role: null,
            requestedPath: path,
            isAuthenticated: false,
          );
          expect(
            result,
            '/login',
            reason: 'unauthenticated user on $path should go to /login',
          );
        }
      });
    });

    group('property: cross-role access is always redirected (exhaustive)', () {
      // For every role, generate various paths and verify the redirect invariant
      for (final role in roles) {
        test('role=$role: all cross-role paths are redirected correctly', () {
          final expectedDefault = defaultDashboardForRole(role);

          // Generate test paths
          final allPaths = [...superAdminPaths, ...adminPaths];

          for (final path in allPaths) {
            final result = resolveRedirect(
              role: role,
              requestedPath: path,
              isAuthenticated: true,
            );

            final isSuperPath = path.startsWith('/super-admin');
            final isAdminPath = path.startsWith('/admin');

            if (isSuperPath && role != 'super_admin') {
              // Non-super_admin on super path → redirect to their dashboard
              expect(
                result,
                expectedDefault,
                reason: '$role on $path should redirect to $expectedDefault',
              );
            } else if (isAdminPath && role == 'super_admin') {
              // Super_admin on admin path → redirect to super dashboard
              expect(
                result,
                '/super-admin/dashboard',
                reason:
                    'super_admin on $path should redirect to /super-admin/dashboard',
              );
            } else {
              // Allowed path → no redirect
              expect(
                result,
                isNull,
                reason: '$role should be allowed on $path',
              );
            }
          }
        });
      }
    });
  });
}
