import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'app_theme.dart';

/// Compiles a themeConfig JSON map into [ShadThemeData] instances.
///
/// Falls back to [AppTheme] baselines for any missing or malformed token.
/// Never throws — always returns valid theme data.
class DynamicThemeBuilder {
  DynamicThemeBuilder._();

  /// The 14 supported color tokens.
  static const List<String> _colorTokens = [
    'primary',
    'secondary',
    'background',
    'surface',
    'border',
    'textPrimary',
    'textSecondary',
    'textMuted',
    'success',
    'warning',
    'danger',
    'info',
    'sidebarBg',
    'sidebarActive',
  ];

  /// Compiles [themeConfig] into light and dark [ShadThemeData] instances
  /// plus a [normalizedConfig] containing the successfully parsed values.
  static ({
    ShadThemeData light,
    ShadThemeData dark,
    Map<String, dynamic> normalizedConfig,
  })
  compile(Map<String, dynamic>? themeConfig) {
    if (themeConfig == null || themeConfig.isEmpty) {
      return (
        light: AppTheme.lightTheme,
        dark: AppTheme.darkTheme,
        normalizedConfig: <String, dynamic>{},
      );
    }

    final normalized = <String, dynamic>{};

    // 1. Parse colors with per-token fallback
    final colors = _parseColors(themeConfig['colors'], normalized);

    // 2. Parse typography with fallback
    final typography = _parseTypography(themeConfig['typography'], normalized);

    // 3. Parse layout tokens
    final layout = _parseLayout(themeConfig['layout'], normalized);

    // 4. Parse dashboard, productPage, sidebar (pass-through)
    _parsePassthrough(themeConfig, normalized);

    // 5. Build light theme extending AppTheme.lightTheme
    final light = _buildTheme(
      base: AppTheme.lightTheme,
      brightness: Brightness.light,
      colors: colors,
      typography: typography,
      layout: layout,
    );

    // 6. Build dark theme extending AppTheme.darkTheme
    final dark = _buildTheme(
      base: AppTheme.darkTheme,
      brightness: Brightness.dark,
      colors: colors,
      typography: typography,
      layout: layout,
    );

    return (light: light, dark: dark, normalizedConfig: normalized);
  }

  // ─── Color Parsing ──────────────────────────────────────────────────────

  static Map<String, Color> _parseColors(
    dynamic colorsRaw,
    Map<String, dynamic> normalized,
  ) {
    final parsed = <String, Color>{};
    if (colorsRaw is! Map<String, dynamic>) return parsed;

    final normalizedColors = <String, String>{};

    for (final token in _colorTokens) {
      final hex = colorsRaw[token];
      if (hex is! String) continue;
      final color = _parseHex(hex);
      if (color != null) {
        parsed[token] = color;
        normalizedColors[token] = hex;
      }
    }

    if (normalizedColors.isNotEmpty) {
      normalized['colors'] = normalizedColors;
    }

    return parsed;
  }

  /// Parses a hex color string of the form `#RRGGBB` or `#AARRGGBB`.
  /// Returns null for any malformed input.
  static Color? _parseHex(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    final clean = hex.replaceFirst('#', '');
    try {
      if (clean.length == 6) {
        return Color(int.parse('FF$clean', radix: 16));
      }
      if (clean.length == 8) {
        return Color(int.parse(clean, radix: 16));
      }
    } catch (_) {
      // Malformed hex → fallback
    }
    return null;
  }

  // ─── Typography Parsing ─────────────────────────────────────────────────

  static _TypographyResult _parseTypography(
    dynamic typographyRaw,
    Map<String, dynamic> normalized,
  ) {
    TextStyle Function({TextStyle? textStyle})? fontBuilder;
    double? baseFontSize;

    if (typographyRaw is! Map<String, dynamic>) {
      return _TypographyResult(fontBuilder: null, baseFontSize: null);
    }

    final normalizedTypography = <String, dynamic>{};

    // fontFamily → GoogleFonts lookup, fallback to Poppins
    final fontFamily = typographyRaw['fontFamily'];
    if (fontFamily is String && fontFamily.isNotEmpty) {
      fontBuilder = _resolveGoogleFont(fontFamily);
      if (fontBuilder != null) {
        normalizedTypography['fontFamily'] = fontFamily;
      }
    }

    // baseFontSize → clamp 8.0 to 32.0
    baseFontSize = _clampFontSize(typographyRaw['baseFontSize']);
    if (baseFontSize != null) {
      normalizedTypography['baseFontSize'] = baseFontSize;
    }

    if (normalizedTypography.isNotEmpty) {
      normalized['typography'] = normalizedTypography;
    }

    return _TypographyResult(
      fontBuilder: fontBuilder,
      baseFontSize: baseFontSize,
    );
  }

  /// Resolves a Google Font by family name.
  /// Returns null if the font cannot be resolved (fallback to baseline).
  static TextStyle Function({TextStyle? textStyle})? _resolveGoogleFont(
    String fontFamily,
  ) {
    try {
      // Attempt to resolve the font — GoogleFonts.getFont throws if unknown
      GoogleFonts.getFont(fontFamily);
      return ({TextStyle? textStyle}) =>
          GoogleFonts.getFont(fontFamily, textStyle: textStyle);
    } catch (_) {
      // Unknown font → fallback to Poppins (the baseline)
      return null;
    }
  }

