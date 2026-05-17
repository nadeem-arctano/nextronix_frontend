import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../provider/auth_provider.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/dashboard/dashboard_screen.dart';
import '../../screens/products/products_screen.dart';
import '../../screens/products/add_product/add_product_screen.dart';
import '../../screens/products/edit_product_screen.dart';
import '../../screens/categories/categories_screen.dart';
import '../../screens/hsn/hsn_screen.dart';
import '../../screens/coupons/coupons_screen.dart';
import '../../screens/orders/orders_screen.dart';
import '../../screens/orders/order_detail_screen.dart';
import '../../screens/users/users_screen.dart';
import '../../screens/reports/reports_dashboard.dart';
import '../../screens/reports/daily_sales_screen.dart';
import '../../screens/reports/monthly_sales_screen.dart';
import '../../screens/reports/gst_report_screen.dart';
import '../../screens/reports/coupon_report_screen.dart';
import '../../screens/reports/top_customers_screen.dart';
import '../../screens/reports/best_products_screen.dart';
import '../../screens/settings/settings_hub_screen.dart';
import '../../screens/settings/sections/business_info_section.dart';
import '../../screens/settings/sections/contact_section.dart';
import '../../screens/settings/sections/address_section.dart';
import '../../screens/settings/sections/branding_section.dart';
import '../../screens/settings/sections/bank_section.dart';
import '../../screens/settings/sections/payment_section.dart';
import '../../screens/settings/sections/invoice_section.dart';
import '../../screens/settings/sections/social_section.dart';
import '../../screens/support/support_list_screen.dart';
import '../../screens/support/support_detail_screen.dart';
import '../../screens/support/contact_messages_screen.dart';
import '../../screens/returns/returns_list_screen.dart';
import '../../screens/returns/return_detail_screen.dart';
import '../../screens/gst/gst_dashboard_screen.dart';
import '../../screens/gst/gstr1_screen.dart';
import '../../screens/gst/gstr3b_screen.dart';
import '../../screens/gst/state_wise_gst_screen.dart';
import '../../screens/gst/invoice_breakup_screen.dart';
import '../../screens/gst/hsn_summary_screen.dart';
import '../../screens/gst/gst_export_screen.dart';
import '../../screens/gst/tax_settings_screen.dart';
import '../../screens/team/team_screen.dart';
import '../../screens/audit_logs/audit_logs_screen.dart';
import '../../screens/inventory_logs/inventory_logs_screen.dart';
import '../../screens/permissions/permissions_screen.dart';
import '../../screens/products/variants/variants_screen.dart';
import '../../screens/products/variations/variations_screen.dart';
import '../../widgets/admin_layout.dart';

/// Instant page transition — no slide, just a quick fade
CustomTransitionPage _fadePage(Widget child, GoRouterState state) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 150),
    reverseTransitionDuration: const Duration(milliseconds: 100),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

class AppRouter {
  /// Reads the actual browser URL at app start, ignoring `/` (which may be
  /// a transient default before the URL strategy reads the real location).
  /// Returns `/admin/dashboard` for an actual root visit so logged-in users
  /// land somewhere useful.
  static String _readInitialPath() {
    final p = html.window.location.pathname ?? '/';
    if (p.isEmpty || p == '/') return '/admin/dashboard';
    return p;
  }

