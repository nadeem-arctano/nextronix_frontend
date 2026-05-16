import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../screens/dashboard/dashboard_screen.dart';
import '../../screens/products/products_screen.dart';
import '../../screens/products/add_product_screen.dart';
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
import '../../screens/settings/business_settings_screen.dart';
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
  static final GoRouter router = GoRouter(
    initialLocation: '/admin/dashboard',
    routes: [
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
          EditProductScreen(productId: int.parse(state.pathParameters['id']!)),
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
            path: '/admin/settings/business',
            name: 'business-settings',
            pageBuilder: (context, state) =>
                _fadePage(const BusinessSettingsScreen(), state),
          ),
        ],
      ),
    ],
  );
}
