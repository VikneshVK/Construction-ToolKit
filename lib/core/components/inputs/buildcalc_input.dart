import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_radii.dart';

import 'buildcalc_info_button.dart';

/// Labeled jobsite measurement input with high-contrast borders and unit badges.
class BuildCalcInput extends StatelessWidget {
  final String label;
  final String? hint;
  final String? unit;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final TextInputType keyboardType;
  final Widget? trailing;
  final FocusNode? focusNode;
  final String? infoDescription;
  final String? infoTip;
  final String? infoTradeTerm;

  const BuildCalcInput({
    super.key,
    required this.label,
    this.hint,
    this.unit,
    this.controller,
    this.onChanged,
    this.errorText,
    this.keyboardType = const TextInputType.numberWithOptions(decimal: true, signed: false),
    this.trailing,
    this.focusNode,
    this.infoDescription,
    this.infoTip,
    this.infoTradeTerm,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: AppTypography.fieldLabel),
                if (infoDescription != null) ...[
                  const SizedBox(width: 4),
                  BuildCalcInfoButton(
                    title: label,
                    description: infoDescription!,
                    measuringTip: infoTip,
                    tradeTerm: infoTradeTerm,
                  ),
                ],
              ],
            ),
            if (unit != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.bgElevated,
                  borderRadius: AppRadii.chipRadius,
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Text(unit!, style: AppTypography.unitBadge),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          height: AppSpacing.inputFieldHeight,
          decoration: BoxDecoration(
            color: AppColors.bgInput,
            borderRadius: AppRadii.inputRadius,
            border: Border.all(
              color: errorText != null
                  ? AppColors.statusError
                  : AppColors.borderSubtle,
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  keyboardType: keyboardType,
                  onChanged: onChanged,
                  style: AppTypography.inputText,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: AppTypography.helperText,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                ),
              ),
              if (trailing != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: trailing!,
                ),
            ],
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: AppTypography.helperText.copyWith(color: AppColors.statusError),
          ),
        ],
      ],
    );
  }
}
