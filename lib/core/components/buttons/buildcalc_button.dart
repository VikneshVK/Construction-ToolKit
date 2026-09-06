import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_motion.dart';

enum BuildCalcButtonVariant {
  primary,   // Safety Gold primary calculate action
  secondary, // Steel Charcoal secondary action (Save, Copy, Reset)
  ghost,     // Subtle action
}

/// Standard jobsite-grade tactile button with 54dp minimum height.
class BuildCalcButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final BuildCalcButtonVariant variant;
  final bool fullWidth;
  final double height;

  const BuildCalcButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.variant = BuildCalcButtonVariant.primary,
    this.fullWidth = true,
    this.height = AppSpacing.primaryButtonHeight,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    BorderSide border = BorderSide.none;

    switch (variant) {
      case BuildCalcButtonVariant.primary:
        bg = onPressed != null ? AppColors.brandGold : AppColors.borderSubtle;
        fg = AppColors.textInverse;
        break;
      case BuildCalcButtonVariant.secondary:
        bg = AppColors.bgElevated;
        fg = AppColors.textPrimary;
        border = const BorderSide(color: AppColors.borderSubtle, width: 1.0);
        break;
      case BuildCalcButtonVariant.ghost:
        bg = Colors.transparent;
        fg = AppColors.textSecondary;
        break;
    }

    final childContent = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20, color: fg),
          const SizedBox(width: AppSpacing.sm),
        ],
        Text(
          label,
          style: variant == BuildCalcButtonVariant.primary
              ? AppTypography.buttonPrimary.copyWith(color: fg)
              : AppTypography.buttonSecondary.copyWith(color: fg),
        ),
      ],
    );

    return SizedBox(
      height: height,
      width: fullWidth ? double.infinity : null,
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.buttonRadius,
          side: border,
        ),
        child: InkWell(
          borderRadius: AppRadii.buttonRadius,
          onTap: onPressed != null
              ? () {
                  AppMotion.tactileClick();
                  onPressed!();
                }
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: childContent,
          ),
        ),
      ),
    );
  }
}
