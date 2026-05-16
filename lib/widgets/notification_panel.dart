import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../core/theme/app_theme.dart';
import '../model/response/response.dart';
import '../provider/notification_provider.dart';

/// Right-anchored sliding notification panel.
/// Opens via [NotificationPanel.show] and slides in from the right.
class NotificationPanel {
  static Future<void> show(BuildContext context) async {
    // Load fresh notifications when opened.
    context.read<NotificationProvider>().loadNotifications();

    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Notifications',
      barrierColor: Colors.black.withValues(alpha: 0.25),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (context, anim, _, __) {
        final slide = Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic));
        return Align(
          alignment: Alignment.centerRight,
          child: SlideTransition(
            position: slide,
            child: const _NotificationPanelContent(),
          ),
        );
      },
    );
  }
}

class _NotificationPanelContent extends StatelessWidget {
  const _NotificationPanelContent();

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final width = MediaQuery.of(context).size.width;
    final panelWidth = width < 480 ? width : 400.0;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: panelWidth,
        height: double.infinity,
        decoration: BoxDecoration(
          color: theme.colorScheme.background,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(-4, 0),
            ),
          ],
        ),
        child: Consumer<NotificationProvider>(
          builder: (context, p, _) {
            return Column(
              children: [
                _buildHeader(context, p, theme),
                _buildFilters(context, p, theme),
                Divider(height: 1, color: theme.colorScheme.border),
                Expanded(child: _buildList(context, p, theme)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    NotificationProvider p,
    ShadThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 12, 12),
      child: Row(
        children: [
          Icon(LucideIcons.bell, size: 18, color: theme.colorScheme.foreground),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifications',
                  style: theme.textTheme.h4.copyWith(fontSize: 15),
                ),
                Text(
                  '${p.unreadCount} unread',
                  style: theme.textTheme.muted.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          if (p.unreadCount > 0)
            TextButton(
              onPressed: () => p.markAllRead(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Mark all read',
                style: TextStyle(fontSize: 11, color: AppTheme.brand),
              ),
            ),
          IconButton(
            icon: Icon(
              LucideIcons.x,
              size: 16,
              color: theme.colorScheme.mutedForeground,
            ),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(
    BuildContext context,
    NotificationProvider p,
    ShadThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Row(
        children: [
          _chip(theme, 'All', null, p.isReadFilter, p.setReadFilter),
          const SizedBox(width: 6),
          _chip(theme, 'Unread', false, p.isReadFilter, p.setReadFilter),
          const SizedBox(width: 6),
          _chip(theme, 'Read', true, p.isReadFilter, p.setReadFilter),
        ],
      ),
    );
  }

  Widget _chip(
    ShadThemeData theme,
    String label,
    bool? value,
    bool? current,
    ValueChanged<bool?> onTap,
  ) {
    final selected = current == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: selected
                ? theme.colorScheme.primaryForeground
                : theme.colorScheme.mutedForeground,
          ),
        ),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    NotificationProvider p,
    ShadThemeData theme,
  ) {
    if (p.isLoading && p.items.isEmpty) {
      return const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    if (p.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.inbox,
              size: 36,
              color: theme.colorScheme.mutedForeground,
            ),
            const SizedBox(height: 10),
            Text(
              'No notifications',
              style: theme.textTheme.muted.copyWith(fontSize: 12),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: p.items.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        color: theme.colorScheme.border.withValues(alpha: 0.5),
      ),
      itemBuilder: (_, i) => _NotificationTile(
        notification: p.items[i],
        onTap: () => p.markAsRead(p.items[i].id),
        onDelete: () => p.remove(p.items[i].id),
      ),
    );
  }
}

class _NotificationTile extends StatefulWidget {
  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  @override
  State<_NotificationTile> createState() => _NotificationTileState();
}

class _NotificationTileState extends State<_NotificationTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final n = widget.notification;
    final iconData = _iconFor(n.type);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
          color: _hovered
              ? theme.colorScheme.muted.withValues(alpha: 0.3)
              : !n.isRead
              ? AppTheme.brand.withValues(alpha: 0.04)
              : Colors.transparent,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconData.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(iconData.icon, color: iconData.color, size: 14),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            n.title,
                            style: theme.textTheme.small.copyWith(
                              fontSize: 12,
                              fontWeight: n.isRead
                                  ? FontWeight.w500
                                  : FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!n.isRead)
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(left: 6, top: 4),
                            decoration: const BoxDecoration(
                              color: AppTheme.brand,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    if (n.message != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        n.message!,
                        style: theme.textTheme.muted.copyWith(fontSize: 11),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      _timeAgo(n.createdAt),
                      style: theme.textTheme.muted.copyWith(fontSize: 10),
                    ),
                  ],
                ),
              ),
              if (_hovered)
                IconButton(
                  icon: Icon(
                    LucideIcons.x,
                    size: 12,
                    color: theme.colorScheme.mutedForeground,
                  ),
                  onPressed: widget.onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconData {
  final IconData icon;
  final Color color;
  _IconData(this.icon, this.color);
}

_IconData _iconFor(String type) {
  switch (type) {
    case 'new_order':
      return _IconData(LucideIcons.shoppingBag, const Color(0xFF4F46E5));
    case 'payment_failed':
      return _IconData(LucideIcons.creditCard, const Color(0xFFDC2626));
    case 'low_stock':
      return _IconData(LucideIcons.triangleAlert, const Color(0xFFF59E0B));
    case 'new_user':
      return _IconData(LucideIcons.userPlus, const Color(0xFF059669));
    case 'return_request':
      return _IconData(LucideIcons.refreshCw, const Color(0xFFEA580C));
    case 'refund_completed':
      return _IconData(LucideIcons.indianRupee, const Color(0xFF10B981));
    case 'ticket_created':
      return _IconData(LucideIcons.lifeBuoy, const Color(0xFF7C3AED));
    case 'contact_message':
      return _IconData(LucideIcons.mail, const Color(0xFF0891B2));
    default:
      return _IconData(LucideIcons.bell, const Color(0xFF6B7280));
  }
}

String _timeAgo(String? dateStr) {
  if (dateStr == null) return '';
  try {
    final date = DateTime.parse(dateStr);
    final diff = DateTime.now().difference(date);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM dd, yyyy').format(date);
  } catch (_) {
    return '';
  }
}
