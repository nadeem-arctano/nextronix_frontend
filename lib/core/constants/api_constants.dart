class ApiConstants {
  static const String baseUrl = 'http://localhost:5000/api';
  static const String uploadsUrl = 'http://localhost:5000/uploads';

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String profile = '/auth/me';

  // Products
  static const String products = '/products';
  static const String productSearch = '/products/search';
  static const String productFeatured = '/products/featured';
  static const String productTrending = '/products/trending';
  static const String productLowStock = '/products/low-stock';
  static const String productBulkDelete = '/products/bulk/delete';
  static const String productBulkStatus = '/products/bulk/status';

  // Categories
  static const String categories = '/categories';

  // Orders
  static const String orders = '/orders';
  static const String orderStats = '/orders/stats';

  // Dashboard
  static const String dashboardStats = '/dashboard/stats';
  static const String dashboardRevenue = '/dashboard/revenue';
  static const String dashboardRecentOrders = '/dashboard/recent-orders';
  static const String dashboardTopProducts = '/dashboard/top-products';
  static const String dashboardLowStock = '/dashboard/low-stock';
  static const String dashboardOrderChart = '/dashboard/order-chart';
  static const String dashboardCategoryStats = '/dashboard/category-stats';

  // Coupons
  static const String coupons = '/coupons';

  static String getImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return '$uploadsUrl/$path';
  }
}
