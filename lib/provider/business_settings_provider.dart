import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../model/response/response.dart';
import '../repository/nextronix_repository.dart';

class BusinessSettingsProvider extends ChangeNotifier {
  BusinessSettings? _settings;
  bool _isLoading = false;
  bool _isSaving = false;
  bool _isUploadingLogo = false;
  bool _isUploadingFavicon = false;
  String? _error;

  // Local form values for unsaved-changes detection
  final Map<String, String> _formValues = {};
  final Map<String, String> _initialValues = {};

  BusinessSettings? get settings => _settings;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get isUploadingLogo => _isUploadingLogo;
  bool get isUploadingFavicon => _isUploadingFavicon;
  String? get error => _error;

  bool get hasUnsavedChanges {
    if (_formValues.isEmpty) return false;
    for (final entry in _formValues.entries) {
      final initial = _initialValues[entry.key] ?? '';
      if (entry.value != initial) return true;
    }
    return false;
  }

  String getValue(String key) => _formValues[key] ?? '';

  void setValue(String key, String value) {
    _formValues[key] = value;
    notifyListeners();
  }

  Future<AlertErrorResponse?> loadSettings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await NextronixRepository().getBusinessSettings();
      _settings = response.data;
      _hydrateForm(_settings);
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load settings';
      notifyListeners();
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  void _hydrateForm(BusinessSettings? s) {
    _formValues.clear();
    _initialValues.clear();
    if (s == null) return;

    final map = <String, String?>{
      'businessName': s.businessName,
      'legalBusinessName': s.legalBusinessName,
      'gstNumber': s.gstNumber,
      'panNumber': s.panNumber,
      'websiteUrl': s.websiteUrl,
      'businessEmail': s.businessEmail,
      'businessPhone': s.businessPhone,
      'supportEmail': s.supportEmail,
      'supportPhone': s.supportPhone,
      'addressLine1': s.addressLine1,
      'addressLine2': s.addressLine2,
      'city': s.city,
      'state': s.state,
      'country': s.country,
      'pincode': s.pincode,
      'accountHolderName': s.accountHolderName,
      'bankName': s.bankName,
      'ifscCode': s.ifscCode,
      'branchName': s.branchName,
      'upiId': s.upiId,
      'razorpayKey': s.razorpayKey,
      'stripePublicKey': s.stripePublicKey,
      'invoicePrefix': s.invoicePrefix,
      'invoiceStartNumber': s.invoiceStartNumber?.toString(),
      'gstPercentage': s.gstPercentage?.toString(),
      'invoiceFooter': s.invoiceFooter,
      'invoiceTerms': s.invoiceTerms,
      'instagramUrl': s.instagramUrl,
      'facebookUrl': s.facebookUrl,
      'youtubeUrl': s.youtubeUrl,
      'twitterUrl': s.twitterUrl,
    };

    map.forEach((k, v) {
      _formValues[k] = v ?? '';
      _initialValues[k] = v ?? '';
    });

    // Sensitive fields default to empty (placeholder is shown if `Set` is true)
    _formValues['accountNumber'] = '';
    _initialValues['accountNumber'] = '';
    _formValues['razorpaySecret'] = '';
    _initialValues['razorpaySecret'] = '';
    _formValues['stripeSecretKey'] = '';
    _initialValues['stripeSecretKey'] = '';
  }

  Future<AlertErrorResponse?> saveSettings() async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      // Build only changed values + always-allowed sensitive fields
      final body = <String, dynamic>{};
      _formValues.forEach((k, v) {
        // Send sensitive fields only if user typed something
        if (k == 'accountNumber' ||
            k == 'razorpaySecret' ||
            k == 'stripeSecretKey') {
          if (v.isNotEmpty) body[k] = v;
        } else {
          body[k] = v;
        }
      });

      // Cast numeric fields
      if (body['invoiceStartNumber'] != null &&
          body['invoiceStartNumber'] is String) {
        final s = body['invoiceStartNumber'] as String;
        body['invoiceStartNumber'] = s.isEmpty ? null : int.tryParse(s);
      }
      if (body['gstPercentage'] != null && body['gstPercentage'] is String) {
        final s = body['gstPercentage'] as String;
        body['gstPercentage'] = s.isEmpty ? null : double.tryParse(s);
      }

      final response = await NextronixRepository().updateBusinessSettings(
        body: body,
      );
      _settings = response.data;
      _hydrateForm(_settings);
      _isSaving = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isSaving = false;
      _error = 'Failed to save settings';
      notifyListeners();
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

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
      _settings = response.data;
      _isUploadingLogo = false;
      notifyListeners();
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
      _settings = response.data;
      _isUploadingFavicon = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isUploadingFavicon = false;
      notifyListeners();
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  void resetChanges() {
    _formValues.clear();
    _formValues.addAll(_initialValues);
    notifyListeners();
  }
}
