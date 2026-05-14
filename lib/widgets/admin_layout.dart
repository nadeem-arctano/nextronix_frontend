import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';
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
        body: Row(
          children: [
            // Mobile: no sidebar, use drawer
            Expanded(
              child: Column(
                children: [
                  // Small mobile header with menu button
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: const BoxDecoration(
                      color: AppTheme.sidebarColor,
                    ),
                    child: Row(
                      children: [
                        Builder(
                          builder: (ctx) => IconButton(
                            icon: const Icon(
                              Icons.menu,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: () => Scaffold.of(ctx).openDrawer(),
                          ),
                        ),
                        const Text(
                          'Nextronix',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: widget.child),
                ],
              ),
            ),
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
                const Icon(Icons.bolt, color: AppTheme.primaryColor, size: 22),
              if (!collapsed)
                GestureDetector(
                  onTap: () => setState(
                    () => _isSidebarCollapsed = !_isSidebarCollapsed,
                  ),
                  child: const Icon(
                    Icons.chevron_left,
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
                Icons.dashboard_outlined,
                'Dashboard',
                '/dashboard',
                currentPath,
                collapsed,
              ),
              _buildNavItem(
                context,
                Icons.inventory_2_outlined,
                'Products',
                '/products',
                currentPath,
                collapsed,
              ),
              _buildNavItem(
                context,
                Icons.category_outlined,
                'Categories',
                '/categories',
                currentPath,
                collapsed,
              ),
              _buildNavItem(
                context,
                Icons.shopping_bag_outlined,
                'Orders',
                '/orders',
                currentPath,
                collapsed,
              ),
              _buildNavItem(
                context,
                Icons.people_outline,
                'Users',
                '/users',
                currentPath,
                collapsed,
              ),
            ],
          ),
        ),

        // Profile + Logout at bottom
        const Divider(color: Colors.white10, height: 1),
        _buildProfileSection(collapsed),
      ],
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
              backgroundColor: AppTheme.primaryColor,
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
              child: const Icon(Icons.logout, color: Colors.white38, size: 18),
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
                backgroundColor: AppTheme.primaryColor,
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
            child: OutlinedButton.icon(
              onPressed: _handleLogout,
              icon: const Icon(Icons.logout, size: 14),
              label: const Text('Logout'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white60,
                side: const BorderSide(color: Colors.white12),
                padding: const EdgeInsets.symmetric(vertical: 8),
                textStyle: const TextStyle(fontSize: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleLogout() {
    globalAccessToken = null;
    // Navigate to login or handle logout
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
                        color: AppTheme.primaryColor,
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
