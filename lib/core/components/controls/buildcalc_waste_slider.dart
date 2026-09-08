import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_motion.dart';

/// Reusable 0% - 20% waste and spillage buffer slider component.
/// Provides real-time waste buffer calculation feedback with tactile haptics.
class BuildCalcWasteSlider extends StatelessWidget {
  final double value; // 0 to 20
  final ValueChanged<double> onChanged;
  final String label;

  const BuildCalcWasteSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.label = 'Waste / Spillage Buffer',
  });

  @override
  Widget build(BuildContext context) {
    final int roundedPercent = value.round();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: AppRadii.cardRadius,
        border: Border.all(color: AppColors.borderSubtle, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(label, style: AppTypography.fieldLabel)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.bgElevated,
                  borderRadius: AppRadii.chipRadius,
                  border: Border.all(color: AppColors.brandGold.withValues(alpha: 0.5)),
                ),
                child: Text(
                  '+$roundedPercent%',
                  style: AppTypography.unitBadge,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.brandGold,
              inactiveTrackColor: AppColors.bgElevated,
              thumbColor: AppColors.brandGold,
              overlayColor: AppColors.brandGold.withValues(alpha: 0.2),
              trackHeight: 6.0,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0),
            ),
            child: Slider(
              value: value,
              min: 0,
              max: 20,
              divisions: 20,
              onChanged: (newVal) {
                if (newVal.round() != value.round()) {
                  AppMotion.tactileClick();
                }
                onChanged(newVal);
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Expanded(
                child: Text('0% (Exact)', style: AppTypography.microMeta, textAlign: TextAlign.start),
              ),
              Expanded(
                child: Text('10% (Standard)', style: AppTypography.microMeta, textAlign: TextAlign.center),
              ),
              Expanded(
                child: Text('20% (High)', style: AppTypography.microMeta, textAlign: TextAlign.end),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
