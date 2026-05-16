import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../model/response/response.dart';
import '../../provider/notification_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/page_header.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<NotificationProvider>();
      p.loadStats();
      p.loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, p, _) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                title: 'Notifications',
                subtitle: '${p.unreadCount} unread',
                actions: [
                  if (p.unreadCount > 0)
                    ShadButton.outline(
                      size: ShadButtonSize.sm,
                      leading: const Icon(LucideIcons.checkCheck, size: 14),
                      onPressed: () => p.markAllRead(),
                      child: const Text('Mark all read'),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              _buildFilters(p),
              const SizedBox(height: 16),
              Expanded(
                child: p.isLoading && p.items.isEmpty
                    ? const LoadingWidget(message: 'Loading...')
                    : p.items.isEmpty
                    ? const EmptyWidget(message: 'No notifications')
                    : ListView.separated(
                        itemCount: p.items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) => _NotificationCard(
                          notification: p.items[i],
                          onTap: () => p.markAsRead(p.items[i].id),
                          onDelete: () => p.remove(p.items[i].id),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilters(NotificationProvider p) {
    return Row(
      children: [
        _chip('All', null, p.isReadFilter, (v) => p.setReadFilter(v)),
        const SizedBox(width: 6),
        _chip('Unread', false, p.isReadFilter, (v) => p.setReadFilter(v)),
        const SizedBox(width: 6),
        _chip('Read', true, p.isReadFilter, (v) => p.setReadFilter(v)),
      ],
    );
  }

  Widget _chip(
    String label,
    bool? value,
    bool? current,
    ValueChanged<bool?> onTap,
  ) {
    final theme = ShadTheme.of(context);
    final selected = current == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: selected
                ? theme.colorScheme.primaryForeground
                : theme.colorScheme.mutedForeground,
          ),
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final iconData = notificationIcon(notification.type);
    return InkWell(
      onTap: onTap,
      child: ShadCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconData.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(iconData.icon, color: iconData.color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: theme.textTheme.small.copyWith(
                            fontWeight: notification.isRead
                                ? FontWeight.w500
                                : FontWeight.w700,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF4F46E5),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  if (notification.message != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      notification.message!,
                      style: theme.textTheme.muted.copyWith(fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    _timeAgo(notification.createdAt),
                    style: theme.textTheme.muted.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                LucideIcons.x,
                size: 14,
                color: theme.colorScheme.mutedForeground,
              ),
              onPressed: onDelete,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            ),
          ],
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

_IconData notificationIcon(String type) {
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
