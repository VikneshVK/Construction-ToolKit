import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_radii.dart';

/// Universal InfoCard component for BuildCalc.
/// Structure: [icon badge] -> [bold topic / value] -> [short explanatory description]
/// Example: ■ WALL LENGTH 30 ft — Total horizontal length of the wall.
/// Standardized for Materials, Roofing, Stairs, Measurements, and future calculators.
class BuildCalcInfoCard extends StatelessWidget {
  final String topic;
  final String? value;
  final String description;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry padding;

  const BuildCalcInfoCard({
    super.key,
    required this.topic,
    this.value,
    required this.description,
    this.icon = Icons.info_outline_rounded,
    this.iconColor = AppColors.technicalBlue,
    this.iconBgColor = AppColors.technicalBlueBg,
    this.margin,
    this.padding = const EdgeInsets.all(AppSpacing.md),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: AppRadii.cardRadius,
        border: Border.all(color: AppColors.borderSubtle, width: 1.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon badge
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              size: 16,
              color: iconColor,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Topic and Value (wrapped naturally if narrow)
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 2,
                  children: [
                    Text(
                      topic.toUpperCase(),
                      style: const TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.technicalBlue,
                        letterSpacing: 0.4,
                      ),
                    ),
                    if (value != null && value!.isNotEmpty)
                      Text(
                        value!,
                        style: const TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                // Explanatory description
                Text(
                  description,
                  style: AppTypography.supportingText.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
