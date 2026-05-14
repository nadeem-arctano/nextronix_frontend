import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';

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
        appBar: _buildAppBar(context, isMobile: true),
        drawer: _buildDrawer(context),
        body: widget.child,
      );
    }

    return Scaffold(
      body: Row(
        children: [
          _buildSidebar(context, collapsed: isTablet || _isSidebarCollapsed),
          Expanded(
            child: Column(
              children: [
                _buildAppBar(context, isMobile: false),
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context, {
    required bool isMobile,
  }) {
    return AppBar(
      automaticallyImplyLeading: isMobile,
      title: isMobile ? const Text('Nextronix') : null,
      actions: [
        if (!isMobile)
          IconButton(
            icon: Icon(
              _isSidebarCollapsed ? Icons.menu_open : Icons.menu,
              size: 20,
            ),
            onPressed: () =>
                setState(() => _isSidebarCollapsed = !_isSidebarCollapsed),
          ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined, size: 20),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: AppTheme.primaryColor,
            shape: BoxShape.circle,
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
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(child: _buildSidebarContent(context, collapsed: false));
  }

  Widget _buildSidebar(BuildContext context, {required bool collapsed}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: collapsed ? 64 : 240,
      decoration: const BoxDecoration(color: AppTheme.sidebarColor),
      child: _buildSidebarContent(context, collapsed: collapsed),
    );
  }

  Widget _buildSidebarContent(BuildContext context, {required bool collapsed}) {
    final currentPath = GoRouterState.of(context).uri.toString();

    return Column(
      children: [
        // Logo
        Container(
          height: 56,
          padding: EdgeInsets.symmetric(horizontal: collapsed ? 8 : 20),
          alignment: collapsed ? Alignment.center : Alignment.centerLeft,
          child: collapsed
              ? const Icon(Icons.bolt, color: AppTheme.primaryColor, size: 24)
              : const Text(
                  'Nextronix',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
        ),
        const Divider(color: Colors.white10, height: 1),
        const SizedBox(height: 8),
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
      ],
    );
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
                  color: isActive ? Colors.white : Colors.white60,
                  size: 20,
                ),
                if (!collapsed) ...[
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.white60,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      fontSize: 13,
                    ),
                  ),
                  if (isActive) ...[
                    const Spacer(),
                    Container(
                      width: 3,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
