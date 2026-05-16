import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../core/theme/app_theme.dart';
import '../../provider/support_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/page_header.dart';
import '../../widgets/status_badge.dart';
import 'widgets/priority_badge.dart';

class SupportDetailScreen extends StatefulWidget {
  final int ticketId;
  const SupportDetailScreen({super.key, required this.ticketId});

  @override
  State<SupportDetailScreen> createState() => _SupportDetailScreenState();
}

class _SupportDetailScreenState extends State<SupportDetailScreen> {
  final _replyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SupportProvider>().loadTicketById(widget.ticketId);
    });
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _sendReply(SupportProvider p) async {
    final text = _replyController.text.trim();
    if (text.isEmpty) return;
    final err = await p.reply(widget.ticketId, text);
    if (!mounted) return;
    if (err == null) {
      _replyController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reply sent'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err.alertMessage),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SupportProvider>(
      builder: (context, p, _) {
        final t = p.selectedTicket;
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                title: t?.ticketNumber ?? 'Ticket',
                subtitle: t?.subject ?? '',
                onBack: () => context.go('/admin/support'),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: p.isLoading || t == null
                    ? const LoadingWidget(message: 'Loading ticket...')
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 2, child: _buildConversation(p)),
                          const SizedBox(width: 16),
                          Expanded(flex: 1, child: _buildSidebar(p)),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildConversation(SupportProvider p) {
    final t = p.selectedTicket!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ShadCard(
            padding: const EdgeInsets.all(16),
            child: t.messages.isEmpty
                ? const Center(child: Text('No messages yet'))
                : ListView.separated(
                    itemCount: t.messages.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (_, i) => _buildMessage(t.messages[i]),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        ShadCard(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              ShadInput(
                controller: _replyController,
                placeholder: const Text('Type your reply...'),
                maxLines: 4,
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Spacer(),
                  ShadButton(
                    leading: p.isReplying
                        ? const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(LucideIcons.send, size: 14),
                    onPressed: p.isReplying ? null : () => _sendReply(p),
                    child: Text(p.isReplying ? 'Sending...' : 'Send Reply'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessage(dynamic m) {
    final theme = ShadTheme.of(context);
    final isAdmin = m.senderType == 'admin';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isAdmin
                ? AppTheme.brand.withValues(alpha: 0.1)
                : AppTheme.successColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isAdmin ? LucideIcons.shield : LucideIcons.user,
            color: isAdmin ? AppTheme.brand : AppTheme.successColor,
            size: 14,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    isAdmin ? 'Admin' : (m.senderName ?? 'Customer'),
                    style: theme.textTheme.small.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (m.createdAt != null)
                    Text(
                      DateFormat(
                        'MMM dd, h:mm a',
                      ).format(DateTime.parse(m.createdAt!)),
                      style: theme.textTheme.muted.copyWith(fontSize: 11),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.muted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(m.message, style: theme.textTheme.small),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSidebar(SupportProvider p) {
    final t = p.selectedTicket!;
    final theme = ShadTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ShadCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Status & Priority',
                style: theme.textTheme.h4.copyWith(fontSize: 13),
              ),
              const SizedBox(height: 12),
              _buildField('Status', StatusBadge(status: t.status)),
              const SizedBox(height: 8),
              _buildField('Priority', PriorityBadge(priority: t.priority)),
              const SizedBox(height: 14),
              _buildStatusButtons(p),
              const SizedBox(height: 8),
              _buildPriorityButtons(p),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ShadCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Customer',
                style: theme.textTheme.h4.copyWith(fontSize: 13),
              ),
              const SizedBox(height: 12),
              _buildInfoRow(LucideIcons.user, t.customerName ?? '-'),
              const SizedBox(height: 8),
              _buildInfoRow(LucideIcons.mail, t.customerEmail ?? '-'),
              if (t.customerMobile != null) ...[
                const SizedBox(height: 8),
                _buildInfoRow(LucideIcons.phone, t.customerMobile!),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildField(String label, Widget value) {
    final theme = ShadTheme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.muted.copyWith(fontSize: 12)),
        value,
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String value) {
    final theme = ShadTheme.of(context);
    return Row(
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.mutedForeground),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.small.copyWith(fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusButtons(SupportProvider p) {
    final statuses = ['open', 'pending', 'resolved', 'closed'];
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: statuses
          .map(
            (s) => ShadButton.outline(
              size: ShadButtonSize.sm,
              onPressed: () => p.updateStatus(widget.ticketId, s),
              child: Text(
                s.toUpperCase(),
                style: const TextStyle(fontSize: 10),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildPriorityButtons(SupportProvider p) {
    final priorities = ['low', 'medium', 'high', 'urgent'];
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: priorities
          .map(
            (s) => ShadButton.outline(
              size: ShadButtonSize.sm,
              onPressed: () => p.updatePriority(widget.ticketId, s),
              child: Text(
                s.toUpperCase(),
                style: const TextStyle(fontSize: 10),
              ),
            ),
          )
          .toList(),
    );
  }
}
