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
        statusTitle = 'Pass — Within selected IRC limits';
        break;
      case StairCodeStatus.warning:
        bg = AppColors.statusWarningBg;
        border = AppColors.statusWarning.withValues(alpha: 0.4);
        fg = AppColors.statusWarning;
        icon = Icons.warning_amber_rounded;
        statusTitle = 'Warning — Exceeds selected IRC limit';
        break;
      case StairCodeStatus.error:
        bg = AppColors.statusErrorBg;
        border = AppColors.statusError.withValues(alpha: 0.4);
        fg = AppColors.statusError;
        icon = Icons.error_outline_rounded;
        statusTitle = 'Error — Invalid dimensions';
        break;
    }

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
        ],
      ),
    );
  }
}
