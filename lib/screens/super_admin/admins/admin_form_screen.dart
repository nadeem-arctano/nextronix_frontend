import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../core/theme/app_theme.dart';
import '../../../api/base_url.dart';
import '../../../static_values/static_values.dart';
import '../../../widgets/page_header.dart';

/// Admin form screen for creating or editing a brand Admin account.
/// Calls `POST /api/super-admin/admins` (create) or
/// `PUT /api/super-admin/admins/:id` (edit).
///
/// Fields:
/// - name, email, mobile (always)
/// - password (create only)
/// - status (edit only)
///
/// On 409 DUPLICATE_FIELD with field:'email', highlights the email field inline.
class AdminFormScreen extends StatefulWidget {
  /// When null, the screen is in "create" mode. When provided, it's "edit" mode.
  final int? adminId;

  /// Optional pre-loaded admin data for edit mode to avoid an extra fetch.
  final Map<String, dynamic>? initialData;

  const AdminFormScreen({super.key, this.adminId, this.initialData});

  @override
  State<AdminFormScreen> createState() => _AdminFormScreenState();
}

class _AdminFormScreenState extends State<AdminFormScreen> {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: BaseUrl.baseurl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();

  String _status = 'active';
  bool _isLoading = false;
  bool _isFetchingAdmin = false;
  String? _generalError;
  String? _emailError;

  bool get _isEditMode => widget.adminId != null;

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

    if (_isEditMode && widget.initialData != null) {
      _populateFromData(widget.initialData!);
    } else if (_isEditMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _fetchAdmin();
      });
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

  void _populateFromData(Map<String, dynamic> data) {
    _nameController.text = data['name']?.toString() ?? '';
    _emailController.text = data['email']?.toString() ?? '';
    _mobileController.text = data['mobile']?.toString() ?? '';
    _status = data['status']?.toString() ?? 'active';
  }

  Future<void> _fetchAdmin() async {
    setState(() => _isFetchingAdmin = true);
    try {
      final response = await _dio.get('super-admin/admins/${widget.adminId}');
      final data = response.data;
      final admin = data['data'] ?? data;
      _populateFromData(admin is Map<String, dynamic> ? admin : {});
      setState(() => _isFetchingAdmin = false);
    } catch (e) {
      setState(() {
        _isFetchingAdmin = false;
        _generalError = _extractErrorMessage(e) ?? 'Failed to load admin';
      });
    }
  }

  Future<void> _submit() async {
    setState(() {
      _emailError = null;
      _generalError = null;
    });

    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      final body = <String, dynamic>{
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'mobile': _mobileController.text.trim(),
      };

      if (_isEditMode) {
        body['status'] = _status;
        await _dio.put('super-admin/admins/${widget.adminId}', data: body);
      } else {
        body['password'] = _passwordController.text;
        await _dio.post('super-admin/admins', data: body);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      if (e.response?.statusCode == 409 &&
          data is Map<String, dynamic> &&
          data['code'] == 'DUPLICATE_FIELD' &&
          data['field'] == 'email') {
        setState(() {
          _emailError =
              data['message']?.toString() ?? 'This email is already in use';
        });
      } else {
        setState(() {
          _generalError = _extractErrorMessage(e) ?? 'Something went wrong';
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isFetchingAdmin) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: _isEditMode ? 'Edit Admin' : 'Create Admin',
            actions: [
              ShadButton.outline(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 8),
              ShadButton(
                enabled: !_isLoading,
                onPressed: _submit,
                child: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isEditMode ? 'Update' : 'Create'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: _buildForm(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_generalError != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.dangerColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 18,
                    color: AppTheme.dangerColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _generalError!,
                      style: TextStyle(
                        color: AppTheme.dangerColor,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
          _buildFieldLabel('Full Name', required: true),
          const SizedBox(height: 6),
          ShadInput(
            controller: _nameController,
            placeholder: const Text('Enter admin name'),
          ),
          const SizedBox(height: 20),
          _buildFieldLabel('Email Address', required: true),
          const SizedBox(height: 6),
          ShadInput(
            controller: _emailController,
            placeholder: const Text('Enter email address'),
            keyboardType: TextInputType.emailAddress,
          ),
          if (_emailError != null) ...[
            const SizedBox(height: 6),
            Text(
              _emailError!,
              style: TextStyle(color: AppTheme.dangerColor, fontSize: 12),
            ),
          ],
          const SizedBox(height: 20),
          _buildFieldLabel('Mobile Number', required: true),
          const SizedBox(height: 6),
          ShadInput(
            controller: _mobileController,
            placeholder: const Text('Enter mobile number'),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 20),
          if (!_isEditMode) ...[
            _buildFieldLabel('Password', required: true),
            const SizedBox(height: 6),
            ShadInput(
              controller: _passwordController,
              placeholder: const Text('Enter password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
          ],
          if (_isEditMode) ...[
            _buildFieldLabel('Status'),
            const SizedBox(height: 6),
            ShadSelect<String>(
              initialValue: _status,
              options: const [
                ShadOption(value: 'active', child: Text('Active')),
                ShadOption(value: 'blocked', child: Text('Blocked')),
              ],
              selectedOptionBuilder: (context, value) => Text(value),
              onChanged: (v) {
                if (v != null) setState(() => _status = v);
              },
            ),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label, {bool required = false}) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        if (required)
          Text(
            ' *',
            style: TextStyle(color: AppTheme.dangerColor, fontSize: 13),
          ),
      ],
    );
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
