import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../core/theme/app_theme.dart';
import '../model/response/response.dart';
import '../provider/notification_provider.dart';

/// Floating dropdown notification panel anchored to the bell icon.
/// Use [NotificationPanel.show] passing the bell's [GlobalKey] to anchor.
class NotificationPanel {
  static Future<void> show(
    BuildContext context, {
    required GlobalKey anchorKey,
  }) async {
    // Load fresh notifications when opened.
    context.read<NotificationProvider>().loadNotifications();

    // Compute anchor position from the bell.
    final renderBox =
        anchorKey.currentContext?.findRenderObject() as RenderBox?;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    Offset bellOffset = const Offset(80, 60);
    Size bellSize = const Size(32, 32);
    if (renderBox != null) {
      bellOffset = renderBox.localToGlobal(Offset.zero, ancestor: overlay);
      bellSize = renderBox.size;
    }

    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Notifications',
      barrierColor: Colors.black.withValues(alpha: 0.18),
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (context, anim, _, __) {
        final fade = CurvedAnimation(parent: anim, curve: Curves.easeOut);
        return _PanelLayout(
          anchorOffset: bellOffset,
          anchorSize: bellSize,
          animation: fade,
          child: const _NotificationPanelContent(),
        );
      },
    );
  }
}

/// Positions the panel below+right-of the bell with screen-edge clamping
/// and a fade + scale entrance.
class _PanelLayout extends StatelessWidget {
  final Offset anchorOffset;
  final Size anchorSize;
  final Animation<double> animation;
  final Widget child;

