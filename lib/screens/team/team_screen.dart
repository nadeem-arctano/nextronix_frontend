import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../core/theme/app_theme.dart';
import '../../model/response/response.dart';
import '../../provider/auth_provider.dart';
import '../../provider/team_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/page_header.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/user_avatar.dart';

class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeamProvider>().loadManagers();
    });
  }

  Future<void> _openCreateDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => const _ManagerFormDialog(),
    );
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Manager created'),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _openEditDialog(Manager manager) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => _ManagerFormDialog(manager: manager),
    );
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Manager updated'),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _confirmDelete(Manager manager) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove manager?'),
        content: Text(
          '${manager.name ?? 'This manager'} will lose access to your brand. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ShadButton.destructive(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final err = await context.read<TeamProvider>().deleteManager(manager.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(err == null ? 'Manager removed' : err.alertMessage),
        backgroundColor: err == null
            ? AppTheme.successColor
            : AppTheme.dangerColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (!auth.isAdmin) {
      return _buildAccessDenied();
    }

    return Consumer<TeamProvider>(
      builder: (context, p, _) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                title: 'Team',
                subtitle: 'Manage staff who can administer your brand',
                actions: [
                  ShadButton(
                    leading: const Icon(LucideIcons.userPlus, size: 14),
                    onPressed: _openCreateDialog,
                    child: const Text('Add Manager'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (p.isLoading && p.managers.isEmpty)
                const Expanded(child: LoadingWidget(message: 'Loading team...'))
              else if (p.managers.isEmpty)
                Expanded(child: _buildEmpty())
              else
                Expanded(child: _buildList(p)),
            ],
          ),
        );
      },
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
              'Only the brand owner can manage team members.',
              style: theme.textTheme.muted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    final theme = ShadTheme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: theme.colorScheme.muted.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              LucideIcons.users,
              size: 28,
              color: theme.colorScheme.mutedForeground,
            ),
          ),
          const SizedBox(height: 16),
          Text('No managers yet', style: theme.textTheme.h4),
          const SizedBox(height: 6),
          Text(
            'Add managers to delegate day-to-day operations.',
            style: theme.textTheme.muted,
          ),
          const SizedBox(height: 16),
          ShadButton(
            leading: const Icon(LucideIcons.userPlus, size: 14),
            onPressed: _openCreateDialog,
            child: const Text('Add your first manager'),
          ),
        ],
      ),
    );
  }

  Widget _buildList(TeamProvider p) {
    final theme = ShadTheme.of(context);
    return ShadCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.muted.withValues(alpha: 0.3),
              border: Border(
                bottom: BorderSide(color: theme.colorScheme.border),
              ),
            ),
            child: Row(
              children: [
                _h('MANAGER', 3, theme),
                _h('EMAIL', 3, theme),
                _h('MOBILE', 2, theme),
                _h('STATUS', 1, theme),
                _h('JOINED', 2, theme),
                const SizedBox(width: 80),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: p.managers.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: theme.colorScheme.border),
              itemBuilder: (_, i) => _buildRow(p.managers[i], theme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(Manager m, ShadThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                UserAvatar(name: m.name ?? 'M', radius: 15),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    m.name ?? 'N/A',
                    style: theme.textTheme.small,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              m.email ?? '-',
              style: theme.textTheme.muted.copyWith(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              m.mobile ?? '-',
              style: theme.textTheme.muted.copyWith(fontSize: 12),
            ),
          ),
          Expanded(flex: 1, child: StatusBadge(status: m.status ?? 'active')),
          Expanded(
            flex: 2,
            child: Text(
              m.createdAt != null
                  ? DateFormat(
                      'MMM dd, yyyy',
                    ).format(DateTime.parse(m.createdAt!))
                  : '-',
              style: theme.textTheme.muted.copyWith(fontSize: 12),
            ),
          ),
          SizedBox(
            width: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(
                    LucideIcons.pencil,
                    size: 14,
                    color: theme.colorScheme.mutedForeground,
                  ),
                  tooltip: 'Edit',
                  onPressed: () => _openEditDialog(m),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 28,
                    minHeight: 28,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    LucideIcons.trash2,
                    size: 14,
                    color: AppTheme.dangerColor,
                  ),
                  tooltip: 'Remove',
                  onPressed: () => _confirmDelete(m),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 28,
                    minHeight: 28,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _h(String text, int flex, ShadThemeData theme) => Expanded(
    flex: flex,
    child: Text(
      text,
      style: theme.textTheme.muted.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),
  );
}

class _ManagerFormDialog extends StatefulWidget {
  final Manager? manager;
  const _ManagerFormDialog({this.manager});

  bool get isEdit => manager != null;

  @override
  State<_ManagerFormDialog> createState() => _ManagerFormDialogState();
}

class _ManagerFormDialogState extends State<_ManagerFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  String _status = 'active';
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    if (widget.manager != null) {
      _nameController.text = widget.manager!.name ?? '';
      _emailController.text = widget.manager!.email ?? '';
      _mobileController.text = widget.manager!.mobile ?? '';
      _status = widget.manager!.status ?? 'active';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final p = context.read<TeamProvider>();
    final err = widget.isEdit
        ? await p.updateManager(
            id: widget.manager!.id,
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            mobile: _mobileController.text.trim(),
            password: _passwordController.text.isEmpty
                ? null
                : _passwordController.text,
            status: _status,
          )
        : await p.createManager(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            mobile: _mobileController.text.trim().isEmpty
                ? null
                : _mobileController.text.trim(),
          );

    if (!mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err.alertMessage),
          backgroundColor: AppTheme.dangerColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.isEdit ? 'Edit manager' : 'Add manager',
                  style: theme.textTheme.h3,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.isEdit
                      ? 'Update this manager\'s details.'
                      : 'Create a manager who can administer your brand.',
                  style: theme.textTheme.muted,
                ),
                const SizedBox(height: 20),
                _label('Full name', theme),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameController,
                  decoration: _decoration(LucideIcons.user, 'Riya Sharma'),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Name required' : null,
                ),
                const SizedBox(height: 12),
                _label('Email', theme),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _emailController,
                  decoration: _decoration(LucideIcons.mail, 'name@brand.com'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email required';
                    if (!RegExp(
                      r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                    ).hasMatch(v.trim())) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _label('Mobile (optional)', theme),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _mobileController,
                  decoration: _decoration(LucideIcons.phone, '9876543210'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                _label(
                  widget.isEdit
                      ? 'New password (leave blank to keep current)'
                      : 'Password',
                  theme,
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    prefixIcon: const Icon(LucideIcons.lock, size: 16),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure ? LucideIcons.eye : LucideIcons.eyeOff,
                        size: 16,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: theme.colorScheme.border),
                    ),
                  ),
                  validator: (v) {
                    if (widget.isEdit && (v == null || v.isEmpty)) return null;
                    if (v == null || v.isEmpty) return 'Password required';
                    if (v.length < 6) return 'Min 6 characters';
                    return null;
                  },
                ),
                if (widget.isEdit) ...[
                  const SizedBox(height: 12),
                  _label('Status', theme),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _status,
                    decoration: _decoration(LucideIcons.circleCheck, 'Status'),
                    items: const [
                      DropdownMenuItem(value: 'active', child: Text('Active')),
                      DropdownMenuItem(
                        value: 'inactive',
                        child: Text('Inactive'),
                      ),
                      DropdownMenuItem(
                        value: 'blocked',
                        child: Text('Blocked'),
                      ),
                    ],
                    onChanged: (v) => setState(() => _status = v ?? 'active'),
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Consumer<TeamProvider>(
                      builder: (context, p, _) {
                        return Row(
                          children: [
                            ShadButton.outline(
                              onPressed: p.isSaving
                                  ? null
                                  : () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            const SizedBox(width: 10),
                            ShadButton(
                              leading: p.isSaving
                                  ? const SizedBox(
                                      width: 12,
                                      height: 12,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Icon(
                                      widget.isEdit
                                          ? LucideIcons.check
                                          : LucideIcons.userPlus,
                                      size: 14,
                                    ),
                              onPressed: p.isSaving ? null : _submit,
                              child: Text(
                                p.isSaving
                                    ? 'Saving...'
                                    : widget.isEdit
                                    ? 'Save changes'
                                    : 'Create manager',
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text, ShadThemeData theme) => Text(
    text,
    style: theme.textTheme.small.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
  );

  InputDecoration _decoration(IconData icon, String hint) => InputDecoration(
    hintText: hint,
    prefixIcon: Icon(icon, size: 16),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: ShadTheme.of(context).colorScheme.border),
    ),
  );
}