  /// Builds the router instance bound to the given AuthProvider so route
  /// changes react to login/logout state.
  static GoRouter build(AuthProvider auth) {
    // Snapshot the actual browser URL once at construction time. On hard
    // reloads Flutter Web's engine briefly publishes the default `/` route
    // via the platform RouteInformationProvider before our URL strategy
    // reads the real location. Without an explicit initialLocation,
    // GoRouter would see `/` and bounce the user away from a deep-linked
    // URL like `/admin/products`. The phantom `/` guard inside `redirect`
    // also catches subsequent stale callbacks.
    final initialPath = _readInitialPath();

    return GoRouter(
      initialLocation: initialPath,
      // Listen ONLY to `auth.authRoutingTick`, not to AuthProvider itself.
      // This keeps incidental notifies (profile refresh, loading flags) from
      // forcing GoRouter to re-evaluate redirects — which can otherwise
      // briefly publish a stale `/` URI and bounce a deep-linked reload to
      // /admin/dashboard.
      refreshListenable: auth.authRoutingTick,
      redirect: (context, state) {
        // While bootstrapping (reading saved token) keep the current location.
        if (auth.isInitializing) return null;

        // Phantom `/` guard: Flutter Web's RouteInformationProvider can
        // publish `/` after GoRouter has already settled on the real URL.
        // If the browser still says we're on something else, redirect to
        // that real path instead of falling through to the `/` GoRoute.
        if (state.uri.toString() == '/') {
          final realPath = html.window.location.pathname ?? '/';
          if (realPath != '/') {
            // ignore: avoid_print
            print('[router.redirect]   → ignoring spurious / (real=$realPath)');
            return realPath;
          }
        }

        final loggingIn = state.matchedLocation == '/login';
        if (!auth.isAuthenticated) {
          return loggingIn ? null : '/login';
        }
        // Already authenticated → never let them sit on /login
        if (loggingIn) return '/admin/dashboard';
        return null;
      },
      routes: [
        // Bare root → dashboard (only triggered for literal `/` URLs)
        GoRoute(path: '/', redirect: (_, __) => '/admin/dashboard'),
        GoRoute(
          path: '/login',
          name: 'login',
          pageBuilder: (context, state) =>
              _fadePage(const LoginScreen(), state),
        ),
        // Standalone pages (no sidebar)
        GoRoute(
          path: '/admin/products/add',
          name: 'add-product',
          pageBuilder: (context, state) =>
              _fadePage(const AddProductScreen(), state),
        ),
        GoRoute(
          path: '/admin/products/edit/:id',
          name: 'edit-product',
          pageBuilder: (context, state) => _fadePage(
            EditProductScreen(
              productId: int.parse(state.pathParameters['id']!),
            ),
            state,
          ),
        ),
        ShellRoute(
          builder: (context, state, child) => AdminLayout(child: child),
          routes: [
            GoRoute(
              path: '/admin/dashboard',
              name: 'dashboard',
              pageBuilder: (context, state) =>
                  _fadePage(const DashboardScreen(), state),
            ),
            GoRoute(
              path: '/admin/products',
              name: 'products',
              pageBuilder: (context, state) =>
                  _fadePage(const ProductsScreen(), state),
            ),
            GoRoute(
              path: '/admin/categories',
              name: 'categories',
              pageBuilder: (context, state) =>
                  _fadePage(const CategoriesScreen(), state),
            ),
            GoRoute(
              path: '/admin/orders',
              name: 'orders',
              pageBuilder: (context, state) =>
                  _fadePage(const OrdersScreen(), state),
            ),
            GoRoute(
              path: '/admin/orders/:id',
              name: 'order-detail',
              pageBuilder: (context, state) => _fadePage(
                OrderDetailScreen(
                  orderId: int.parse(state.pathParameters['id']!),
                ),
                state,
              ),
            ),
            GoRoute(
              path: '/admin/users',
              name: 'users',
              pageBuilder: (context, state) =>
                  _fadePage(const UsersScreen(), state),
            ),
            GoRoute(
              path: '/admin/hsn-codes',
              name: 'hsn-codes',
              pageBuilder: (context, state) =>
                  _fadePage(const HsnScreen(), state),
            ),
            GoRoute(
              path: '/admin/coupons',
              name: 'coupons',
              pageBuilder: (context, state) =>
                  _fadePage(const CouponsScreen(), state),
            ),
            GoRoute(
              path: '/admin/reports',
              name: 'reports',
              pageBuilder: (context, state) =>
                  _fadePage(const ReportsDashboard(), state),
            ),
            GoRoute(
              path: '/admin/reports/daily-sales',
              name: 'daily-sales',
              pageBuilder: (context, state) =>
                  _fadePage(const DailySalesScreen(), state),
            ),
            GoRoute(
              path: '/admin/reports/monthly-sales',
              name: 'monthly-sales',
              pageBuilder: (context, state) =>
                  _fadePage(const MonthlySalesScreen(), state),
            ),
            GoRoute(
              path: '/admin/reports/gst-report',
              name: 'gst-report',
              pageBuilder: (context, state) =>
                  _fadePage(const GstReportScreen(), state),
            ),
            GoRoute(
              path: '/admin/reports/coupon-report',
              name: 'coupon-report',
              pageBuilder: (context, state) =>
                  _fadePage(const CouponReportScreen(), state),
            ),
            GoRoute(
              path: '/admin/reports/top-customers',
              name: 'top-customers',
              pageBuilder: (context, state) =>
                  _fadePage(const TopCustomersScreen(), state),
            ),
            GoRoute(
              path: '/admin/reports/best-products',
              name: 'best-products',
              pageBuilder: (context, state) =>
                  _fadePage(const BestProductsScreen(), state),
            ),
            GoRoute(
              path: '/admin/settings',
              name: 'settings-hub',
              pageBuilder: (context, state) =>
                  _fadePage(const SettingsHubScreen(), state),
            ),
            GoRoute(
              path: '/admin/settings/business-info',
              name: 'settings-business-info',
              pageBuilder: (context, state) =>
                  _fadePage(const BusinessInfoSectionScreen(), state),
            ),
            GoRoute(
              path: '/admin/settings/contact',
              name: 'settings-contact',
              pageBuilder: (context, state) =>
                  _fadePage(const ContactSectionScreen(), state),
            ),
            GoRoute(
              path: '/admin/settings/address',
              name: 'settings-address',
              pageBuilder: (context, state) =>
                  _fadePage(const AddressSectionScreen(), state),
            ),
            GoRoute(
              path: '/admin/settings/branding',
              name: 'settings-branding',
              pageBuilder: (context, state) =>
                  _fadePage(const BrandingSectionScreen(), state),
            ),
            GoRoute(
              path: '/admin/settings/bank',
              name: 'settings-bank',
              pageBuilder: (context, state) =>
                  _fadePage(const BankSectionScreen(), state),
            ),
            GoRoute(
              path: '/admin/settings/payment',
              name: 'settings-payment',
              pageBuilder: (context, state) =>
                  _fadePage(const PaymentSectionScreen(), state),
            ),
            GoRoute(
              path: '/admin/settings/invoice',
              name: 'settings-invoice',
              pageBuilder: (context, state) =>
                  _fadePage(const InvoiceSectionScreen(), state),
            ),
            GoRoute(
              path: '/admin/settings/social',
              name: 'settings-social',
              pageBuilder: (context, state) =>
                  _fadePage(const SocialSectionScreen(), state),
            ),
            // ─── Support ───────────────────────────────────────────────────────
            GoRoute(
              path: '/admin/support',
              name: 'support-list',
              pageBuilder: (context, state) =>
                  _fadePage(const SupportListScreen(), state),
            ),
            GoRoute(
              path: '/admin/support/:id',
              name: 'support-detail',
              pageBuilder: (context, state) => _fadePage(
                SupportDetailScreen(
                  ticketId: int.parse(state.pathParameters['id']!),
                ),
                state,
              ),
            ),
            GoRoute(
              path: '/admin/contact-messages',
              name: 'contact-messages',
              pageBuilder: (context, state) =>
                  _fadePage(const ContactMessagesScreen(), state),
            ),
            // ─── Returns ───────────────────────────────────────────────────────
            GoRoute(
              path: '/admin/returns',
              name: 'returns-list',
              pageBuilder: (context, state) =>
                  _fadePage(const ReturnsListScreen(), state),
            ),
            GoRoute(
              path: '/admin/returns/:id',
              name: 'return-detail',
              pageBuilder: (context, state) => _fadePage(
                ReturnDetailScreen(
                  returnId: int.parse(state.pathParameters['id']!),
                ),
                state,
              ),
            ),
            // ─── GST Management ────────────────────────────────────────────────
            GoRoute(
              path: '/admin/gst',
              name: 'gst-dashboard',
              pageBuilder: (context, state) =>
                  _fadePage(const GstDashboardScreen(), state),
            ),
            GoRoute(
              path: '/admin/gst/reports',
              name: 'gst-reports',
              pageBuilder: (context, state) =>
                  _fadePage(const GstReportScreen(), state),
            ),
            GoRoute(
              path: '/admin/gst/gstr1',
              name: 'gst-gstr1',
              pageBuilder: (context, state) =>
                  _fadePage(const Gstr1Screen(), state),
            ),
            GoRoute(
              path: '/admin/gst/gstr3b',
              name: 'gst-gstr3b',
              pageBuilder: (context, state) =>
                  _fadePage(const Gstr3bScreen(), state),
            ),
            GoRoute(
              path: '/admin/gst/state-wise',
              name: 'gst-state-wise',
              pageBuilder: (context, state) =>
                  _fadePage(const StateWiseGstScreen(), state),
            ),
            GoRoute(
              path: '/admin/gst/invoice-breakup',
              name: 'gst-invoice-breakup',
              pageBuilder: (context, state) =>
                  _fadePage(const InvoiceBreakupScreen(), state),
            ),
            GoRoute(
              path: '/admin/gst/hsn-summary',
              name: 'gst-hsn-summary',
              pageBuilder: (context, state) =>
                  _fadePage(const HsnSummaryScreen(), state),
            ),
            GoRoute(
              path: '/admin/gst/export',
              name: 'gst-export',
              pageBuilder: (context, state) =>
                  _fadePage(const GstExportScreen(), state),
            ),
            GoRoute(
              path: '/admin/gst/settings',
              name: 'gst-settings',
              pageBuilder: (context, state) =>
                  _fadePage(const TaxSettingsScreen(), state),
            ),
            GoRoute(
              path: '/admin/team',
              name: 'team',
              pageBuilder: (context, state) =>
                  _fadePage(const TeamScreen(), state),
            ),
            GoRoute(
              path: '/admin/permissions',
              name: 'permissions',
              pageBuilder: (context, state) =>
                  _fadePage(const PermissionsScreen(), state),
            ),
            GoRoute(
              path: '/admin/audit-logs',
              name: 'audit-logs',
              pageBuilder: (context, state) =>
                  _fadePage(const AuditLogsScreen(), state),
            ),
            GoRoute(
              path: '/admin/inventory-logs',
              name: 'inventory-logs',
              pageBuilder: (context, state) =>
                  _fadePage(const InventoryLogsScreen(), state),
            ),
            GoRoute(
              path: '/admin/products/:id/variants',
              name: 'product-variants',
              pageBuilder: (context, state) => _fadePage(
                VariantsScreen(
                  productId: int.parse(state.pathParameters['id']!),
                ),
                state,
              ),
            ),
            GoRoute(
              path: '/admin/products/:id/variations',
              name: 'product-variations',
              pageBuilder: (context, state) => _fadePage(
                VariationsScreen(
                  productId: int.parse(state.pathParameters['id']!),
                ),
                state,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
