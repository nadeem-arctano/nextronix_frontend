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
import '../../../model/request/request.dart';
import '../../../provider/category_provider.dart';
import '../../../provider/color_master_provider.dart';
import '../../../provider/material_master_provider.dart';
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
  bool _isSavingDraft = false;
  Set<int> _stepsWithErrors = {};

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
      context.read<ColorMasterProvider>().loadColors();
      context.read<MaterialMasterProvider>().loadMaterials();
    });
  }

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  // ─── Step navigation ─────────────────────────────────────────────────────
  /// Jump to any step. The stepper is fully free-roam — past, current, or
  /// future steps all switch instantly. Validation only runs when the user
  /// presses Next or Submit so red errors don't surface from poking around.
  void _go(int idx) {
    setState(() {
      _step = AddProductStep.values[idx];
      // Clear error for this step when user visits it
      _stepsWithErrors = Set.from(_stepsWithErrors)..remove(idx);
    });
  }

  void _next() {
    // Just move to next step — no validation on continue
    final i = _step.index;
    if (i < AddProductStep.values.length - 1) _go(i + 1);
  }

  void _cancel() {
    context.go('/admin/products');
  }

  /// Save the current form state as a draft. The product is created with
  /// `status='draft'` regardless of which step the user is on. Drafts only
  /// require name + category — pricing, stock, and other soft fields can
  /// be missing and are filled in later. Empty MRP/selling are persisted
  /// as 0 so the row passes server validation.
  Future<void> _saveDraft() async {
    if (_form.name.text.trim().isEmpty || _form.categoryId == null) {
      ToastService.warning(
        context,
        'Add at least a product name and category before saving as draft.',
      );
      _go(AddProductStep.info.index);
      return;
    }

    setState(() => _isSavingDraft = true);
    final originalStatus = _form.status;
    _form.status = 'draft';
    final err = await _persist();
    if (!mounted) return;
    setState(() {
      _isSavingDraft = false;
      _form.status = originalStatus;
    });
    if (err == null) {
      ToastService.success(context, 'Draft saved');
      context.go('/admin/products');
    }
  }

  // ─── Submit ──────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    // Validate ALL steps and collect error indices
    final errors = <int>{};

    // Step 0: Info
    final infoValid =
        (_form.infoKey.currentState?.validate() ?? false) &&
        _form.categoryId != null;
    if (!infoValid) errors.add(0);

    // Step 2: Pricing
    final pricingValid = _form.pricingKey.currentState?.validate() ?? false;
    if (!pricingValid) errors.add(2);

    setState(() => _stepsWithErrors = errors);

    if (errors.isNotEmpty) {
      // Stay on current step, just show errors on stepper
      return;
    }

    setState(() => _isSubmitting = true);
    final err = await _persist();
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    if (err == null) {
      ToastService.success(context, 'Product created successfully');
      context.go('/admin/products');
    }
  }

  /// Shared persistence path used by both `Submit` and `Save as draft`.
  /// Returns `null` on success, otherwise the AlertErrorResponse.
  Future<dynamic> _persist() async {
    // Clear any previous field errors before a new submission.
    _form.clearAllFieldErrors();

    final ordered = _form.images.orderedForSubmit();
    final request = ProductRequest(
      name: _form.name.text.trim(),
      categoryId: _form.categoryId!,
      hsnId: _form.hsnId,
      shortDescription: _form.fullDesc.text.trim(),
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
      colorId: _form.colorId,
      materialTypeId: _form.materialTypeId,
      warranty: _form.buildWarrantyBlob(),
      status: _form.status,
      isFeatured: _form.isFeatured,
      thumbnailFile: ordered.isNotEmpty ? ordered.first.file : null,
      galleryFiles: ordered.length > 1
          ? ordered.skip(1).map((p) => p.file).toList()
          : const [],
    );

    final formData = await request.toFormData();
    if (!mounted) return null;
    final result = await context
        .read<ProductProvider>()
        .createProductReturningId(formData: formData);

    if (result.error != null) {
      if (mounted) {
        final err = result.error!;
        // Surface master validation errors inline on the corresponding field.
        if (err.isMasterValidationError && err.field != null) {
          _form.setFieldError(err.field!, err.alertMessage);
          final targetStep = AddProductForm.stepForField(err.field!);
          if (targetStep != null) {
            setState(() => _step = targetStep);
          } else {
            setState(() {});
          }
        } else {
          ToastService.fromError(context, err);
        }
      }
      return result.error;
    }
    return null;
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
          // Stepper is fully free-roam — every chip is tappable so users
          // can hop between sections and review/edit as they like.
          WizardStepper(
            steps: _stepperSteps,
            currentIndex: _step.index,
            onTap: _go,
            errorSteps: _stepsWithErrors,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildStepBody(),
                      // Action bar lives inline at the end of the scroll
                      // content so it scrolls with the page instead of
                      // floating over it.
                      WizardActionBar(
                        onCancel: _cancel,
                        onSaveDraft: _saveDraft,
                        onNext: _next,
                        onSubmit: _submit,
                        isLast: isLast,
                        isSubmitting: _isSubmitting,
                        isSavingDraft: _isSavingDraft,
                        submitLabel: 'Submit',
                        submitIcon: LucideIcons.check,
                        nextStepLabel: isLast
                            ? null
                            : _stepperSteps[_step.index + 1].title,
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
