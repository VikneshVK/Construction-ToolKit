import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_radii.dart';

/// Gentle ( ? ) info button opening a beginner-friendly modal explaining
/// what a measurement is, how to measure it on site, and its trade jargon name.
class BuildCalcInfoButton extends StatelessWidget {
  final String title;
  final String description;
  final String? measuringTip;
  final String? tradeTerm;
  final IconData? icon;

  const BuildCalcInfoButton({
    super.key,
    required this.title,
    required this.description,
    this.measuringTip,
    this.tradeTerm,
    this.icon,
  });

  void _showHelp(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.brandGold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(icon ?? Icons.help_outline_rounded, color: AppColors.brandGold, size: 20),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(title, style: AppTypography.screenTitle.copyWith(fontSize: 16)),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textSecondary, size: 20),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  description,
                  style: AppTypography.inputText.copyWith(fontSize: 14, height: 1.4),
                ),
                if (measuringTip != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.bgElevated,
                      borderRadius: AppRadii.cardRadius,
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.straighten, color: AppColors.brandGold, size: 18),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('How to Measure:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.textPrimary)),
                              const SizedBox(height: 2),
                              Text(measuringTip!, style: AppTypography.helperText.copyWith(color: AppColors.textPrimary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (tradeTerm != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Trade / Industry Term: $tradeTerm',
                    style: AppTypography.helperText.copyWith(
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showHelp(context),
      borderRadius: BorderRadius.circular(12),
      child: const Padding(
        padding: EdgeInsets.all(4.0),
        child: Icon(
          Icons.help_outline_rounded,
          size: 16,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
