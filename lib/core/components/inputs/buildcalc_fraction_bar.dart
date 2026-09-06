import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_motion.dart';
import '../../math/fraction.dart';

/// Glove-friendly quick fraction picker strip.
/// Tapping a fraction appends or selects the fractional component instantly without manual keyboard typing.
class BuildCalcFractionBar extends StatelessWidget {
  final Fraction? selectedFraction;
  final ValueChanged<Fraction> onFractionSelected;
  final List<Fraction> availableFractions;

  const BuildCalcFractionBar({
    super.key,
    this.selectedFraction,
    required this.onFractionSelected,
    this.availableFractions = const [
      Fraction.raw(1, 16),
      Fraction.raw(1, 8),
      Fraction.raw(3, 16),
      Fraction.raw(1, 4),
      Fraction.raw(5, 16),
      Fraction.raw(3, 8),
      Fraction.raw(7, 16),
      Fraction.raw(1, 2),
      Fraction.raw(9, 16),
      Fraction.raw(5, 8),
      Fraction.raw(11, 16),
      Fraction.raw(3, 4),
      Fraction.raw(13, 16),
      Fraction.raw(7, 8),
      Fraction.raw(15, 16),
    ],
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSpacing.fractionButtonHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: availableFractions.length,
        separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.xs),
        itemBuilder: (context, index) {
          final frac = availableFractions[index];
          final isSelected = selectedFraction == frac;

          return Material(
            color: isSelected ? AppColors.brandGold : AppColors.bgElevated,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadii.chipRadius,
              side: BorderSide(
                color: isSelected ? AppColors.brandGold : AppColors.borderSubtle,
                width: 1.0,
              ),
            ),
            child: InkWell(
              borderRadius: AppRadii.chipRadius,
              onTap: () {
                AppMotion.tactileClick();
                onFractionSelected(frac);
              },
              child: Container(
                constraints: const BoxOption(),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                alignment: Alignment.center,
                child: Text(
                  frac.toMixedString(),
                  style: isSelected
                      ? AppTypography.badgeText.copyWith(color: AppColors.textInverse)
                      : AppTypography.badgeText.copyWith(color: AppColors.textPrimary),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class BoxOption extends BoxConstraints {
  const BoxOption() : super(minWidth: 44, minHeight: 40);
}