  const _PanelLayout({
    required this.anchorOffset,
    required this.anchorSize,
    required this.animation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    const panelWidth = 400.0;
    const panelMaxHeight = 560.0;
    const margin = 16.0;
    const sidebarGap = 0; // breathing room from the sidebar / anchor

    // Drop the panel below the bell with a comfortable gap.
    final top = (anchorOffset.dy + anchorSize.height + sidebarGap).clamp(
      margin,
      screen.height - margin,
    );

    // Place the panel to the RIGHT of the bell so it floats over the content
    // area instead of hugging the sidebar edge.
    final preferredLeft = anchorOffset.dx + anchorSize.width + sidebarGap;
    final maxLeft = screen.width - panelWidth - margin;
    final left = preferredLeft > maxLeft ? maxLeft : preferredLeft;

    return Stack(
      children: [
        Positioned(
          left: left
              .clamp(margin, screen.width - panelWidth - margin)
              .toDouble(),
          top: top.toDouble(),
          child: FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween(begin: 0.96, end: 1.0).animate(animation),
              alignment: Alignment.topLeft,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: panelWidth,
                  maxHeight: panelMaxHeight,
                ),
                child: child,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NotificationPanelContent extends StatelessWidget {
  const _NotificationPanelContent();

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.colorScheme.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 30,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Consumer<NotificationProvider>(
            builder: (context, p, _) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(context, p, theme),
                  _buildFilters(context, p, theme),
                  Flexible(child: _buildList(context, p, theme)),
                ],
              );
            },
          ),
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
          Expanded(
            child: Text(
              'Notifications',
              style: theme.textTheme.h3.copyWith(fontSize: 18),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.muted.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  LucideIcons.x,
                  size: 14,
                  color: theme.colorScheme.foreground,
                ),
              ),
            ),
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
    final filters = const [
      ('All', null),
      ('Reminders', 'ticket_created'),
      ('Payment', 'payment_failed'),
      ('Booking', 'new_order'),
      ('Confirmation', 'refund_completed'),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final f in filters) ...[
              _filterChip(theme, f.$1, f.$2, p),
              const SizedBox(width: 6),
            ],
          ],
        ),
      ),
    );
  }

  Widget _filterChip(
    ShadThemeData theme,
    String label,
    String? value,
    NotificationProvider p,
  ) {
    final selected = p.typeFilter == value;
    return GestureDetector(
      onTap: () => p.setTypeFilter(value),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: selected ? theme.colorScheme.foreground : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.colorScheme.border),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: selected
                  ? theme.colorScheme.background
                  : theme.colorScheme.foreground,
            ),
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
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    if (p.items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40),
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

    final groups = _groupByDate(p.items);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < groups.length; i++)
            _buildGroup(
              context,
              theme,
              groups[i],
              showMarkAllLink: i == 0 && p.unreadCount > 0,
              onMarkAll: () => p.markAllRead(),
              onTapItem: (n) => p.markAsRead(n.id),
              onDelete: (n) => p.remove(n.id),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildGroup(
    BuildContext context,
    ShadThemeData theme,
    _NotificationGroup group, {
    required bool showMarkAllLink,
    required VoidCallback onMarkAll,
    required ValueChanged<AppNotification> onTapItem,
    required ValueChanged<AppNotification> onDelete,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
          child: Row(
            children: [
              Text(
                group.label,
                style: theme.textTheme.muted.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.foreground.withValues(alpha: 0.7),
                ),
              ),
              const Spacer(),
              if (showMarkAllLink)
                GestureDetector(
                  onTap: onMarkAll,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Text(
                      'Mark as all read',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.dangerColor.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        ...group.items.map(
          (n) => _NotificationTile(
            notification: n,
            onTap: () => onTapItem(n),
            onDelete: () => onDelete(n),
          ),
        ),
      ],
    );
  }

  List<_NotificationGroup> _groupByDate(List<AppNotification> items) {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    String labelFor(DateTime d) {
      final dd = DateTime(d.year, d.month, d.day);
      final tt = DateTime(today.year, today.month, today.day);
      final yy = DateTime(yesterday.year, yesterday.month, yesterday.day);
      if (dd == tt) return 'Today';
      if (dd == yy) return 'Yesterday';
      final diff = tt.difference(dd).inDays;
      if (diff < 7) return DateFormat('EEEE').format(d);
      return DateFormat('MMMM dd').format(d);
    }

    final groups = <String, List<AppNotification>>{};
    for (final n in items) {
      DateTime d;
      try {
        d = n.createdAt != null ? DateTime.parse(n.createdAt!) : DateTime.now();
      } catch (_) {
        d = DateTime.now();
      }
      final label = labelFor(d);
      groups.putIfAbsent(label, () => []).add(n);
    }

    return groups.entries
        .map((e) => _NotificationGroup(label: e.key, items: e.value))
        .toList();
  }
}

class _NotificationGroup {
  final String label;
  final List<AppNotification> items;
  _NotificationGroup({required this.label, required this.items});
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.fromLTRB(20, 10, 16, 10),
          color: _hovered
              ? theme.colorScheme.muted.withValues(alpha: 0.4)
              : Colors.transparent,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: theme.colorScheme.muted.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(iconData.icon, color: iconData.color, size: 14),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            n.title,
                            style: theme.textTheme.small.copyWith(
                              fontSize: 13,
                              fontWeight: n.isRead
                                  ? FontWeight.w500
                                  : FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _timeOnly(n.createdAt),
                          style: theme.textTheme.muted.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                    if (n.message != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        n.message!,
                        style: theme.textTheme.muted.copyWith(
                          fontSize: 12,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (!n.isRead)
                Container(
                  width: 7,
                  height: 7,
                  margin: const EdgeInsets.only(left: 8, top: 6),
                  decoration: const BoxDecoration(
                    color: AppTheme.brand,
                    shape: BoxShape.circle,
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
      return _IconData(LucideIcons.shoppingBag, const Color(0xFF6B7280));
    case 'payment_failed':
      return _IconData(LucideIcons.creditCard, const Color(0xFF6B7280));
    case 'low_stock':
      return _IconData(LucideIcons.triangleAlert, const Color(0xFF6B7280));
    case 'new_user':
      return _IconData(LucideIcons.userPlus, const Color(0xFF6B7280));
    case 'return_request':
      return _IconData(LucideIcons.refreshCw, const Color(0xFF6B7280));
    case 'refund_completed':
      return _IconData(LucideIcons.indianRupee, const Color(0xFF6B7280));
    case 'ticket_created':
      return _IconData(LucideIcons.bell, const Color(0xFF6B7280));
    case 'contact_message':
      return _IconData(LucideIcons.mail, const Color(0xFF6B7280));
    default:
      return _IconData(LucideIcons.bell, const Color(0xFF6B7280));
  }
}

String _timeOnly(String? dateStr) {
  if (dateStr == null) return '';
  try {
    final date = DateTime.parse(dateStr);
    return DateFormat('h:mm a').format(date).toLowerCase();
  } catch (_) {
    return '';
  }
}
