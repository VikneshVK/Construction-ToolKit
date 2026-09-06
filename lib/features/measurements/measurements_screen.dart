import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/math/fraction.dart';
import '../../core/math/measurement.dart';
import '../../core/components/inputs/buildcalc_input.dart';
import '../../core/components/inputs/buildcalc_fraction_bar.dart';
import '../../core/components/inputs/buildcalc_info_button.dart';
import '../../core/components/display/buildcalc_result_hero.dart';
import '../../core/components/controls/buildcalc_unit_selector.dart';
import '../../core/persistence/local_storage.dart';
import '../../core/components/dialogs/unit_settings_dialog.dart';
import '../../core/theme/unit_settings.dart';

/// Measurements Screen: Dimensional Feet-Inch-Fraction & Metric Converter + Mixed-Unit Site Log.
class MeasurementsScreen extends StatefulWidget {
  const MeasurementsScreen({super.key});

  @override
  State<MeasurementsScreen> createState() => _MeasurementsScreenState();
}

class _MeasurementsScreenState extends State<MeasurementsScreen> {
  int _subTabIndex = 0; // 0: Dimensional Converter, 1: Mixed-Unit Site Log

  // --- Dimensional Converter State ---
  LengthUnit _fromUnit = LengthUnit.feet;
  final TextEditingController _convValueCtrl = TextEditingController(text: '12');
  Fraction _convFraction = Fraction.raw(3, 8); // e.g. 12' 3/8" or 12.375
  Length _currentLength = Length.zero;

  // --- Mixed-Unit Site Log State ---
  final TextEditingController _metricDrawingMmCtrl = TextEditingController(text: '2438'); // Standard 8 ft sheet in mm
  final TextEditingController _imperialMaterialInchesCtrl = TextEditingController(text: '96'); // 96" = 8 ft

  @override
  void initState() {
    super.initState();
    if (UnitSettings.instance.isMetric) {
      _fromUnit = LengthUnit.meters;
      _convValueCtrl.text = '3.5';
    }
    _recalculateConverter();
  }

  void _recalculateConverter() {
    final val = double.tryParse(_convValueCtrl.text) ?? 0.0;
    Length len;

    if (_fromUnit == LengthUnit.feet) {
      len = Length.fromFeetAndInches(val.toInt(), _convFraction);
    } else if (_fromUnit == LengthUnit.inches) {
      len = Length.fromInches(val + _convFraction.toDouble());
    } else if (_fromUnit == LengthUnit.yards) {
      len = Length.fromYards(val);
    } else if (_fromUnit == LengthUnit.meters) {
      len = Length.fromMeters(val);
    } else if (_fromUnit == LengthUnit.millimeters) {
      len = Length.fromMillimeters(val);
    } else if (_fromUnit == LengthUnit.centimeters) {
      len = Length.fromMillimeters(val * 10);
    } else {
      len = Length.fromInches(val);
    }

    setState(() => _currentLength = len);
  }

