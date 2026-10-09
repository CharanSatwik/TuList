// File: lib/utils/responsive.dart
import 'package:flutter/material.dart';

/// Responsive design utility providing breakpoints, adaptive dimensions,
/// and responsive wrapping containers for screens across mobile, tablet, and desktop.
class Responsive {
  Responsive._();

  // Standard Breakpoints
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 1024.0;
  static const double multiColumnBreakpoint = 700.0;

  // Max content widths
  static const double authMaxWidth = 460.0;
  static const double formMaxWidth = 620.0;
  static const double mainContentMaxWidth = 1040.0;
  static const double modalMaxWidth = 540.0;

  /// Returns true if the screen width is less than 600dp (standard phones).
  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobileBreakpoint;

  /// Returns true if the screen is a tablet (600dp to 1023dp).
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  /// Returns true if the screen is desktop or web (>= 1024dp).
  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tabletBreakpoint;

  /// Returns true if the screen is wide enough for multi-column layouts.
  static bool isWide(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= multiColumnBreakpoint;

  /// Returns true if device is in landscape mode.
  static bool isLandscape(BuildContext context) =>
      MediaQuery.orientationOf(context) == Orientation.landscape;

  /// Returns adaptive horizontal padding according to screen width.
  static double horizontalPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 360) return 14.0;
    if (width < mobileBreakpoint) return 20.0;
    if (width < tabletBreakpoint) return 32.0;
    return 48.0;
  }
}

/// A container that centers its content and constrains it to a maximum width
/// on wider screens (tablets, desktop, foldables) while smoothly expanding
/// on smaller screens with adaptive padding.
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry alignment;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = Responsive.mainContentMaxWidth,
    this.padding,
    this.alignment = Alignment.topCenter,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: child,
        ),
      ),
    );
  }
}
