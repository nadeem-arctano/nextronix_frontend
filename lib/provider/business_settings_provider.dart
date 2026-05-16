import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../model/response/response.dart';
import '../repository/nextronix_repository.dart';

/// Sections supported by the per-section APIs.
class SettingsSections {
  static const String businessInfo = 'business-info';
  static const String contact = 'contact';
  static const String address = 'address';
  static const String branding = 'branding';
  static const String bank = 'bank';
  static const String payment = 'payment';
  static const String invoice = 'invoice';
  static const String social = 'social';

  static const List<String> all = [
    businessInfo,
    contact,
    address,
    branding,
    bank,
    payment,
    invoice,
    social,
  ];
}

/// Provider managing per-section business settings.
/// Each section has its own load/save lifecycle and form values.
class BusinessSettingsProvider extends ChangeNotifier {
  // Hub data (used for sidebar previews)
  BusinessSettings? _hubSettings;
  bool _isHubLoading = false;

  // Per-section state
  final Map<String, BusinessSettings> _sectionData = {};
  final Map<String, bool> _sectionLoading = {};
  final Map<String, bool> _sectionSaving = {};
  final Map<String, String?> _sectionError = {};

  // Per-section form values + initial snapshots for unsaved-changes detection
  final Map<String, Map<String, String>> _formValues = {};
  final Map<String, Map<String, String>> _initialValues = {};

  // Branding upload state
  bool _isUploadingLogo = false;
  bool _isUploadingFavicon = false;

  // ─── Hub getters ────────────────────────────────────────────────────────────
  BusinessSettings? get hubSettings => _hubSettings;
  bool get isHubLoading => _isHubLoading;

  // ─── Section getters ────────────────────────────────────────────────────────
  BusinessSettings? sectionData(String section) => _sectionData[section];
  bool isSectionLoading(String section) => _sectionLoading[section] ?? false;
  bool isSectionSaving(String section) => _sectionSaving[section] ?? false;
  String? sectionError(String section) => _sectionError[section];

  bool get isUploadingLogo => _isUploadingLogo;
  bool get isUploadingFavicon => _isUploadingFavicon;

  // ─── Form helpers ───────────────────────────────────────────────────────────
  String getValue(String section, String key) {
    return _formValues[section]?[key] ?? '';
  }

  void setValue(String section, String key, String value) {
    _formValues.putIfAbsent(section, () => {});
    _formValues[section]![key] = value;
    notifyListeners();
  }

  bool hasUnsavedChanges(String section) {
    final form = _formValues[section];
    final initial = _initialValues[section];
    if (form == null || initial == null) return false;
    for (final entry in form.entries) {
      final init = initial[entry.key] ?? '';
      if (entry.value != init) return true;
    }
    return false;
  }

  void resetChanges(String section) {
    final initial = _initialValues[section];
    if (initial == null) return;
    _formValues[section] = Map<String, String>.from(initial);
    notifyListeners();
  }