  void _saveConversion() {
    final isMetric = UnitSettings.instance.isMetric;
    final primaryStr = isMetric
        ? '${_currentLength.toFormatted(LengthUnit.meters, decimals: 3)} (${_currentLength.toFormatted(LengthUnit.millimeters, decimals: 1)})'
        : _currentLength.toFeetInchesFraction();

    LocalStorageService.instance.addCalculation(SavedCalculation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Unit Conversion (${_fromUnit.label})',
      category: 'measurements',
      primaryResult: primaryStr,
      subtitle: isMetric
          ? 'Imperial: ${_currentLength.toFeetInchesFraction()} (${_currentLength.toInchesFraction()})'
          : 'Metric: ${_currentLength.toFormatted(LengthUnit.meters, decimals: 3)} | ${_currentLength.toFormatted(LengthUnit.millimeters, decimals: 1)}',
      inputs: {'Input': '${_convValueCtrl.text} ${_fromUnit.symbol}'},
      details: [
        'Inches Fraction: ${_currentLength.toInchesFraction()}',
        'Decimal Feet: ${_currentLength.toFormatted(LengthUnit.feet, decimals: 4)}',
        'Meters: ${_currentLength.toFormatted(LengthUnit.meters, decimals: 4)}',
        'Millimeters: ${_currentLength.toFormatted(LengthUnit.millimeters, decimals: 1)}',
        'Yards: ${_currentLength.toFormatted(LengthUnit.yards, decimals: 3)}',
      ],
      timestamp: DateTime.now(),
    ));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Measurement conversion saved!'),
        backgroundColor: AppColors.bgElevated,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: UnitSettings.instance,
      builder: (context, _) {
        final isMetric = UnitSettings.instance.isMetric;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Measurements & Conversions'),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
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
                  BuildCalcTabSelector<int>(
                    items: const [0, 1],
                    selectedItem: _subTabIndex,
                    labelBuilder: (i) => ['Dimensional Converter', 'Mixed-Unit Site Log'][i],
                    onSelected: (i) => setState(() => _subTabIndex = i),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  if (_subTabIndex == 0) _buildConverterTab(isMetric),
                  if (_subTabIndex == 1) _buildMixedUnitTab(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildConverterTab(bool isMetric) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('Convert From Unit', style: AppTypography.fieldLabel),
            BuildCalcInfoButton(
              title: 'Unit Conversion',
              description: 'Select the unit of measurement you currently have (from tape measure, blueprint, or spec sheet). The calculator will convert it into all other standard building units simultaneously with exact fraction accuracy.',
              measuringTip: 'For feet and inches, enter the whole feet/inches in the box and tap a fraction button below.',
              tradeTerm: 'Dimensional Conversion / Tape Measure Fractions',
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.bgInput,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<LengthUnit>(
              value: _fromUnit,
              dropdownColor: AppColors.bgElevated,
              isExpanded: true,
              style: AppTypography.inputText,
              items: LengthUnit.values.map((u) {
                return DropdownMenuItem(value: u, child: Text('${u.label} (${u.symbol})'));
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _fromUnit = val);
                  _recalculateConverter();
                }
              },
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        BuildCalcInput(
          label: 'Value (${_fromUnit.symbol})',
          unit: _fromUnit.symbol,
          controller: _convValueCtrl,
          infoDescription: 'The whole number value you want to convert.',
          infoTip: 'Enter standard numbers like 12, 4.5, or 2400.',
          onChanged: (_) => _recalculateConverter(),
        ),
        const SizedBox(height: AppSpacing.md),

        if (_fromUnit == LengthUnit.feet || _fromUnit == LengthUnit.inches) ...[
          Text('Fractional Component: ${_convFraction.toMixedString()}"', style: AppTypography.fieldLabel),
          const SizedBox(height: 6),
          BuildCalcFractionBar(
            selectedFraction: _convFraction,
            onFractionSelected: (frac) {
              setState(() => _convFraction = frac);
              _recalculateConverter();
            },
          ),
          const SizedBox(height: AppSpacing.lg),
        ],

        BuildCalcResultHero(
          title: 'Construction Dimension',
          primaryResult: isMetric
              ? _currentLength.toFormatted(LengthUnit.meters, decimals: 3)
              : _currentLength.toFeetInchesFraction(),
          subtitle: isMetric
              ? 'Exact: ${_currentLength.toFormatted(LengthUnit.millimeters, decimals: 1)} | Imperial: ${_currentLength.toFeetInchesFraction()}'
              : 'Exact: ${_currentLength.toInchesFraction()} (${_currentLength.toFormatted(LengthUnit.feet, decimals: 4)})',
          secondaryMetrics: isMetric
              ? [
                  _currentLength.toFormatted(LengthUnit.millimeters, decimals: 1),
                  _currentLength.toFormatted(LengthUnit.centimeters, decimals: 2),
                  _currentLength.toFeetInchesFraction(),
                  _currentLength.toInchesFraction(),
                  _currentLength.toFormatted(LengthUnit.yards, decimals: 3),
                ]
              : [
                  _currentLength.toFormatted(LengthUnit.meters, decimals: 3),
                  _currentLength.toFormatted(LengthUnit.millimeters, decimals: 1),
                  _currentLength.toFormatted(LengthUnit.yards, decimals: 3),
                  _currentLength.toFormatted(LengthUnit.centimeters, decimals: 2),
                ],
          accentColor: AppColors.categoryMeasurements,
          onSave: _saveConversion,
        ),
        const SizedBox(height: AppSpacing.lg),

        const Text('Common Jobsite Equivalents', style: AppTypography.sectionHeader),
        const SizedBox(height: AppSpacing.sm),
        _buildEquivRow('1 Yard (yd)', '3 Feet = 36 Inches = 0.9144 m'),
        _buildEquivRow('1 Meter (m)', '3.28084 Feet = 39.3701 Inches'),
        _buildEquivRow('1 Inch (in)', '25.4 mm (Exact standard)'),
        _buildEquivRow('1/8 Inch', '3.175 mm'),
      ],
    );
  }

  Widget _buildMixedUnitTab() {
    final mmVal = double.tryParse(_metricDrawingMmCtrl.text) ?? 2438.0;
    final convertedFromMm = Length.fromMillimeters(mmVal);

    final impInches = double.tryParse(_imperialMaterialInchesCtrl.text) ?? 96.0;
    final convertedFromImp = Length.fromInches(impInches);

    final diffInches = (convertedFromMm.toInches() - convertedFromImp.toInches()).abs();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('Cross-Border Fit Check', style: AppTypography.sectionHeader),
            BuildCalcInfoButton(
              title: 'Blueprint vs Material Fit Check',
              description: 'When architectural plans are drafted in metric (e.g. 2400 mm) but store-bought materials are manufactured in imperial dimensions (e.g. 8 ft / 96" = 2438.4 mm), this tool checks the exact discrepancy so you know if trimming or shimming is required.',
              measuringTip: 'Enter the mm from your drawing and the inches from the lumber/drywall tag.',
              tradeTerm: 'Nominal vs Actual Modular Coordination',
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        const Text('Compare metric-drafted blueprint drawings against off-the-shelf imperial building materials with zero conversion drift.', style: AppTypography.helperText),
        const SizedBox(height: AppSpacing.lg),

        BuildCalcInput(
          label: 'Blueprint Drawing Dimension (Metric)',
          unit: 'mm',
          controller: _metricDrawingMmCtrl,
          infoDescription: 'The dimension called out on the architectural floor plan or elevation in millimeters.',
          infoTip: 'Common examples: 2400 mm (ceiling), 1200 mm (sheet width), 600 mm (stud spacing).',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text('Equivalent: ${convertedFromMm.toFeetInchesFraction()} (${convertedFromMm.toInchesFraction()})', style: AppTypography.helperText.copyWith(color: AppColors.brandGold)),
        const SizedBox(height: AppSpacing.lg),

        BuildCalcInput(
          label: 'Stock Material Dimension (Imperial)',
          unit: 'in',
          controller: _imperialMaterialInchesCtrl,
          infoDescription: 'The manufactured length of the store-bought building product in inches.',
          infoTip: 'Common examples: 96" (8 ft sheet), 48" (4 ft width), 16" (stud center).',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text('Equivalent: ${convertedFromImp.toFormatted(LengthUnit.millimeters, decimals: 1)} (${convertedFromImp.toFeetInchesFraction()})', style: AppTypography.helperText.copyWith(color: AppColors.brandGold)),
        const SizedBox(height: AppSpacing.xl),

        BuildCalcResultHero(
          title: 'Dimension Variance Check',
          primaryResult: '${diffInches.toStringAsFixed(3)}"',
          primaryUnit: 'variance',
          subtitle: diffInches < 0.0625
              ? '✓ Nominal match (Difference is less than 1/16")'
              : 'Variance: ${Length.fromInches(diffInches).toInchesFraction()} (${(diffInches * 25.4).toStringAsFixed(1)} mm)',
          secondaryMetrics: [
            'Blueprint: ${convertedFromMm.toFeetInchesFraction()}',
            'Stock Material: ${convertedFromImp.toFeetInchesFraction()}',
          ],
          accentColor: diffInches < 0.0625 ? AppColors.statusSuccess : AppColors.statusWarning,
        ),
      ],
    );
  }

  Widget _buildEquivRow(String title, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTypography.inputText),
          Text(desc, style: AppTypography.helperText),
        ],
      ),
    );
  }
}
