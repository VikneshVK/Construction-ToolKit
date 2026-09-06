import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_motion.dart';

/// Segmented tab selector for switching workflow subtypes (e.g. [Slab] [Footing] [Column] [Wall]).
class BuildCalcTabSelector<T> extends StatelessWidget {
  final List<T> items;
  final T selectedItem;
  final String Function(T item) labelBuilder;
  final ValueChanged<T> onSelected;

  const BuildCalcTabSelector({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.labelBuilder,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.bgInput,
        borderRadius: AppRadii.inputRadius,
        border: Border.all(color: AppColors.borderSubtle, width: 1.0),
      ),
      child: Row(
        children: items.map((item) {
          final isSelected = item == selectedItem;
          return Expanded(
            child: Material(
              color: isSelected ? AppColors.brandGold : Colors.transparent,
              borderRadius: AppRadii.chipRadius,
              child: InkWell(
                borderRadius: AppRadii.chipRadius,
                onTap: () {
                  if (!isSelected) {
                    AppMotion.tactileClick();
                    onSelected(item);
                  }
                },
                child: Center(
                  child: Text(
                    labelBuilder(item),
                    style: isSelected
                        ? AppTypography.inputText.copyWith(color: AppColors.textInverse, fontSize: 13)
                        : AppTypography.inputText.copyWith(color: AppColors.textSecondary, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
