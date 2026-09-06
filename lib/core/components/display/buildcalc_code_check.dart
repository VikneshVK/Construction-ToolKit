import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_radii.dart';
import '../../math/stair_math.dart';

/// IRC Code Sentinel verification banner adhering to DESIGN.md.
/// Non-alarming, explicit building code status indicators.
class BuildCalcCodeCheck extends StatelessWidget {
  final StairCodeReport report;

  const BuildCalcCodeCheck({
    super.key,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color border;
    Color fg;
    IconData icon;
    String statusTitle;

    switch (report.status) {
      case StairCodeStatus.pass:
        bg = AppColors.statusSuccessBg;
        border = AppColors.statusSuccess.withValues(alpha: 0.4);
        fg = AppColors.statusSuccess;
        icon = Icons.verified_outlined;
        statusTitle = 'CODE: PASS — Within IRC Limits';
        break;
      case StairCodeStatus.warning:
        bg = AppColors.statusWarningBg;
        border = AppColors.statusWarning.withValues(alpha: 0.4);
        fg = AppColors.statusWarning;
        icon = Icons.warning_amber_rounded;
        statusTitle = 'CODE: WARNING — Exceeds IRC Limit';
        break;
      case StairCodeStatus.error:
        bg = AppColors.statusErrorBg;
        border = AppColors.statusError.withValues(alpha: 0.4);
        fg = AppColors.statusError;
        icon = Icons.error_outline_rounded;
        statusTitle = 'CODE: ERROR — Invalid Dimensions';
        break;
    }

    final isComfortOk = report.isComfortCompliant;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadii.cardRadius,
        border: Border.all(color: border, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Legal IRC Code Compliance Header
          Row(
            children: [
              Icon(icon, color: fg, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  statusTitle,
                  style: AppTypography.inputText.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            report.ruleReference,
            style: AppTypography.helperText.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (report.details.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            ...report.details.map((detail) => Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• ', style: AppTypography.helperText.copyWith(color: fg)),
                      Expanded(
                        child: Text(
                          detail,
                          style: AppTypography.helperText.copyWith(color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                )),
          ],

          // 2. Separate Architectural Comfort Guidance
          if (report.comfortDetails.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.bgSurface.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isComfortOk
                      ? AppColors.statusSuccess.withValues(alpha: 0.25)
                      : AppColors.brandGold.withValues(alpha: 0.35),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isComfortOk ? Icons.thumb_up_alt_outlined : Icons.info_outline_rounded,
                        size: 14,
                        color: isComfortOk ? AppColors.statusSuccess : AppColors.brandGold,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        report.comfortLabel,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: isComfortOk ? AppColors.statusSuccess : AppColors.brandGold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  ...report.comfortDetails.map((cDetail) => Text(
                        cDetail,
                        style: AppTypography.helperText.copyWith(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      )),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
