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
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        // Estimated required width per item for comfortable text without cramping
        final itemMinWidth = totalWidth / items.length;
        final needsScroll = itemMinWidth < 80 || (items.length > 3 && totalWidth < 360);

        if (needsScroll) {
          return Container(
            height: 46,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: AppColors.bgInput,
              borderRadius: AppRadii.inputRadius,
              border: Border.all(color: AppColors.borderSubtle, width: 1.0),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: items.map((item) {
                  final isSelected = item == selectedItem;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
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
                        child: Container(
                          constraints: const BoxConstraints(minWidth: 76),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          alignment: Alignment.center,
                          child: Text(
                            labelBuilder(item),
                            textAlign: TextAlign.center,
                            style: isSelected
                                ? const TextStyle(
                                    fontFamily: AppTypography.fontFamily,
                                    color: AppColors.textInverse,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    height: 1.15,
                                  )
                                : const TextStyle(
                                    fontFamily: AppTypography.fontFamily,
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    height: 1.15,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        }

        return Container(
          height: 46,
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
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Text(
                          labelBuilder(item),
                          textAlign: TextAlign.center,
                          style: isSelected
                              ? const TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  color: AppColors.textInverse,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  height: 1.15,
                                )
                              : const TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  height: 1.15,
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
