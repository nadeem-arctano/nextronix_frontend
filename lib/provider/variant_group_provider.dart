import 'package:flutter/foundation.dart';

import '../model/request/request.dart';
import '../model/response/response.dart';
import '../repository/nextronix_repository.dart';

/// Provider that owns the state for a single product's variant group, plus
/// the live "groupable products" list used by the picker on the variations
/// screen.
///
/// Lifecycle: a screen calls [loadGroup] (and optionally [loadGroupable])
/// when it opens, listens to [group], [groupable], [isLoading], [isSaving]
/// and [error], and invokes the action methods to mutate.
///
/// Backend rules (already enforced server-side, mirrored here for friendlier
/// errors):
///   • Same category only.
///   • Source products are never deleted — removing a parent dissolves the
///     whole group, removing a child detaches that one.
///   • A product can be in at most one group at a time.
class VariantGroupProvider extends ChangeNotifier {
  final NextronixRepository _repo = NextronixRepository();

  // ─── State ─────────────────────────────────────────────────────────────
  VariantGroup? _group;
  int? _anchorId;
  List<GroupableProduct> _groupable = const [];
  bool _isLoading = false;
  bool _isLoadingGroupable = false;
  bool _isSaving = false;
  String? _error;

  VariantGroup? get group => _group;
  int? get anchorId => _anchorId;
  List<GroupableProduct> get groupable => _groupable;
  bool get isLoading => _isLoading;
  bool get isLoadingGroupable => _isLoadingGroupable;
  bool get isSaving => _isSaving;
  String? get error => _error;

  bool get hasGroup => _group?.parent != null;
  int get childrenCount => _group?.children.length ?? 0;

  // ─── Group fetch ───────────────────────────────────────────────────────

  /// Loads `{parent, children}` for any product in the group. If the product
  /// is standalone, [group] becomes null and [hasGroup] returns false.
  Future<AlertErrorResponse?> loadGroup(int productId) async {
    _anchorId = productId;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final r = await _repo.getProductGroup(id: productId);
      _group = r.data;
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load variant group';
      notifyListeners();
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  /// Clears local state. Useful when leaving the variations screen.
  void clear() {
    _group = null;
    _anchorId = null;
    _groupable = const [];
    _error = null;
    notifyListeners();
  }

  // ─── Groupable picker source ───────────────────────────────────────────

  /// Loads standalone products in the same category — the eligibility list
  /// shown by the SKU picker. Children of any group are excluded server-side.
  Future<AlertErrorResponse?> loadGroupable({
    required int categoryId,
    int? excludeProductId,
    String? search,
  }) async {
    _isLoadingGroupable = true;
    notifyListeners();
    try {
      final r = await _repo.getGroupableProducts(
        categoryId: categoryId,
        excludeProductId: excludeProductId,
        search: search,
      );
      _groupable = r.data ?? const [];
      _isLoadingGroupable = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoadingGroupable = false;
      notifyListeners();
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  // ─── Mutations ─────────────────────────────────────────────────────────

  /// Creates a brand-new group from N standalone products.
  /// `optionsByProduct` keys are int product ids.
  Future<AlertErrorResponse?> createGroup({
    required int parentId,
    required List<int> childIds,
    required Map<int, VariantGroupOption> optionsByProduct,
  }) async {
    _isSaving = true;
    notifyListeners();
    try {
      final r = await _repo.createVariantGroup(
        parentId: parentId,
        childIds: childIds,
        optionsByProduct: optionsByProduct,
      );
      _group = r.data;
      _anchorId = parentId;
      _isSaving = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isSaving = false;
      notifyListeners();
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  /// Adds a single standalone product as a child of the existing group.
  Future<AlertErrorResponse?> addChild({
    required int anchorId,
    required int childId,
    String? color,
    String? size,
  }) async {
    _isSaving = true;
    notifyListeners();
    try {
      final r = await _repo.addToVariantGroup(
        anchorId: anchorId,
        childId: childId,
        color: color,
        size: size,
      );
      _group = r.data;
      _isSaving = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isSaving = false;
      notifyListeners();
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  /// Removes a product from its group.
  ///   • Child  → that child becomes standalone. If it was the LAST child,
  ///     the parent is auto-demoted by the server too and the group ceases
  ///     to exist.
  ///   • Parent → ENTIRE group dissolves (caller should confirm first).
  /// After the call we always re-fetch the group payload for the screen's
  /// anchor so the UI re-renders cleanly: a still-living group keeps
  /// rendering, a fully-dissolved group flips to the empty-state.
  Future<AlertErrorResponse?> removeMember({required int id}) async {
    _isSaving = true;
    notifyListeners();
    try {
      await _repo.removeFromVariantGroup(id: id);
      final anchor = _anchorId;
      if (anchor != null) {
        // Reload from the original anchor — even if the anchor itself was
        // removed, the server now returns null for it (standalone) and
        // `hasGroup` becomes false, which the variations screen renders as
        // "No variations yet".
        await loadGroup(anchor);
      } else {
        _group = null;
        _isSaving = false;
        notifyListeners();
      }
      return null;
    } catch (e) {
      _isSaving = false;
      notifyListeners();
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  /// Promotes a child to become the new parent of the same group. The old
  /// parent is demoted to a child. Other children re-link automatically.
  Future<AlertErrorResponse?> promoteToParent({required int id}) async {
    _isSaving = true;
    notifyListeners();
    try {
      final r = await _repo.promoteVariantToParent(id: id);
      _group = r.data;
      _anchorId = id;
      _isSaving = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isSaving = false;
      notifyListeners();
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  /// Updates the color/size labels of a single member without changing
  /// any other product fields.
  Future<AlertErrorResponse?> updateMemberOptions({
    required int id,
    String? color,
    String? size,
  }) async {
    _isSaving = true;
    notifyListeners();
    try {
      await _repo.updateVariantGroupOptions(id: id, color: color, size: size);
      // Reload to pick up the fresh labels.
      if (_anchorId != null) {
        await loadGroup(_anchorId!);
      } else {
        _isSaving = false;
        notifyListeners();
      }
      return null;
    } catch (e) {
      _isSaving = false;
      notifyListeners();
      return AlertErrorResponse.getErrorResponse(e);
    }
  }
}
