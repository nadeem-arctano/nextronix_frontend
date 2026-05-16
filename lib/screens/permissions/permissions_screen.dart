import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../core/services/toast_service.dart';
import '../../core/theme/app_theme.dart';
import '../../model/response/response.dart';
import '../../provider/auth_provider.dart';
import '../../provider/permission_provider.dart';
import '../../provider/team_provider.dart';
import '../../widgets/page_header.dart';
import '../../widgets/skeletons.dart';
import '../../widgets/user_avatar.dart';

/// Admin-only permissions screen.
///
/// Left pane: list of managers under this brand.
/// Right pane: matrix of permission keys grouped by module — toggle, then save.
class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  Manager? _selected;
  Set<String> _localGrants = {};
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final t = context.read<TeamProvider>();
      final p = context.read<PermissionProvider>();
      if (t.managers.isEmpty) t.loadManagers();
      if (p.catalog.isEmpty) p.loadCatalog();
    });
  }

  Future<void> _select(Manager m) async {
    setState(() {
      _selected = m;
      _dirty = false;
    });
    final p = context.read<PermissionProvider>();
    await p.loadGrantsFor(m.id);
    if (!mounted) return;
    setState(() {
      _localGrants = p.grantsFor(m.id);
    });
  }

  void _toggle(String key) {
    setState(() {
      if (_localGrants.contains(key)) {
        _localGrants.remove(key);
      } else {
        _localGrants.add(key);
      }
      _dirty = true;
    });
  }

  Future<void> _save() async {
    if (_selected == null) return;
    final err = await context.read<PermissionProvider>().save(
      userId: _selected!.id,
      keys: _localGrants,
    );
    if (!mounted) return;
    if (err != null) {
      ToastService.fromError(context, err);
    } else {
      ToastService.success(context, 'Permissions saved');
      setState(() => _dirty = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (!auth.isAdmin) return _buildAccessDenied();

    final team = context.watch<TeamProvider>();
    final perms = context.watch<PermissionProvider>();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(
            title: 'Permissions',
            subtitle:
                'Decide which sections each manager can access on your brand',
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(width: 320, child: _buildManagerList(team)),
                const SizedBox(width: 16),
                Expanded(child: _buildMatrix(perms, team)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessDenied() {
    final theme = ShadTheme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.lock,
              size: 48,
              color: theme.colorScheme.mutedForeground,
            ),
            const SizedBox(height: 16),
            Text('Admin access required', style: theme.textTheme.h4),
            const SizedBox(height: 6),
            Text(
              'Only the brand owner can edit permissions.',
              style: theme.textTheme.muted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagerList(TeamProvider team) {
    final theme = ShadTheme.of(context);
    if (team.isLoading && team.managers.isEmpty) {
      return const CardSkeleton(lines: 6);
    }
    if (team.managers.isEmpty) {
      return ShadCard(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.users,
                size: 32,
                color: theme.colorScheme.mutedForeground,
              ),
              const SizedBox(height: 12),
              Text('No managers yet', style: theme.textTheme.h4),
              const SizedBox(height: 6),
              Text(
                'Add managers from the Team screen to grant them permissions.',
                style: theme.textTheme.muted,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    return ShadCard(
      padding: EdgeInsets.zero,
      child: ListView.separated(
        itemCount: team.managers.length,
        separatorBuilder: (_, __) =>
            Divider(height: 1, color: theme.colorScheme.border),
        itemBuilder: (_, i) {
          final m = team.managers[i];
          final selected = _selected?.id == m.id;
          return InkWell(
            onTap: () => _select(m),
            child: Container(
              decoration: BoxDecoration(
                color: selected
                    ? AppTheme.brand.withValues(alpha: 0.08)
                    : Colors.transparent,
                border: selected
                    ? Border(left: BorderSide(color: AppTheme.brand, width: 3))
                    : null,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  UserAvatar(name: m.name ?? 'M', radius: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m.name ?? '-',
                          style: theme.textTheme.small.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (m.email != null)
                          Text(
                            m.email!,
                            style: theme.textTheme.muted.copyWith(fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMatrix(PermissionProvider perms, TeamProvider team) {
    final theme = ShadTheme.of(context);
    if (_selected == null) {
      return ShadCard(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  LucideIcons.shieldCheck,
                  size: 40,
                  color: theme.colorScheme.mutedForeground,
                ),
                const SizedBox(height: 12),
                Text('Select a manager', style: theme.textTheme.h4),
                const SizedBox(height: 6),
                Text(
                  'Choose a manager from the left to view and edit their permissions.',
                  style: theme.textTheme.muted,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }
    if (perms.isLoading && perms.catalog.isEmpty) {
      return const CardSkeleton(lines: 12);
    }

    final grouped = perms.catalogByModule;
    return ShadCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: theme.colorScheme.border),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_selected!.name ?? '-', style: theme.textTheme.h4),
                      Text(
                        '${_localGrants.length} of ${perms.catalog.length} permissions granted',
                        style: theme.textTheme.muted,
                      ),
                    ],
                  ),
                ),
                if (_dirty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.warningColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Unsaved changes',
                      style: TextStyle(
                        color: AppTheme.warningColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const SizedBox(width: 12),
                ShadButton(
                  leading: const Icon(LucideIcons.check, size: 14),
                  onPressed: _dirty && !perms.isSaving ? _save : null,
                  child: Text(perms.isSaving ? 'Saving...' : 'Save'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: grouped.entries.map((entry) {
                return _ModuleSection(
                  module: entry.key,
                  perms: entry.value,
                  selected: _localGrants,
                  onToggle: _toggle,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModuleSection extends StatelessWidget {
  final String module;
  final List<PermissionDef> perms;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  const _ModuleSection({
    required this.module,
    required this.perms,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.muted.withValues(alpha: 0.4),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
            ),
            child: Text(
              module.toUpperCase(),
              style: theme.textTheme.muted.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
              ),
            ),
          ),
          for (final p in perms)
            _PermRow(
              perm: p,
              checked: selected.contains(p.key),
              onToggle: () => onToggle(p.key),
            ),
        ],
      ),
    );
  }
}

class _PermRow extends StatelessWidget {
  final PermissionDef perm;
  final bool checked;
  final VoidCallback onToggle;

  const _PermRow({
    required this.perm,
    required this.checked,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return InkWell(
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Switch(value: checked, onChanged: (_) => onToggle()),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(perm.label, style: theme.textTheme.small),
                  if (perm.description != null && perm.description!.isNotEmpty)
                    Text(
                      perm.description!,
                      style: theme.textTheme.muted.copyWith(fontSize: 11),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              perm.key,
              style: TextStyle(
                fontFamily: 'Courier',
                fontSize: 10,
                color: theme.colorScheme.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