  // ─── Hub: load full settings (used on settings home screen) ─────────────────
  Future<AlertErrorResponse?> loadHub() async {
    _isHubLoading = true;
    notifyListeners();
    try {
      final response = await NextronixRepository().getBusinessSettings();
      _hubSettings = response.data;
      _isHubLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isHubLoading = false;
      notifyListeners();
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  // ─── Section: load ──────────────────────────────────────────────────────────
  Future<AlertErrorResponse?> loadSection(String section) async {
    _sectionLoading[section] = true;
    _sectionError[section] = null;
    notifyListeners();

    try {
      final response = await NextronixRepository().getSettingsSection(section);
      _sectionData[section] = response.data ?? BusinessSettings();
      _hydrateForm(section, _sectionData[section]!);
      _sectionLoading[section] = false;
      notifyListeners();
      return null;
    } catch (e) {
      _sectionLoading[section] = false;
      _sectionError[section] = 'Failed to load section';
      notifyListeners();
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  void _hydrateForm(String section, BusinessSettings s) {
    final values = <String, String>{};

    switch (section) {
      case SettingsSections.businessInfo:
        values['businessName'] = s.businessName ?? '';
        values['legalBusinessName'] = s.legalBusinessName ?? '';
        values['gstNumber'] = s.gstNumber ?? '';
        values['panNumber'] = s.panNumber ?? '';
        values['websiteUrl'] = s.websiteUrl ?? '';
        break;
      case SettingsSections.contact:
        values['businessEmail'] = s.businessEmail ?? '';
        values['businessPhone'] = s.businessPhone ?? '';
        values['supportEmail'] = s.supportEmail ?? '';
        values['supportPhone'] = s.supportPhone ?? '';
        break;
      case SettingsSections.address:
        values['addressLine1'] = s.addressLine1 ?? '';
        values['addressLine2'] = s.addressLine2 ?? '';
        values['city'] = s.city ?? '';
        values['state'] = s.state ?? '';
        values['country'] = s.country ?? '';
        values['pincode'] = s.pincode ?? '';
        break;
      case SettingsSections.bank:
        values['accountHolderName'] = s.accountHolderName ?? '';
        values['bankName'] = s.bankName ?? '';
        values['ifscCode'] = s.ifscCode ?? '';
        values['branchName'] = s.branchName ?? '';
        values['accountNumber'] =
            ''; // sensitive: always blank, masked preview shown
        break;
      case SettingsSections.payment:
        values['upiId'] = s.upiId ?? '';
        values['razorpayKey'] = s.razorpayKey ?? '';
        values['stripePublicKey'] = s.stripePublicKey ?? '';
        values['razorpaySecret'] = '';
        values['stripeSecretKey'] = '';
        break;
      case SettingsSections.invoice:
        values['invoicePrefix'] = s.invoicePrefix ?? '';
        values['invoiceStartNumber'] = s.invoiceStartNumber?.toString() ?? '';
        values['gstPercentage'] = s.gstPercentage?.toString() ?? '';
        values['invoiceFooter'] = s.invoiceFooter ?? '';
        values['invoiceTerms'] = s.invoiceTerms ?? '';
        break;
      case SettingsSections.social:
        values['instagramUrl'] = s.instagramUrl ?? '';
        values['facebookUrl'] = s.facebookUrl ?? '';
        values['youtubeUrl'] = s.youtubeUrl ?? '';
        values['twitterUrl'] = s.twitterUrl ?? '';
        break;
    }

    _formValues[section] = Map.from(values);
    _initialValues[section] = Map.from(values);
  }

  // ─── Section: save ──────────────────────────────────────────────────────────
  Future<AlertErrorResponse?> saveSection(String section) async {
    _sectionSaving[section] = true;
    notifyListeners();

    try {
      final form = _formValues[section] ?? {};
      final body = <String, String>{};

      form.forEach((k, v) {
        // Skip empty sensitive fields so server keeps existing value
        if ((k == 'accountNumber' ||
                k == 'razorpaySecret' ||
                k == 'stripeSecretKey') &&
            v.isEmpty) {
          return;
        }
        body[k] = v;
      });

      // Repository converts the form map into the proper section request model
      final response = await NextronixRepository().updateSettingsSection(
        section: section,
        body: body,
      );

      _sectionData[section] = response.data ?? BusinessSettings();
      _hydrateForm(section, _sectionData[section]!);
      _sectionSaving[section] = false;
      notifyListeners();

      // Refresh hub preview in background
      loadHub();
      return null;
    } catch (e) {
      _sectionSaving[section] = false;
      notifyListeners();
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  // ─── Branding uploads ───────────────────────────────────────────────────────
  Future<AlertErrorResponse?> uploadLogo(
    Uint8List bytes,
    String filename,
  ) async {
    _isUploadingLogo = true;
    notifyListeners();
    try {
      final file = MultipartFile.fromBytes(bytes, filename: filename);
      final response = await NextronixRepository().uploadBusinessLogo(
        file: file,
      );
      _sectionData[SettingsSections.branding] =
          response.data ?? BusinessSettings();
      _isUploadingLogo = false;
      notifyListeners();
      loadHub();
      return null;
    } catch (e) {
      _isUploadingLogo = false;
      notifyListeners();
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  Future<AlertErrorResponse?> uploadFavicon(
    Uint8List bytes,
    String filename,
  ) async {
    _isUploadingFavicon = true;
    notifyListeners();
    try {
      final file = MultipartFile.fromBytes(bytes, filename: filename);
      final response = await NextronixRepository().uploadBusinessFavicon(
        file: file,
      );
      _sectionData[SettingsSections.branding] =
          response.data ?? BusinessSettings();
      _isUploadingFavicon = false;
      notifyListeners();
      loadHub();
      return null;
    } catch (e) {
      _isUploadingFavicon = false;
      notifyListeners();
      return AlertErrorResponse.getErrorResponse(e);
    }
  }
}
