/// Reusable form validators.
///
/// Pass into TextFormField.validator. Each returns null when valid, or a
/// human-readable message when invalid. Compose with `.combine` for multi-rule
/// fields (`Validators.combine([Validators.required(), Validators.email()])`).
typedef Validator = String? Function(String? value);

class Validators {
  Validators._();

  static final RegExp _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static final RegExp _phoneRegex = RegExp(r'^[0-9+\-\s()]{6,}$');
  static final RegExp _gstRegex = RegExp(
    r'^\d{2}[A-Z]{5}\d{4}[A-Z][A-Z\d]Z[A-Z\d]$',
  );
  static final RegExp _panRegex = RegExp(r'^[A-Z]{5}\d{4}[A-Z]$');
  static final RegExp _pincodeRegex = RegExp(r'^\d{4,10}$');
  static final RegExp _ifscRegex = RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$');
  static final RegExp _hsnRegex = RegExp(r'^\d{4,8}$');
  static final RegExp _skuRegex = RegExp(r'^[A-Za-z0-9_\-]{2,40}$');

  static Validator required([String message = 'Required']) {
    return (v) => (v == null || v.trim().isEmpty) ? message : null;
  }

  static Validator minLength(int len, [String? message]) {
    return (v) {
      if (v == null) return null;
      return v.trim().length < len ? (message ?? 'Min $len characters') : null;
    };
  }

  static Validator maxLength(int len, [String? message]) {
    return (v) {
      if (v == null) return null;
      return v.trim().length > len ? (message ?? 'Max $len characters') : null;
    };
  }

  static Validator email([String message = 'Enter a valid email']) {
    return (v) {
      if (v == null || v.isEmpty) return null;
      return _emailRegex.hasMatch(v.trim()) ? null : message;
    };
  }

  static Validator phone([String message = 'Enter a valid phone']) {
    return (v) {
      if (v == null || v.isEmpty) return null;
      return _phoneRegex.hasMatch(v.trim()) ? null : message;
    };
  }

  static Validator gstNumber([String message = 'Invalid GST number']) {
    return (v) {
      if (v == null || v.isEmpty) return null;
      return _gstRegex.hasMatch(v.trim().toUpperCase()) ? null : message;
    };
  }

  static Validator pan([String message = 'Invalid PAN']) {
    return (v) {
      if (v == null || v.isEmpty) return null;
      return _panRegex.hasMatch(v.trim().toUpperCase()) ? null : message;
    };
  }

  static Validator pincode([String message = 'Invalid pincode']) {
    return (v) {
      if (v == null || v.isEmpty) return null;
      return _pincodeRegex.hasMatch(v.trim()) ? null : message;
    };
  }

  static Validator ifsc([String message = 'Invalid IFSC']) {
    return (v) {
      if (v == null || v.isEmpty) return null;
      return _ifscRegex.hasMatch(v.trim().toUpperCase()) ? null : message;
    };
  }

  static Validator hsnCode([String message = 'Invalid HSN code']) {
    return (v) {
      if (v == null || v.isEmpty) return null;
      return _hsnRegex.hasMatch(v.trim()) ? null : message;
    };
  }

  static Validator sku([String message = 'Invalid SKU (A-Z, 0-9, _ -)']) {
    return (v) {
      if (v == null || v.isEmpty) return null;
      return _skuRegex.hasMatch(v.trim()) ? null : message;
    };
  }

  static Validator url([String message = 'Enter a valid URL']) {
    return (v) {
      if (v == null || v.isEmpty) return null;
      final s = v.trim();
      final parsed = Uri.tryParse(s);
      if (parsed == null) return message;
      if (!parsed.hasScheme ||
          (!parsed.isScheme('http') && !parsed.isScheme('https'))) {
        return message;
      }
      if (parsed.host.isEmpty) return message;
      return null;
    };
  }

  static Validator number({
    bool required = false,
    num? min,
    num? max,
    String? message,
  }) {
    return (v) {
      if (v == null || v.trim().isEmpty) return required ? 'Required' : null;
      final n = num.tryParse(v.trim());
      if (n == null) return message ?? 'Enter a number';
      if (min != null && n < min) return message ?? 'Minimum is $min';
      if (max != null && n > max) return message ?? 'Maximum is $max';
      return null;
    };
  }

  static Validator integer({
    bool required = false,
    int? min,
    int? max,
    String? message,
  }) {
    return (v) {
      if (v == null || v.trim().isEmpty) return required ? 'Required' : null;
      final n = int.tryParse(v.trim());
      if (n == null) return message ?? 'Enter an integer';
      if (min != null && n < min) return message ?? 'Minimum is $min';
      if (max != null && n > max) return message ?? 'Maximum is $max';
      return null;
    };
  }

  static Validator password({int min = 6, String? message}) {
    return (v) {
      if (v == null || v.isEmpty) return 'Password required';
      if (v.length < min) return message ?? 'Min $min characters';
      return null;
    };
  }

  static Validator match(
    String? Function() other, {
    String message = 'Values do not match',
  }) {
    return (v) {
      if (v == null) return null;
      return v == other() ? null : message;
    };
  }

  /// Compose multiple validators — returns the first non-null message.
  static Validator combine(List<Validator> rules) {
    return (v) {
      for (final r in rules) {
        final msg = r(v);
        if (msg != null) return msg;
      }
      return null;
    };
  }
}
