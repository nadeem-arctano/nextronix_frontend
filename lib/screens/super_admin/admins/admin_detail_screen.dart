import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../core/theme/app_theme.dart';
import '../../../api/base_url.dart';
import '../../../static_values/static_values.dart';
import '../../../widgets/page_header.dart';
import '../../../widgets/status_badge.dart';
import 'admin_form_screen.dart';

/// Admin detail screen showing the brand Admin profile info.
/// Fetches `GET /api/super-admin/admins/:id`.
class AdminDetailScreen extends StatefulWidget {
  final int adminId;

  const AdminDetailScreen({super.key, required this.adminId});

  @override
  State<AdminDetailScreen> createState() => _AdminDetailScreenState();
}

class _AdminDetailScreenState extends State<AdminDetailScreen> {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: BaseUrl.baseurl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  Map<String, dynamic>? _admin;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (globalAccessToken != null) {
            options.headers['Authorization'] = 'Bearer $globalAccessToken';
          }
          handler.next(options);
        },
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadAdmin();
    });
  }

  Future<void> _loadAdmin() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _dio.get('super-admin/admins/${widget.adminId}');
      final data = response.data;
      setState(() {
        _admin = data['data'] is Map<String, dynamic>
            ? data['data'] as Map<String, dynamic>
            : data is Map<String, dynamic>
            ? data
            : null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = _extractErrorMessage(e) ?? 'Failed to load admin details';
      });
    }
  }

  void _navigateToEdit() async {
    if (_admin == null) return;
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            AdminFormScreen(adminId: widget.adminId, initialData: _admin),
      ),
    );
    if (result == true && mounted) {
      _loadAdmin();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Admin Details',
            actions: [
              ShadButton.outline(
                leading: const Icon(LucideIcons.arrowLeft, size: 16),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Back'),
              ),
              const SizedBox(width: 8),
              if (_admin != null)
                ShadButton(
                  leading: const Icon(LucideIcons.pencil, size: 16),
                  onPressed: _navigateToEdit,
                  child: const Text('Edit'),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const DetailSkeleton();
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppTheme.dangerColor),
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: AppTheme.dangerColor)),
            const SizedBox(height: 16),
            ShadButton.outline(
              onPressed: _loadAdmin,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_admin == null) {
      return const Center(child: Text('Admin not found'));
    }

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: _buildProfileCard(),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    final admin = _admin!;
    final theme = ShadTheme.of(context);
    final createdAt = admin['createdAt'] != null
        ? _formatDate(admin['createdAt'].toString())
        : '-';
    final updatedAt = admin['updatedAt'] != null
        ? _formatDate(admin['updatedAt'].toString())
        : '-';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with avatar and name
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: theme.colorScheme.primary.withValues(
                  alpha: 0.1,
                ),
                child: Text(
                  _getInitials(admin['name']?.toString() ?? ''),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      admin['name']?.toString() ?? '-',
                      style: theme.textTheme.h4,
                    ),
                    const SizedBox(height: 4),
                    StatusBadge(
                      status: admin['status']?.toString() ?? 'active',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),
          // Detail fields
          _buildDetailRow(
            icon: LucideIcons.mail,
            label: 'Email',
            value: admin['email']?.toString() ?? '-',
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            icon: LucideIcons.phone,
            label: 'Mobile',
            value: admin['mobile']?.toString() ?? '-',
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            icon: LucideIcons.shield,
            label: 'Role',
            value: admin['role']?.toString() ?? 'admin',
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            icon: LucideIcons.calendar,
            label: 'Created',
            value: createdAt,
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            icon: LucideIcons.calendarClock,
            label: 'Last Updated',
            value: updatedAt,
          ),
          // Show business name if available
          if (admin['businessName'] != null &&
              admin['businessName'].toString().isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildDetailRow(
              icon: LucideIcons.building2,
              label: 'Business Name',
              value: admin['businessName'].toString(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = ShadTheme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.mutedForeground),
        const SizedBox(width: 12),
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: theme.textTheme.muted.copyWith(fontSize: 13),
          ),
        ),
        Expanded(child: Text(value, style: theme.textTheme.small)),
      ],
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy • hh:mm a').format(dt);
    } catch (_) {
      return dateStr;
    }
  }

  String? _extractErrorMessage(dynamic e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        return data['message']?.toString();
      }
    }
    return null;
  }
}

/// Simple skeleton for a detail page while loading.
class DetailSkeleton extends StatelessWidget {
  const DetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 160,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 80,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),
              for (int i = 0; i < 5; i++) ...[
                Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 100,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      width: 200,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
                if (i < 4) const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
