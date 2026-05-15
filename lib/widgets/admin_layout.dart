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

class _AdminLayoutState extends State<AdminLayout> {
  bool _isSidebarCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 768;
    final isTablet = width >= 768 && width < 1024;

    if (isMobile) {
      return Scaffold(
        drawer: _buildDrawer(context),
        body: Column(
          children: [
            _buildMobileHeader(context),
            Expanded(child: widget.child),
          ],
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          _buildSidebar(context, collapsed: isTablet || _isSidebarCollapsed),
          Expanded(child: widget.child),
        ],
      ),
    );
  }

  Widget _buildMobileHeader(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(color: AppTheme.sidebarColor),
      child: Row(
        children: [
          Builder(
            builder: (ctx) => ShadIconButton.ghost(
              icon: const Icon(LucideIcons.menu, color: Colors.white, size: 20),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Nextronix',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          _buildThemeToggle(compact: true),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.sidebarColor,
      child: _buildSidebarContent(context, collapsed: false),
    );
  }

  Widget _buildSidebar(BuildContext context, {required bool collapsed}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: collapsed ? 64 : 220,
      decoration: const BoxDecoration(color: AppTheme.sidebarColor),
      child: _buildSidebarContent(context, collapsed: collapsed),
    );
  }

  Widget _buildSidebarContent(BuildContext context, {required bool collapsed}) {
    final currentPath = GoRouterState.of(context).uri.toString();

    return Column(
      children: [
        // Logo + collapse toggle
        Container(
          height: 56,
          padding: EdgeInsets.symmetric(horizontal: collapsed ? 0 : 16),
          child: Row(
            mainAxisAlignment: collapsed
                ? MainAxisAlignment.center
                : MainAxisAlignment.spaceBetween,
            children: [
              if (!collapsed)
                const Text(
                  'Nextronix',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
              if (collapsed)
                const Icon(LucideIcons.zap, color: Color(0xFF2563EB), size: 22),
              if (!collapsed)
                GestureDetector(
                  onTap: () => setState(
                    () => _isSidebarCollapsed = !_isSidebarCollapsed,
                  ),
                  child: const Icon(
                    LucideIcons.panelLeftClose,
                    color: Colors.white38,
                    size: 18,
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Nav items
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            children: [
              _buildNavItem(
                context,
                LucideIcons.layoutDashboard,
                'Dashboard',
                '/dashboard',
                currentPath,
                collapsed,
              ),
              _buildNavItem(
                context,
                LucideIcons.package,
                'Products',
                '/products',
                currentPath,
                collapsed,
              ),
              _buildNavItem(
                context,
                LucideIcons.layers,
                'Categories',
                '/categories',
                currentPath,
                collapsed,
              ),
              _buildNavItem(
                context,
                LucideIcons.shoppingBag,
                'Orders',
                '/orders',
                currentPath,
                collapsed,
              ),
              _buildNavItem(
                context,
                LucideIcons.users,
                'Users',
                '/users',
                currentPath,
                collapsed,
              ),
            ],
          ),
        ),

        // Theme toggle
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: collapsed ? 8 : 12,
            vertical: 8,
          ),
          child: _buildThemeToggle(compact: collapsed),
        ),

        // Profile + Logout at bottom
        const Divider(color: Colors.white10, height: 1),
        _buildProfileSection(collapsed),
      ],
    );
  }

  Widget _buildThemeToggle({bool compact = false}) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDark;

    if (compact) {
      return GestureDetector(
        onTap: () => themeProvider.toggleTheme(),
        child: Icon(
          isDark ? LucideIcons.sun : LucideIcons.moon,
          color: Colors.white54,
          size: 18,
        ),
      );
    }

    return GestureDetector(
      onTap: () => themeProvider.toggleTheme(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.sidebarActiveColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isDark ? LucideIcons.sun : LucideIcons.moon,
              color: Colors.white54,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              isDark ? 'Light Mode' : 'Dark Mode',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(bool collapsed) {
    if (collapsed) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 14,
              backgroundColor: Color(0xFF2563EB),
              child: Text(
                'A',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _handleLogout,
              child: const Icon(
                LucideIcons.logOut,
                color: Colors.white38,
                size: 18,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFF2563EB),
                child: Text(
                  'A',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ShadButton.outline(
              leading: const Icon(LucideIcons.logOut, size: 14),
              onPressed: _handleLogout,
              foregroundColor: Colors.white60,
              size: ShadButtonSize.sm,
              child: const Text('Logout'),
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
    IconData icon,
    String label,
    String path,
    String currentPath,
    bool collapsed,
  ) {
    final isActive = currentPath.startsWith(path);

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: isActive ? AppTheme.sidebarActiveColor : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          hoverColor: AppTheme.sidebarActiveColor,
          onTap: () {
            context.go(path);
            if (MediaQuery.of(context).size.width < 768) {
              Navigator.pop(context);
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: collapsed ? 0 : 12,
              vertical: 10,
            ),
            child: Row(
              mainAxisAlignment: collapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  color: isActive ? Colors.white : Colors.white54,
                  size: 19,
                ),
                if (!collapsed) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.white54,
                        fontWeight: isActive
                            ? FontWeight.w600
                            : FontWeight.w400,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  if (isActive)
                    Container(
                      width: 3,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        borderRadius: BorderRadius.circular(2),
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
