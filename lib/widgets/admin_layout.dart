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
      title: isMobile ? const Text('NextTronics Admin') : null,
      actions: [
        if (!isMobile)
          IconButton(
            icon: Icon(_isSidebarCollapsed ? Icons.menu_open : Icons.menu),
            onPressed: () =>
                setState(() => _isSidebarCollapsed = !_isSidebarCollapsed),
          ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
        const CircleAvatar(
          radius: 16,
          backgroundColor: AppTheme.primaryColor,
          child: Text('A', style: TextStyle(color: Colors.white, fontSize: 14)),
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
      width: collapsed ? 70 : 260,
      decoration: const BoxDecoration(color: AppTheme.sidebarColor),
      child: _buildSidebarContent(context, collapsed: collapsed),
    );
  }

  Widget _buildSidebarContent(BuildContext context, {required bool collapsed}) {
    final currentPath = GoRouterState.of(context).uri.toString();

    return Column(
      children: [
        Container(
          height: 64,
          padding: EdgeInsets.symmetric(horizontal: collapsed ? 8 : 20),
          alignment: collapsed ? Alignment.center : Alignment.centerLeft,
          child: collapsed
              ? const Icon(Icons.bolt, color: AppTheme.primaryColor, size: 28)
              : const Text(
                  'NextTronics',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
        const Divider(color: Colors.white12, height: 1),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: isActive
            ? AppTheme.primaryColor.withOpacity(0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            context.go(path);
            if (MediaQuery.of(context).size.width < 768) {
              Navigator.pop(context);
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: collapsed ? 12 : 16,
              vertical: 12,
            ),
            child: Row(
              mainAxisAlignment: collapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  color: isActive ? AppTheme.primaryColor : Colors.white70,
                  size: 22,
                ),
                if (!collapsed) ...[
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: TextStyle(
                      color: isActive ? AppTheme.primaryColor : Colors.white70,
                      fontWeight: isActive
                          ? FontWeight.w600
                          : FontWeight.normal,
                      fontSize: 14,
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
