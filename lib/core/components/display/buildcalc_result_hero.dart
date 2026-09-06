import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_radii.dart';

/// Standard Result Hero block answering:
/// 1. What is the exact primary answer?
/// 2. What are the supporting / alternate unit metrics?
/// 3. How much raw material should be ordered?
class BuildCalcResultHero extends StatelessWidget {
  final String title;
  final String primaryResult;
  final String? primaryUnit;
  final String? subtitle;
  final List<String> secondaryMetrics;
  final String? recommendedOrder;
  final Color accentColor;
  final VoidCallback? onSave;
  final VoidCallback? onCopy;
  final VoidCallback? onShare;

  const BuildCalcResultHero({
    super.key,
    required this.title,
    required this.primaryResult,
    this.primaryUnit,
    this.subtitle,
    this.secondaryMetrics = const [],
    this.recommendedOrder,
    this.accentColor = AppColors.brandGold,
    this.onSave,
    this.onCopy,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: AppRadii.cardRadius,
        border: Border.all(color: AppColors.borderSubtle, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header title
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              top: AppSpacing.lg,
            ),
            child: Text(
              title.toUpperCase(),
              style: AppTypography.fieldLabel.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: AppColors.textSecondary,
              ),
            ),
          ),

          // Primary Readout
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(primaryResult, style: AppTypography.heroResult),
                if (primaryUnit != null) ...[
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    primaryUnit!,
                    style: AppTypography.screenTitle.copyWith(color: accentColor),
                  ),
                ],
              ],
            ),
          ),

          // Subtitle / Note
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(subtitle!, style: AppTypography.secondaryMetric),
            ),

          // Secondary metrics (e.g. alternate units)
          if (secondaryMetrics.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.xs,
                children: secondaryMetrics.map((metric) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.bgElevated,
                      borderRadius: AppRadii.chipRadius,
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Text(metric, style: AppTypography.helperText.copyWith(color: AppColors.textPrimary)),
                  );
                }).toList(),
              ),
            ),
          ],

          // Recommended Order Banner
          if (recommendedOrder != null) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.statusSuccessBg,
                borderRadius: AppRadii.inputRadius,
                border: Border.all(color: AppColors.statusSuccess.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline, color: AppColors.statusSuccess, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      recommendedOrder!,
                      style: AppTypography.inputText.copyWith(color: AppColors.statusSuccess),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.md),
          const Divider(color: AppColors.borderSubtle),

          // Action Toolbar (Save, Copy, Share)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (onSave != null)
                  TextButton.icon(
                    onPressed: onSave,
                    icon: const Icon(Icons.bookmark_outline, size: 18, color: AppColors.textSecondary),
                    label: const Text('Save', style: AppTypography.helperText),
                  ),
                if (onCopy != null)
                  TextButton.icon(
                    onPressed: onCopy,
                    icon: const Icon(Icons.copy_outlined, size: 18, color: AppColors.textSecondary),
                    label: const Text('Copy', style: AppTypography.helperText),
                  ),
                if (onShare != null)
                  TextButton.icon(
                    onPressed: onShare,
                    icon: const Icon(Icons.share_outlined, size: 18, color: AppColors.textSecondary),
                    label: const Text('Share', style: AppTypography.helperText),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
