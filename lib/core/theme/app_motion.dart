import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Snappy, mechanical motion and micro-interaction tokens (120-180ms).
/// Taste Dial: MOTION_INTENSITY 2/10. Zero slow decorative delays.
class AppMotion {
  static const Duration quick = Duration(milliseconds: 120);
  static const Duration standard = Duration(milliseconds: 180);
  static const Duration tab = Duration(milliseconds: 200);

  static const Curve curve = Curves.easeOutCubic;

  /// Light haptic feedback for button taps, unit toggles, and slider snaps
  static void tactileClick() {
    HapticFeedback.selectionClick();
  }

  /// Stronger haptic confirmation on calculation completion
  static void calculateComplete() {
    HapticFeedback.mediumImpact();
  }

  /// Warning haptic when IRC code limit is exceeded
  static void codeWarning() {
    HapticFeedback.heavyImpact();
  }
}