  /// Clamps font size to [8.0, 32.0]. Returns null if outside range or not a number.
  static double? _clampFontSize(dynamic value) {
    if (value is! num) return null;
    final d = value.toDouble();
    if (d < 8.0 || d > 32.0) return null;
    return d;
  }

  // ─── Layout Parsing ─────────────────────────────────────────────────────

  static _LayoutResult _parseLayout(
    dynamic layoutRaw,
    Map<String, dynamic> normalized,
  ) {
    String? density;
    double? borderRadius;

    if (layoutRaw is! Map<String, dynamic>) {
      return _LayoutResult(density: null, borderRadius: null);
    }

    final normalizedLayout = <String, dynamic>{};

    // density: compact / comfortable / spacious
    final densityValue = layoutRaw['density'];
    if (densityValue is String &&
        const ['compact', 'comfortable', 'spacious'].contains(densityValue)) {
      density = densityValue;
      normalizedLayout['density'] = density;
    }

    // borderRadius: positive number
    final radiusValue = layoutRaw['borderRadius'];
    if (radiusValue is num && radiusValue > 0) {
      borderRadius = radiusValue.toDouble();
      normalizedLayout['borderRadius'] = borderRadius;
    }

    // Pass through other layout tokens (dashboard, productPage, sidebar sub-keys)
    for (final key in layoutRaw.keys) {
      if (key != 'density' && key != 'borderRadius') {
        // Skip unknown layout sub-keys to normalized but don't break
      }
    }

    if (normalizedLayout.isNotEmpty) {
      normalized['layout'] = normalizedLayout;
    }

    return _LayoutResult(density: density, borderRadius: borderRadius);
  }

  // ─── Pass-through Section Tokens ────────────────────────────────────────

  static void _parsePassthrough(
    Map<String, dynamic> themeConfig,
    Map<String, dynamic> normalized,
  ) {
    // Pass through dashboard, productPage, sidebar as-is if they are maps
    for (final key in const ['dashboard', 'productPage', 'sidebar']) {
      final value = themeConfig[key];
      if (value is Map<String, dynamic> && value.isNotEmpty) {
        normalized[key] = Map<String, dynamic>.from(value);
      }
    }
  }

  // ─── Theme Building ─────────────────────────────────────────────────────

  static ShadThemeData _buildTheme({
    required ShadThemeData base,
    required Brightness brightness,
    required Map<String, Color> colors,
    required _TypographyResult typography,
    required _LayoutResult layout,
  }) {
    // Build color scheme override
    ShadColorScheme? colorScheme;
    if (colors.isNotEmpty) {
      final baseScheme = base.colorScheme;
      colorScheme = baseScheme.copyWith(
        primary: colors['primary'],
        primaryForeground: colors['textPrimary'] != null
            ? _contrastForeground(colors['primary'])
            : null,
        secondary: colors['secondary'],
        background: colors['background'],
        foreground: colors['textPrimary'],
        card: colors['surface'],
        cardForeground: colors['textPrimary'],
        popover: colors['surface'],
        popoverForeground: colors['textPrimary'],
        muted: colors['textMuted'],
        mutedForeground: colors['textSecondary'],
        accent: colors['secondary'],
        accentForeground: colors['textPrimary'],
        destructive: colors['danger'],
        border: colors['border'],
        input: colors['border'],
        ring: colors['primary'],
      );
    }

    // Build text theme override
    ShadTextTheme? textTheme;
    if (typography.fontBuilder != null) {
      textTheme = ShadTextTheme.fromGoogleFont(({
        TextStyle? textStyle,
        Color? color,
        Color? backgroundColor,
        double? fontSize,
        FontWeight? fontWeight,
        FontStyle? fontStyle,
        double? letterSpacing,
        double? wordSpacing,
        TextBaseline? textBaseline,
        double? height,
        Locale? locale,
        Paint? foreground,
        Paint? background,
        List<Shadow>? shadows,
        List<FontFeature>? fontFeatures,
        TextDecoration? decoration,
        Color? decorationColor,
        TextDecorationStyle? decorationStyle,
        double? decorationThickness,
      }) {
        return typography.fontBuilder!(textStyle: textStyle);
      });
    }

    // Build radius override
    BorderRadius? radius;
    if (layout.borderRadius != null) {
      radius = BorderRadius.circular(layout.borderRadius!);
    }

    return base.copyWith(
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: textTheme,
      radius: radius,
    );
  }

  /// Computes a simple contrast foreground color (white or black)
  /// based on luminance. Returns null if input is null.
  static Color? _contrastForeground(Color? color) {
    if (color == null) return null;
    return color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }
}

// ─── Internal Helper Classes ──────────────────────────────────────────────

class _TypographyResult {
  final TextStyle Function({TextStyle? textStyle})? fontBuilder;
  final double? baseFontSize;

  const _TypographyResult({
    required this.fontBuilder,
    required this.baseFontSize,
  });
}

class _LayoutResult {
  final String? density;
  final double? borderRadius;

  const _LayoutResult({required this.density, required this.borderRadius});
}
