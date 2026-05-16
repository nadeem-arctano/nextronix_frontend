import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/theme_provider.dart';
import '../static_values/static_values.dart';

class AdminLayout extends StatefulWidget {
  final Widget child;
  const AdminLayout({super.key, required this.child});

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout>
    with SingleTickerProviderStateMixin {
  bool _isSidebarCollapsed = false;
  int _hoveredIndex = -1;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 768;
    final isTablet = width >= 768 && width < 1024;
    final theme = ShadTheme.of(context);

    if (isMobile) {
      return Scaffold(
        drawer: _buildDrawer(context),
        body: Column(
          children: [
            _buildMobileHeader(context, theme),
            Expanded(child: widget.child),
          ],
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          _buildSidebar(context, collapsed: isTablet || _isSidebarCollapsed),
          Expanded(
            child: Container(
              color: theme.colorScheme.background,
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileHeader(BuildContext context, ShadThemeData theme) {
    final themeProvider = context.watch<ThemeProvider>();
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.sidebarBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Builder(
            builder: (ctx) => GestureDetector(
              onTap: () => Scaffold.of(ctx).openDrawer(),
              child: const Icon(
                LucideIcons.menu,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          _buildLogo(false),
          const Spacer(),
          GestureDetector(
            onTap: () => themeProvider.toggleTheme(),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) =>
                  RotationTransition(turns: anim, child: child),
              child: Icon(
                themeProvider.isDark ? LucideIcons.sun : LucideIcons.moon,
                key: ValueKey(themeProvider.isDark),
                color: Colors.white70,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.sidebarBg,
      child: _buildSidebarContent(context, collapsed: false),
    );
  }

  Widget _buildSidebar(BuildContext context, {required bool collapsed}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: collapsed ? 72 : 240,
      decoration: BoxDecoration(
        color: AppTheme.sidebarBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: _buildSidebarContent(context, collapsed: collapsed),
    );
  }

  Widget _buildSidebarContent(BuildContext context, {required bool collapsed}) {
    final currentPath = GoRouterState.of(context).uri.toString();
    final themeProvider = context.watch<ThemeProvider>();

    return Column(
      children: [
        // Logo area
        Container(
          height: 64,
          padding: EdgeInsets.symmetric(horizontal: collapsed ? 0 : 20),
          child: Row(
            mainAxisAlignment: collapsed
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              _buildLogo(collapsed),
              if (!collapsed) ...[
                const Spacer(),
                GestureDetector(
                  onTap: () => setState(
                    () => _isSidebarCollapsed = !_isSidebarCollapsed,
                  ),
                  child: AnimatedRotation(
                    turns: _isSidebarCollapsed ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: const Icon(
                      LucideIcons.chevronsLeft,
                      color: Colors.white24,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        // Divider
        Padding(
          padding: EdgeInsets.symmetric(horizontal: collapsed ? 12 : 20),
          child: Divider(
            color: Colors.white.withValues(alpha: 0.06),
            height: 1,
          ),
        ),

        const SizedBox(height: 16),

        // Navigation
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: collapsed ? 8 : 12),
            child: Column(
              children: [
                if (!collapsed)
                  Padding(
                    padding: const EdgeInsets.only(left: 12, bottom: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'MENU',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.3),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                _buildNavItem(
                  context,
                  0,
                  LucideIcons.layoutDashboard,
                  'Dashboard',
                  '/admin/dashboard',
                  currentPath,
                  collapsed,
                ),
                _buildNavItem(
                  context,
                  1,
                  LucideIcons.package,
                  'Products',
                  '/admin/products',
                  currentPath,
                  collapsed,
                ),
                _buildNavItem(
                  context,
                  2,
                  LucideIcons.shoppingBag,
                  'Orders',
                  '/admin/orders',
                  currentPath,
                  collapsed,
                ),
                _buildNavItem(
                  context,
                  3,
                  LucideIcons.users,
                  'Users',
                  '/admin/users',
                  currentPath,
                  collapsed,
                ),
                _buildNavItem(
                  context,
                  4,
                  LucideIcons.layers,
                  'Categories',
                  '/admin/categories',
                  currentPath,
                  collapsed,
                ),
                _buildNavItem(
                  context,
                  5,
                  LucideIcons.fileText,
                  'HSN Codes',
                  '/admin/hsn-codes',
                  currentPath,
                  collapsed,
                ),
                _buildNavItem(
                  context,
                  6,
                  LucideIcons.ticket,
                  'Coupons',
                  '/admin/coupons',
                  currentPath,
                  collapsed,
                ),
              ],
            ),
          ),
        ),

        // Theme toggle
        Padding(
          padding: EdgeInsets.symmetric(horizontal: collapsed ? 12 : 16),
          child: GestureDetector(
            onTap: () => themeProvider.toggleTheme(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(
                horizontal: collapsed ? 0 : 14,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: collapsed
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, anim) =>
                        RotationTransition(turns: anim, child: child),
                    child: Icon(
                      themeProvider.isDark ? LucideIcons.sun : LucideIcons.moon,
                      key: ValueKey(themeProvider.isDark),
                      color: Colors.white54,
                      size: 16,
                    ),
                  ),
                  if (!collapsed) ...[
                    const SizedBox(width: 10),
                    Text(
                      themeProvider.isDark ? 'Light Mode' : 'Dark Mode',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: collapsed ? 12 : 20),
          child: Divider(
            color: Colors.white.withValues(alpha: 0.06),
            height: 1,
          ),
        ),

        // Profile
        _buildProfileSection(collapsed),
      ],
    );
  }

  Widget _buildLogo(bool collapsed) {
    if (collapsed) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.brand, AppTheme.brandLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            'N',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.brand, AppTheme.brandLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Text(
              'N',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'Nextronix',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileSection(bool collapsed) {
    if (collapsed) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.brand.withValues(alpha: 0.8),
                    AppTheme.brandLight.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'A',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _handleLogout,
              child: const Icon(
                LucideIcons.logOut,
                color: Colors.white30,
                size: 16,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.brand, AppTheme.brandLight],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'A',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Admin',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'admin@nextronix.com',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _handleLogout,
            child: const Icon(
              LucideIcons.logOut,
              color: Colors.white30,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  void _handleLogout() {
    globalAccessToken = null;
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    IconData icon,
    String label,
    String path,
    String currentPath,
    bool collapsed,
  ) {
    final isActive = currentPath.startsWith(path);
    final isHovered = _hoveredIndex == index;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hoveredIndex = index),
        onExit: (_) => setState(() => _hoveredIndex = -1),
        child: GestureDetector(
          onTap: () {
            context.go(path);
            if (MediaQuery.of(context).size.width < 768) {
              Navigator.pop(context);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: EdgeInsets.symmetric(
              horizontal: collapsed ? 0 : 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: isActive
                  ? AppTheme.brand.withValues(alpha: 0.15)
                  : isHovered
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: isActive
                  ? Border.all(
                      color: AppTheme.brand.withValues(alpha: 0.2),
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              mainAxisAlignment: collapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  color: isActive
                      ? AppTheme.brand
                      : isHovered
                      ? Colors.white70
                      : Colors.white38,
                  size: 18,
                ),
                if (!collapsed) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: isActive
                            ? Colors.white
                            : isHovered
                            ? Colors.white70
                            : Colors.white54,
                        fontWeight: isActive
                            ? FontWeight.w500
                            : FontWeight.w400,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  if (isActive)
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: AppTheme.brand,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
