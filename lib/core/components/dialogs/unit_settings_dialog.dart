import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_radii.dart';
import '../../theme/unit_settings.dart';
import '../legal/legal_disclaimer_content.dart';

/// Settings modal dialog allowing live toggling between American Standard and SI Metric systems,
/// a comprehensive Construction & Building Code Glossary, and Legal & Disclaimer terms.
class UnitSettingsDialog extends StatefulWidget {
  final int initialTab;

  const UnitSettingsDialog({super.key, this.initialTab = 0});

  static Future<void> show(BuildContext context, {int initialTab = 0}) {
    return showDialog(
      context: context,
      builder: (context) => UnitSettingsDialog(initialTab: initialTab),
    );
  }

  @override
  State<UnitSettingsDialog> createState() => _UnitSettingsDialogState();
}

class _UnitSettingsDialogState extends State<UnitSettingsDialog> {
  late int _activeTab; // 0: Unit System, 1: Trade & Code Glossary, 2: Legal & Disclaimer

  @override
  void initState() {
    super.initState();
    _activeTab = widget.initialTab;
  }

  String _getTitle() {
    switch (_activeTab) {
      case 1:
        return 'Code & Glossary';
      case 2:
        return 'Legal & Disclaimer';
      default:
        return 'Unit System Settings';
    }
  }

  IconData _getTitleIcon() {
    switch (_activeTab) {
      case 1:
        return Icons.menu_book_rounded;
      case 2:
        return Icons.shield_outlined;
      default:
        return Icons.tune_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentSystem = UnitSettings.instance.system;

    return Dialog(
      backgroundColor: AppColors.bgSurface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadii.cardRadius,
        side: const BorderSide(color: AppColors.borderSubtle, width: 1.0),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(_getTitleIcon(), color: AppColors.brandGold, size: 24),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            _getTitle(),
                            style: AppTypography.cardTitle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSecondary, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Sub-tabs: Units vs Glossary vs Legal
              Row(
                children: [
                  Expanded(
                    child: _buildSubTab(
                      label: 'Units',
                      icon: Icons.straighten,
                      isSelected: _activeTab == 0,
                      onTap: () => setState(() => _activeTab = 0),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildSubTab(
                      label: 'Code & Glossary',
                      icon: Icons.menu_book_rounded,
                      isSelected: _activeTab == 1,
                      onTap: () => setState(() => _activeTab = 1),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildSubTab(
                      label: 'Legal',
                      icon: Icons.shield_outlined,
                      isSelected: _activeTab == 2,
                      onTap: () => setState(() => _activeTab = 2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              Expanded(
                child: SingleChildScrollView(
                  child: _activeTab == 0
                      ? _buildUnitsContent(currentSystem)
                      : _activeTab == 1
                          ? _buildGlossaryContent()
                          : const LegalDisclaimerContent(showAcceptedBadge: true),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandGold,
                    foregroundColor: AppColors.textInverse,
                    shape: RoundedRectangleBorder(borderRadius: AppRadii.buttonRadius),
                    minimumSize: const Size(120, 44),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Apply Settings', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubTab({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandGold.withValues(alpha: 0.15) : AppColors.bgElevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? AppColors.brandGold : AppColors.borderSubtle),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: isSelected ? AppColors.brandGold : AppColors.textSecondary),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.brandGold : AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitsContent(UnitSystem currentSystem) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select the global measurement standard for all calculators and material estimates.',
          style: AppTypography.helperText,
        ),
        const SizedBox(height: AppSpacing.lg),

        // Option 1: American Standard (Imperial)
        _buildUnitOption(
          title: 'American Standard (Imperial)',
          subtitle: 'Feet, Inches, Fractions (to 1/64"), Yards, Cubic Yards (yd³), Board Feet',
          system: UnitSystem.imperial,
          isSelected: currentSystem == UnitSystem.imperial,
        ),
        const SizedBox(height: AppSpacing.md),

        // Option 2: SI Metric
        _buildUnitOption(
          title: 'International System (SI Metric)',
          subtitle: 'Meters (m), Centimeters (cm), Millimeters (mm), Cubic Meters (m³)',
          system: UnitSystem.metric,
          isSelected: currentSystem == UnitSystem.metric,
        ),
      ],
    );
  }

  Widget _buildGlossaryContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGlossaryCard(
          term: 'IRC 2024 Building Safety Code (§R311.7)',
          tag: 'Stairs & Handrails',
          explanation: 'Standard residential safety rules. It limits the vertical step height (riser) to max 7¾" (197 mm) and step depth (tread) to min 10" (254 mm) to prevent tripping and falling.',
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildGlossaryCard(
          term: "Blondel's Rule of Comfort",
          tag: 'Human Stride Formula',
          explanation: 'Named after 17th-century architect François Blondel. The formula (2 × Step Height + Step Depth = 24" to 25") guarantees stairs feel effortless and match a natural human walking stride.',
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildGlossaryCard(
          term: 'Plumb Cut & Birdsmouth Seat Cut',
          tag: 'Roofing Angles',
          explanation: 'A "Plumb Cut" is the vertical cut where the top of a rafter meets the roof ridge beam. A "Birdsmouth Notch" is the horizontal shelf cut that rests flat on the top of your exterior wall.',
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildGlossaryCard(
          term: 'Nominal vs. Actual Lumber',
          tag: 'Framing & Wood',
          explanation: 'A "2x4" is called nominal because that was its rough-sawn green size. After drying and smooth planing at the mill, its real finished size is 1½" × 3½" (38 × 89 mm).',
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildGlossaryCard(
          term: 'Concrete Ready-Mix & Waste Allowance',
          tag: 'Masonry & Pours',
          explanation: 'Ready-mix concrete is ordered in cubic yards (yd³) or cubic meters (m³). A 10% waste buffer is standard to account for uneven ground, trench spillage, and form deflection.',
        ),
      ],
    );
  }

  Widget _buildGlossaryCard({
    required String term,
    required String tag,
    required String explanation,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(term, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.brandGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(tag, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.brandGold)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(explanation, style: AppTypography.helperText.copyWith(color: AppColors.textPrimary, height: 1.35)),
        ],
      ),
    );
  }

  Widget _buildUnitOption({
    required String title,
    required String subtitle,
    required UnitSystem system,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () {
        UnitSettings.instance.setSystem(system);
        setState(() {});
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandGold.withValues(alpha: 0.12) : AppColors.bgElevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.brandGold : AppColors.borderSubtle,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppColors.brandGold : AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.inputText.copyWith(
                      color: isSelected ? AppColors.brandGold : AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(subtitle, style: AppTypography.helperText),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
