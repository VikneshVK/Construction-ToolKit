import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/unit_settings.dart';
import '../../core/components/icons/custom_category_icons.dart';
import '../../core/components/dialogs/unit_settings_dialog.dart';
import '../../core/persistence/local_storage.dart';

/// Home Dashboard Screen precisely matching the design mockup:
/// - "Good morning, Let's build." greeting with settings gear.
/// - 4 category tiles with custom crafted graphic icons.
/// - Global unit system switch badge.
/// - Recent calculations quick-restore list.
class HomeScreen extends StatelessWidget {
  final ValueChanged<int> onSelectCategory;

  const HomeScreen({
    super.key,
    required this.onSelectCategory,
  });

  @override
  Widget build(BuildContext context) {
    final recent = LocalStorageService.instance.getHistory().take(3).toList();

    return ListenableBuilder(
      listenable: UnitSettings.instance,
      builder: (context, _) {
        final isMetric = UnitSettings.instance.isMetric;

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.brandGold,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'BUILDCALC',
                    style: TextStyle(
                      color: AppColors.textInverse,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Built for the Jobsite', style: TextStyle(fontSize: 15)),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: AppColors.textPrimary),
                tooltip: 'Unit & App Settings',
                onPressed: () => UnitSettingsDialog.show(context),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Good morning,', style: AppTypography.helperText.copyWith(fontSize: 14)),
                          const SizedBox(height: 2),
                          const Text("Let's build.", style: AppTypography.heroResult),
                        ],
                      ),
                      // Quick Unit Switch Badge
                      InkWell(
                        onTap: () => UnitSettingsDialog.show(context),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.bgElevated,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.brandGold.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isMetric ? Icons.square_foot_outlined : Icons.straighten,
                                color: AppColors.brandGold,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isMetric ? 'SI Metric' : 'Imperial',
                                style: const TextStyle(
                                  color: AppColors.brandGold,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  const Text('What are you working on?', style: AppTypography.sectionHeader),
                  const SizedBox(height: AppSpacing.md),

                  // 2x2 Category Grid with Custom Crafted Icons matching the mockup
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: AppSpacing.md,
                    crossAxisSpacing: AppSpacing.md,
                    childAspectRatio: 1.05,
                    children: [
                      _buildCategoryCard(
                        title: 'Materials',
                        subtitle: 'Concrete, Lumber,\nMasonry',
                        iconType: 'materials',
                        cardBgColor: const Color(0xFF1E1715),
                        onTap: () => onSelectCategory(1), // Materials
                      ),
                      _buildCategoryCard(
                        title: 'Roofing',
                        subtitle: 'Pitch, Rafters,\nJack Rafters',
                        iconType: 'roofing',
                        cardBgColor: const Color(0xFF131B24),
                        onTap: () => onSelectCategory(2), // Roofing
                      ),
                      _buildCategoryCard(
                        title: 'Stairs',
                        subtitle: 'Design & Safety',
                        iconType: 'stairs',
                        cardBgColor: const Color(0xFF191624),
                        onTap: () => onSelectCategory(3), // Stairs
                      ),
                      _buildCategoryCard(
                        title: 'Measurements',
                        subtitle: 'Convert, Units,\nWaste',
                        iconType: 'measurements',
                        cardBgColor: const Color(0xFF121E1B),
                        onTap: () => onSelectCategory(4), // Measurements
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Recent Calculations Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Recent Calculations', style: AppTypography.sectionHeader),
                      TextButton(
                        onPressed: () => onSelectCategory(5), // History
                        child: const Text('See All', style: TextStyle(color: AppColors.brandGold, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  if (recent.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.bgSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.history, color: AppColors.textMuted, size: 28),
                          SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              'Your recent calculations will be autosaved here for quick retrieval on site.',
                              style: AppTypography.helperText,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...recent.map((item) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.bgSurface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.title, style: AppTypography.inputText),
                                const SizedBox(height: 2),
                                Text(item.subtitle, style: AppTypography.helperText),
                              ],
                            ),
                            Text(item.primaryResult, style: AppTypography.unitBadge.copyWith(fontSize: 16)),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required String subtitle,
    required String iconType,
    required Color cardBgColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: cardBgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderSubtle, width: 1.0),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomCategoryIcon(type: iconType, size: 48),
              const SizedBox(height: AppSpacing.sm),
              Text(title, style: AppTypography.sectionHeader.copyWith(fontSize: 16), textAlign: TextAlign.center),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTypography.helperText.copyWith(fontSize: 11, height: 1.2),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
