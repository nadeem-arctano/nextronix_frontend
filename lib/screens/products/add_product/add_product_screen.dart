// Add Product wizard — thin shell.
//
// Owns nothing besides which step is currently visible and the shared
// `AddProductForm` instance. Each step is a separate widget under
// `steps/` and the reusable form pieces live in `widgets/forms/`.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/services/toast_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../model/request/request.dart';
import '../../../provider/category_provider.dart';
import '../../../provider/product_provider.dart';
import '../../../widgets/forms/forms.dart';
import 'controller/add_product_form.dart';
import 'steps/step_images.dart';
import 'steps/step_info.dart';
import 'steps/step_pricing.dart';
import 'steps/step_review.dart';
import 'steps/step_specs.dart';
import 'steps/step_warranty.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _form = AddProductForm();
  AddProductStep _step = AddProductStep.info;
  bool _isSubmitting = false;

  static const _stepperSteps = [
    WizardStep(
      title: 'Product info',
      subtitle: 'Name, category, descriptions',
      icon: LucideIcons.info,
    ),
    WizardStep(
      title: 'Images',
      subtitle: 'Cover photo + gallery',
      icon: LucideIcons.images,
    ),
    WizardStep(
      title: 'Pricing & stock',
      subtitle: 'Price, GST, inventory',
      icon: LucideIcons.indianRupee,
    ),
    WizardStep(
      title: 'Specifications',
      subtitle: 'Material, weight, origin',
      icon: LucideIcons.boxes,
    ),
    WizardStep(
      title: 'Warranty',
      subtitle: 'Coverage and service',
      icon: LucideIcons.shieldCheck,
    ),
    WizardStep(
      title: 'Review & publish',
      subtitle: 'Final check',
      icon: LucideIcons.checkCheck,
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProductProvider>().loadHsnCodes();
      context.read<CategoryProvider>().loadCategories();
    });
    // The stepper's lock state depends on whether key fields are filled.
    // Listening here means future-step chips light up the moment the user
    // finishes typing them, without waiting for a Next press.
    _form.name.addListener(_onGateInputChanged);
    _form.mrp.addListener(_onGateInputChanged);
    _form.selling.addListener(_onGateInputChanged);
  }

  void _onGateInputChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _form.name.removeListener(_onGateInputChanged);
    _form.mrp.removeListener(_onGateInputChanged);
    _form.selling.removeListener(_onGateInputChanged);
    _form.dispose();
    super.dispose();
  }

  // ─── Step navigation ─────────────────────────────────────────────────────
  void _go(int idx) {
    setState(() => _step = AddProductStep.values[idx]);
  }

  /// Decide whether the user can jump from `_step` to `targetIdx` directly
  /// via the top stepper.
  ///
  /// Rules:
  ///   - Backward (or staying put) is always allowed — already-filled data
  ///     stays intact in `AddProductForm` so they can review/edit anything.
  ///   - Forward jumps validate every required step in between, just like
  ///     pressing Next that many times. If any step in the chain fails its
  ///     validation, we land the user on the first failing step.
  void _onStepperTap(int targetIdx) {
    final currentIdx = _step.index;
    if (targetIdx <= currentIdx) {
      _go(targetIdx);
      return;
    }
    // Forward jump: walk every step from current → targetIdx-1 and make
    // sure each one's validation passes before advancing past it.
    for (var i = currentIdx; i < targetIdx; i++) {
      _step = AddProductStep.values[i];
      if (!_validateCurrent()) {
        if (_step == AddProductStep.info && _form.categoryId == null) {
          ToastService.warning(context, 'Pick a category to continue');
        } else {
          ToastService.warning(
            context,
            'Complete "${_step.title}" before moving forward',
          );
        }
        setState(() {}); // surface the failing step in the UI
        return;
      }
    }
    setState(() => _step = AddProductStep.values[targetIdx]);
  }

  /// Used by the stepper to fade and lock future steps the user hasn't
  /// earned yet. Only checks "static" form data (no validators run here)
  /// because we don't want to show red errors on fields the user hasn't
  /// touched. The Next button still does the strict validation.
  bool _isStepUnlocked(int targetIdx) {
    if (targetIdx <= _step.index) return true; // past + active always open
    // Walk the steps before `targetIdx` and require their minimum data.
    for (var i = 0; i < targetIdx; i++) {
      final s = AddProductStep.values[i];
      switch (s) {
        case AddProductStep.info:
          if (_form.name.text.trim().isEmpty || _form.categoryId == null) {
            return false;
          }
          break;
        case AddProductStep.pricing:
          final mrp = double.tryParse(_form.mrp.text);
          final selling = double.tryParse(_form.selling.text);
          if (mrp == null || mrp <= 0 || selling == null || selling <= 0) {
            return false;
          }
          break;
        case AddProductStep.images:
        case AddProductStep.specs:
        case AddProductStep.warranty:
        case AddProductStep.review:
          break;
      }
    }
    return true;
  }

  bool _validateCurrent() {
    switch (_step) {
      case AddProductStep.info:
        return (_form.infoKey.currentState?.validate() ?? false) &&
            _form.categoryId != null;
      case AddProductStep.pricing:
        return _form.pricingKey.currentState?.validate() ?? false;
      case AddProductStep.images:
      case AddProductStep.specs:
      case AddProductStep.warranty:
      case AddProductStep.review:
        return true;
    }
  }

  void _next() {
    if (!_validateCurrent()) {
      if (_step == AddProductStep.info && _form.categoryId == null) {
        ToastService.warning(context, 'Pick a category to continue');
      }
      return;
    }
    final i = _step.index;
    if (i < AddProductStep.values.length - 1) _go(i + 1);
  }

  void _back() {
    final i = _step.index;
    if (i > 0) _go(i - 1);
  }

  // ─── Submit ──────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    if (_form.categoryId == null) {
      ToastService.warning(context, 'Category is required');
      _go(AddProductStep.info.index);
      return;
    }
    if (!(_form.pricingKey.currentState?.validate() ?? false)) {
      _go(AddProductStep.pricing.index);
      return;
    }

    setState(() => _isSubmitting = true);

    final ordered = _form.images.orderedForSubmit();
    final request = ProductRequest(
      name: _form.name.text.trim(),
      categoryId: _form.categoryId!,
      hsnId: _form.hsnId,
      shortDescription: _form.shortDesc.text.trim(),
      fullDescription: _form.buildFullDescription(),
      sku: _form.sku.text.trim(),
      barcode: _form.barcode.text.trim(),
      tags: _form.tags.text.trim(),
      mrpPrice: double.tryParse(_form.mrp.text) ?? 0,
      sellingPrice: double.tryParse(_form.selling.text) ?? 0,
      gstPercent: double.tryParse(_form.gst.text),
      stockQuantity: int.tryParse(_form.stock.text),
      minStockAlert: int.tryParse(_form.minStock.text),
      weight: _form.weight.text.trim(),
      dimensions: _form.dimensions.text.trim(),
      color: _form.color.text.trim(),
      material: _form.material.text.trim(),
      warranty: _form.buildWarrantyBlob(),
      status: _form.status,
      isFeatured: _form.isFeatured,
      thumbnailFile: ordered.isNotEmpty ? ordered.first.file : null,
      galleryFiles: ordered.length > 1
          ? ordered.skip(1).map((p) => p.file).toList()
          : const [],
    );

    final formData = await request.toFormData();
    if (!mounted) return;
    final result = await context.read<ProductProvider>().createProduct(
      formData: formData,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);
    if (result == null) {
      ToastService.success(context, 'Product created successfully');
      context.go('/admin/products');
    } else {
      ToastService.fromError(context, result);
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final isLast = _step == AddProductStep.values.last;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Column(
        children: [
          _buildTopBar(theme),
          WizardStepper(
            steps: _stepperSteps,
            currentIndex: _step.index,
            onTap: _onStepperTap,
            canTap: _isStepUnlocked,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: _buildStepBody(),
                ),
              ),
            ),
          ),
          WizardActionBar(
            currentIndex: _step.index,
            totalSteps: AddProductStep.values.length,
            onBack: _step.index == 0 ? null : _back,
            onNext: _next,
            onSubmit: _submit,
            isLast: isLast,
            isSubmitting: _isSubmitting,
            submitLabel: 'Create product',
            submitIcon: LucideIcons.check,
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(ShadThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        border: Border(bottom: BorderSide(color: theme.colorScheme.border)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(LucideIcons.arrowLeft, size: 18),
            tooltip: 'Back to products',
            onPressed: () => context.go('/admin/products'),
          ),
          const SizedBox(width: 4),
          Text(
            'Add new product',
            style: theme.textTheme.h3.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.brand.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'STEP ${_step.index + 1} / ${AddProductStep.values.length}',
              style: TextStyle(
                color: AppTheme.brand,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
          ),
          const Spacer(),
          ShadButton.outline(
            size: ShadButtonSize.sm,
            onPressed: () => context.go('/admin/products'),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildStepBody() {
    switch (_step) {
      case AddProductStep.info:
        return StepInfo(form: _form);
      case AddProductStep.images:
        return StepImages(form: _form);
      case AddProductStep.pricing:
        return StepPricing(form: _form);
      case AddProductStep.specs:
        return StepSpecs(form: _form);
      case AddProductStep.warranty:
        return StepWarranty(form: _form);
      case AddProductStep.review:
        return StepReview(form: _form);
    }
  }
}
