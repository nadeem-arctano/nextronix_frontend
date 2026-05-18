import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/theme_provider.dart';
import '../provider/auth_provider.dart';

/// Shell layout for the Super Admin route subtree with a left sidebar.
class SuperAdminLayout extends StatefulWidget {
  final Widget child;
  const SuperAdminLayout({super.key, required this.child});

  @override
  State<SuperAdminLayout> createState() => _SuperAdminLayoutState();
}

class _SuperAdminLayoutState extends State<SuperAdminLayout> {
  bool _isSidebarCollapsed = false;
  int _hoveredIndex = -1;

  static const _navItems = [
    _NavItem(
      icon: LucideIcons.layoutDashboard,
      label: 'Dashboard',
      path: '/super-admin/dashboard',
    ),
    _NavItem(
      icon: LucideIcons.building2,
      label: 'Admins',
      path: '/super-admin/admins',
    ),
    _NavItem(
      icon: LucideIcons.layers,
      label: 'Categories',
      path: '/super-admin/masters/categories',
    ),
    _NavItem(
      icon: LucideIcons.fileText,
      label: 'HSN Codes',
      path: '/super-admin/masters/hsn',
    ),
    _NavItem(
      icon: LucideIcons.palette,
      label: 'Colors',
      path: '/super-admin/masters/colors',
    ),
    _NavItem(
      icon: LucideIcons.box,
      label: 'Materials',
      path: '/super-admin/masters/materials',
    ),
  ];

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

  Widget _buildMobileHeader(BuildContext context) {
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
            children: [_buildLogo(collapsed)],
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

        const SizedBox(height: 12),

        // Super Admin badge
        if (!collapsed)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.brand.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: AppTheme.brand.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.shield, color: AppTheme.brand, size: 14),
                  const SizedBox(width: 6),
                  const Text(
                    'Super Admin',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(height: 16),

        // Navigation
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: collapsed ? 8 : 12),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (!collapsed)
                    Padding(
                      padding: const EdgeInsets.only(left: 12, bottom: 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'PLATFORM',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.3),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  for (var i = 0; i < _navItems.length; i++)
                    _buildNavItem(
                      context,
                      i,
                      _navItems[i],
                      currentPath,
                      collapsed,
                    ),
                ],
              ),
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

        // Profile section
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
                  'SA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
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
                'SA',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Consumer<AuthProvider>(
              builder: (context, auth, _) {
                final name = auth.user?.name ?? 'Super Admin';
                final email = auth.user?.email ?? '';
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      email,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                );
              },
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
    context.read<AuthProvider>().logout();
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    _NavItem item,
    String currentPath,
    bool collapsed,
  ) {
    final isActive =
        currentPath == item.path || currentPath.startsWith('${item.path}/');
    final isHovered = _hoveredIndex == index;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hoveredIndex = index),
        onExit: (_) => setState(() => _hoveredIndex = -1),
        child: GestureDetector(
          onTap: () {
            context.go(item.path);
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
                  item.icon,
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
                      item.label,
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

class _NavItem {
  final IconData icon;
  final String label;
  final String path;
  const _NavItem({required this.icon, required this.label, required this.path});
}
