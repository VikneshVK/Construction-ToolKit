import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Central typography scale and hierarchy for BuildCalc.
/// Standardized BuildCalc Type Scale:
/// - Screen title: 30 px, 700
/// - Section title: 21 px, 700
/// - Card title: 18 px, 700
/// - Primary result: 52 px, 700-800
/// - Result unit: 26 px, 700
/// - Input label: 17 px, 500
/// - Input value: 28 px, 600
/// - Body: 16 px, 400
/// - Supporting text: 14 px, 400
/// - Micro / meta: 12 px, 500
class AppTypography {
  static const String fontFamily = 'Inter';

  /// 30px w700 for main screen titles
  static const TextStyle screenTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 30,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  /// 21px w700 for section titles
  static const TextStyle sectionTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 21,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  /// Section header alias for section title
  static const TextStyle sectionHeader = sectionTitle;

  /// 18px w700 for card titles
  static const TextStyle cardTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
  );

  /// 52px w800 for primary calculation result numbers (White, tabular figures)
  static const TextStyle primaryResult = TextStyle(
    fontFamily: fontFamily,
    fontSize: 52,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -1.0,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Hero result alias
  static const TextStyle heroResult = primaryResult;

  /// 26px w700 for result units (e.g. yd³, m³, RISERS, Line Length)
  static const TextStyle resultUnit = TextStyle(
    fontFamily: fontFamily,
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.textSecondary,
    letterSpacing: -0.2,
  );

  /// 17px w500 for input labels (Gray)
  static const TextStyle inputLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  /// Field label alias
  static const TextStyle fieldLabel = inputLabel;

  /// 28px w600 for large numeric input values (tabular figures)
  static const TextStyle inputValue = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// 16px w500 for standard input text
  static const TextStyle inputText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// 16px w400 for standard body text
  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  /// 14px w400 for supporting text, descriptions, and helper annotations (Gray)
  static const TextStyle supportingText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.3,
  );

  /// Helper text alias
  static const TextStyle helperText = supportingText;

  /// 12px w500 for micro / meta / badges
  static const TextStyle microMeta = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
    letterSpacing: 0.2,
  );

  /// Badge text alias
  static const TextStyle badgeText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
  );

  /// Unit badge style for chip/tags
  static const TextStyle unitBadge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppColors.textSecondary,
  );

  /// Secondary metric readout style
  static const TextStyle secondaryMetric = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Primary button text
  static const TextStyle buttonPrimary = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textInverse,
    letterSpacing: 0.3,
  );

  /// Secondary button text
  static const TextStyle buttonSecondary = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
}
