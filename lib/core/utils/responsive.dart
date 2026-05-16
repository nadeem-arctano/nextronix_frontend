import 'package:flutter/widgets.dart';

/// Responsive breakpoints used across Nextronix admin.
///
/// Aligns with the layout assumptions in `AdminLayout`:
/// - mobile  : sidebar collapses into a drawer
/// - tablet  : sidebar shows as a 72px rail
/// - desktop : full 240px sidebar
class Breakpoints {
  Breakpoints._();
  static const double mobile = 768;
  static const double tablet = 1024;
  static const double laptop = 1280;
  static const double desktop = 1536;
}

extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  bool get isMobile => screenWidth < Breakpoints.mobile;
  bool get isTablet =>
      screenWidth >= Breakpoints.mobile && screenWidth < Breakpoints.tablet;
  bool get isDesktop => screenWidth >= Breakpoints.tablet;
  bool get isLargeDesktop => screenWidth >= Breakpoints.laptop;

  /// Pick a value depending on screen width.
  T responsive<T>({required T mobile, T? tablet, T? desktop}) {
    if (screenWidth >= Breakpoints.tablet) return desktop ?? tablet ?? mobile;
    if (screenWidth >= Breakpoints.mobile) return tablet ?? mobile;
    return mobile;
  }
}

/// Renders `mobile` on small screens, `desktop` on larger screens, optionally
/// `tablet` for the in-between range. Use to swap between layouts cleanly.
class ResponsiveBuilder extends StatelessWidget {
  final WidgetBuilder mobile;
  final WidgetBuilder? tablet;
  final WidgetBuilder desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= Breakpoints.tablet) return desktop(context);
    if (w >= Breakpoints.mobile && tablet != null) return tablet!(context);
    return mobile(context);
  }
}
