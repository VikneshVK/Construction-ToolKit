import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/math/fraction.dart';
import '../../core/math/measurement.dart';
import '../../core/math/stair_math.dart';
import '../../core/components/inputs/buildcalc_input.dart';
import '../../core/components/inputs/buildcalc_fraction_bar.dart';
import '../../core/components/display/buildcalc_result_hero.dart';
import '../../core/components/display/buildcalc_code_check.dart';
import '../../core/components/controls/buildcalc_unit_selector.dart';
import '../../core/persistence/local_storage.dart';
import '../../core/components/dialogs/unit_settings_dialog.dart';
import '../../core/theme/unit_settings.dart';

import '../../core/components/guides/visual_measurement_guide.dart';
import '../../core/components/display/trade_details_expansion.dart';

/// Stairs Workflow Screen: Dual-Mode Stair Solver (Comfort vs Fixed Opening Run) & IRC 2024 Sentinel.
class StairsScreen extends StatefulWidget {
  const StairsScreen({super.key});

  @override
  State<StairsScreen> createState() => _StairsScreenState();
}

class _StairsScreenState extends State<StairsScreen> {
  StairSolveMode _solveMode = StairSolveMode.comfortableTread;

  // Imperial controllers
  final TextEditingController _riseFeetCtrl = TextEditingController(text: '8');
  Fraction _riseFraction = Fraction.raw(2, 8); // 8' 2 1/2" = 98 1/2"
  final TextEditingController _preferredTreadCtrl = TextEditingController(text: '10');
  final TextEditingController _availableRunFeetCtrl = TextEditingController(text: '11');

  // Metric controllers
  final TextEditingController _riseMmCtrl = TextEditingController(text: '2500'); // 2500 mm
  final TextEditingController _preferredTreadMmCtrl = TextEditingController(text: '280'); // 280 mm
  final TextEditingController _availableRunMetersCtrl = TextEditingController(text: '3.35'); // 3.35 m

  StairResult? _stairResult;

  String _activeStairDim = 'rise';

  @override
  void initState() {
    super.initState();
    _recalculate();
  }

  void _recalculate() {
    final isMetric = UnitSettings.instance.isMetric;

    Length totalRise;
    Length preferredTread;
    Length availableRun;

    if (isMetric) {
      final riseMm = double.tryParse(_riseMmCtrl.text) ?? 2500.0;
      final treadMm = double.tryParse(_preferredTreadMmCtrl.text) ?? 280.0;
      final runM = double.tryParse(_availableRunMetersCtrl.text) ?? 3.35;

      totalRise = Length.fromMillimeters(riseMm);
      preferredTread = Length.fromMillimeters(treadMm);
      availableRun = Length.fromMeters(runM);
    } else {
      final feet = int.tryParse(_riseFeetCtrl.text) ?? 8;
      totalRise = Length.fromFeetAndInches(feet, _riseFraction);

      final tread = double.tryParse(_preferredTreadCtrl.text) ?? 10.0;
      final runFeet = double.tryParse(_availableRunFeetCtrl.text) ?? 11.0;

      preferredTread = Length.fromInches(tread);
      availableRun = Length.fromFeet(runFeet);
    }

    final result = StairMath.solve(
      totalRise: totalRise,
      mode: _solveMode,
      preferredTread: preferredTread,
      availableRun: availableRun,
    );

    setState(() => _stairResult = result);
  }

  void _saveCalculation() {
    if (_stairResult == null) return;
    final isMetric = UnitSettings.instance.isMetric;

    final riserFormatted = isMetric
        ? '${_stairResult!.riserHeight.toMillimeters().toStringAsFixed(1)} mm (${_stairResult!.riserHeight.toInchesFraction()})'
        : _stairResult!.riserHeight.toInchesFraction();

    final treadFormatted = isMetric
        ? '${_stairResult!.treadDepth.toMillimeters().toStringAsFixed(1)} mm'
        : _stairResult!.treadDepth.toInchesFraction();

    final stringerFormatted = isMetric
        ? '${_stairResult!.stringerLength.toMeters().toStringAsFixed(3)} m (${_stairResult!.stringerLength.toFeetInchesFraction()})'
        : _stairResult!.stringerLength.toFeetInchesFraction();

    LocalStorageService.instance.addCalculation(SavedCalculation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Stair Layout (${_stairResult!.numberOfRisers} Risers)',
      category: 'stairs',
      primaryResult: '${_stairResult!.numberOfRisers} Risers @ $riserFormatted',
      subtitle: '${_stairResult!.numberOfTreads} Treads @ $treadFormatted | Incline: ${_stairResult!.inclineAngleDegrees.toStringAsFixed(1)}°',
      inputs: {
        'Total Rise': isMetric ? '${_riseMmCtrl.text} mm' : '${_riseFeetCtrl.text}\' ${_riseFraction.toMixedString()}"',
        'Mode': _solveMode.label,
      },
      details: [
        'Diagonal Stringer: $stringerFormatted',
        'Total Horizontal Run: ${isMetric ? "${_stairResult!.totalRun.toMeters().toStringAsFixed(3)} m" : _stairResult!.totalRun.toFeetInchesFraction()}',
        'Stride Comfort (2R+T): ${((2 * _stairResult!.riserHeight.toInches()) + _stairResult!.treadDepth.toInches()).toStringAsFixed(2)}"',
        'IRC Compliance: ${_stairResult!.codeReport.status == StairCodeStatus.pass ? "Passed" : "Non-Compliant"}',
      ],
      timestamp: DateTime.now(),
    ));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Stair calculation saved to project history!'),
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
            title: const Text('Stairs & Handrails'),
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
                  VisualMeasurementGuide(
                    type: MeasurementGuideType.stairs,
                    activeDimension: _activeStairDim,
                    values: {
                      'rise': isMetric
                          ? (_stairResult != null
                              ? '${_stairResult!.totalRise.toMillimeters().toStringAsFixed(0)} mm'
                              : '${_riseMmCtrl.text} mm')
                          : (_stairResult != null
                              ? _stairResult!.totalRise.toFeetInchesFraction()
                              : '${_riseFeetCtrl.text}\' ${_riseFraction.toMixedString()}"'),
                      'tread': isMetric
                          ? (_stairResult != null
                              ? '${_stairResult!.treadDepth.toMillimeters().toStringAsFixed(0)} mm'
                              : '${_preferredTreadMmCtrl.text} mm')
                          : (_stairResult != null
                              ? _stairResult!.treadDepth.toInchesFraction()
                              : '${_preferredTreadCtrl.text}"'),
                      'run': isMetric
                          ? (_stairResult != null
                              ? '${_stairResult!.totalRun.toMeters().toStringAsFixed(2)} m'
                              : '${_availableRunMetersCtrl.text} m')
                          : (_stairResult != null
                              ? _stairResult!.totalRun.toFeetInchesFraction()
                              : '${_availableRunFeetCtrl.text} ft'),
                    },
                    onDimensionSelected: (dim) => setState(() => _activeStairDim = dim),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Quick ceiling height presets
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildPresetChip('Standard 8 ft Ceiling (244 cm)', () {
                          if (isMetric) {
                            _riseMmCtrl.text = '2438';
                          } else {
                            _riseFeetCtrl.text = '8';
                            _riseFraction = Fraction.zero;
                          }
                          _activeStairDim = 'rise';
                          _recalculate();
                        }),
                        const SizedBox(width: 6),
                        _buildPresetChip('9 ft Ceiling (274 cm)', () {
                          if (isMetric) {
                            _riseMmCtrl.text = '2743';
                          } else {
                            _riseFeetCtrl.text = '9';
                            _riseFraction = Fraction.zero;
                          }
                          _activeStairDim = 'rise';
                          _recalculate();
                        }),
                        const SizedBox(width: 6),
                        _buildPresetChip('Basement / Deck (180 cm)', () {
                          if (isMetric) {
                            _riseMmCtrl.text = '1828';
                          } else {
                            _riseFeetCtrl.text = '6';
                            _riseFraction = Fraction.zero;
                          }
                          _activeStairDim = 'rise';
                          _recalculate();
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  BuildCalcTabSelector<StairSolveMode>(
                    items: StairSolveMode.values,
                    selectedItem: _solveMode,
                    labelBuilder: (m) => m.label,
                    onSelected: (m) {
                      setState(() => _solveMode = m);
                      _recalculate();
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  if (isMetric) ...[
                    BuildCalcInput(
                      label: 'Total Rise (Floor to Floor)',
                      unit: 'mm',
                      controller: _riseMmCtrl,
                      infoDescription: 'Vertical distance from the bottom finished floor to the top finished landing floor.',
                      infoTip: 'Use a laser measure or tape vertically. Include the thickness of top floor decking.',
                      infoTradeTerm: 'Total Rise (Story Height)',
                      onTap: () => setState(() => _activeStairDim = 'rise'),
                      onFocusChange: (f) {
                        if (f) setState(() => _activeStairDim = 'rise');
                      },
                      onChanged: (_) => _recalculate(),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (_solveMode == StairSolveMode.comfortableTread)
                      BuildCalcInput(
                        label: 'Tread Depth',
                        unit: 'mm',
                        controller: _preferredTreadMmCtrl,
                        infoDescription: 'Horizontal walking surface depth where your foot lands on each step (10" is standard).',
                        infoTip: 'Standard comfortable depth is 250 mm to 280 mm (10" - 11").',
                        infoTradeTerm: 'Tread Depth (T)',
                        onTap: () => setState(() => _activeStairDim = 'tread'),
                        onFocusChange: (f) {
                          if (f) setState(() => _activeStairDim = 'tread');
                        },
                        onChanged: (_) => _recalculate(),
                      )
                    else
                      BuildCalcInput(
                        label: 'Available Total Run',
                        unit: 'm',
                        controller: _availableRunMetersCtrl,
                        infoDescription: 'Total horizontal space available on the lower floor for the stairs to land.',
                        infoTradeTerm: 'Available Total Run',
                        onTap: () => setState(() => _activeStairDim = 'run'),
                        onFocusChange: (f) {
                          if (f) setState(() => _activeStairDim = 'run');
                        },
                        onChanged: (_) => _recalculate(),
                      ),
                  ] else ...[
                    BuildCalcInput(
                      label: 'Total Rise (Feet)',
                      unit: 'ft',
                      controller: _riseFeetCtrl,
                      infoDescription: 'Vertical height from bottom floor to top landing.',
                      infoTradeTerm: 'Total Rise',
                      onTap: () => setState(() => _activeStairDim = 'rise'),
                      onFocusChange: (f) {
                        if (f) setState(() => _activeStairDim = 'rise');
                      },
                      onChanged: (_) => _recalculate(),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text('Inches Fraction: ${_riseFraction.toMixedString()}"', style: AppTypography.fieldLabel),
                    const SizedBox(height: 6),
                    BuildCalcFractionBar(
                      selectedFraction: _riseFraction,
                      onFractionSelected: (frac) {
                        setState(() {
                          _riseFraction = frac;
                          _activeStairDim = 'rise';
                        });
                        _recalculate();
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (_solveMode == StairSolveMode.comfortableTread)
                      BuildCalcInput(
                        label: 'Tread Depth',
                        unit: 'in',
                        controller: _preferredTreadCtrl,
                        infoDescription: 'Horizontal walking surface depth where your foot lands on each step (10" is standard).',
                        infoTradeTerm: 'Tread Depth (T)',
                        onTap: () => setState(() => _activeStairDim = 'tread'),
                        onFocusChange: (f) {
                          if (f) setState(() => _activeStairDim = 'tread');
                        },
                        onChanged: (_) => _recalculate(),
                      )
                    else
                      BuildCalcInput(
                        label: 'Available Total Run',
                        unit: 'ft',
                        controller: _availableRunFeetCtrl,
                        infoDescription: 'Total horizontal space available on the lower floor.',
                        infoTradeTerm: 'Available Total Run',
                        onTap: () => setState(() => _activeStairDim = 'run'),
                        onFocusChange: (f) {
                          if (f) setState(() => _activeStairDim = 'run');
                        },
                        onChanged: (_) => _recalculate(),
                      ),
                  ],
                  const SizedBox(height: AppSpacing.xl),

                  if (_stairResult != null) ...[
                    BuildCalcCodeCheck(report: _stairResult!.codeReport),
                    const SizedBox(height: AppSpacing.lg),
                    BuildCalcResultHero(
                      title: 'Stair Steps Summary',
                      primaryResult: '${_stairResult!.numberOfRisers} RISERS',
                      primaryUnit: isMetric
                          ? 'Riser: ${_stairResult!.riserHeight.toMillimeters().toStringAsFixed(1)} mm'
                          : 'Riser: ${_stairResult!.riserHeight.toInchesFraction()}',
                      subtitle: isMetric
                          ? '${_stairResult!.numberOfTreads} TREADS @ ${_stairResult!.treadDepth.toMillimeters().toStringAsFixed(0)} mm · Total Run: ${_stairResult!.totalRun.toMeters().toStringAsFixed(2)} m'
                          : '${_stairResult!.numberOfTreads} TREADS @ ${_stairResult!.treadDepth.toInchesFraction()} · Total Run: ${_stairResult!.totalRun.toFeetInchesFraction()}',
                      secondaryMetrics: [
                        'Total Rise: ${isMetric ? "${_stairResult!.totalRise.toMillimeters().toStringAsFixed(0)} mm" : _stairResult!.totalRise.toFeetInchesFraction()}',
                        'Incline Angle: ${_stairResult!.inclineAngleDegrees.toStringAsFixed(1)}°',
                        'Diagonal Stringer: ${isMetric ? "${_stairResult!.stringerLength.toMeters().toStringAsFixed(3)} m" : _stairResult!.stringerLength.toFeetInchesFraction()}',
                      ],
                      accentColor: AppColors.categoryStairs,
                      onSave: _saveCalculation,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    TradeDetailsExpansion(
                      title: 'Stringer & Code Details',
                      children: [
                        _buildDetailRow('Diagonal Stringer Board Length', isMetric ? '${_stairResult!.stringerLength.toMeters().toStringAsFixed(3)} m (${_stairResult!.stringerLength.toFeetInchesFraction()})' : _stairResult!.stringerLength.toFeetInchesFraction()),
                        _buildDetailRow('Incline Slope Angle', '${_stairResult!.inclineAngleDegrees.toStringAsFixed(1)}° (Ideal: 30° - 37°)'),
                        _buildDetailRow('Step Stride Formula (2R + T)', '${((2 * _stairResult!.riserHeight.toInches()) + _stairResult!.treadDepth.toInches()).toStringAsFixed(1)}" (Target: 24" - 25.5")'),
                        _buildDetailRow('Code Status', _stairResult!.codeReport.codeLabel),
                        _buildDetailRow('Comfort Evaluation', _stairResult!.codeReport.comfortLabel),
                        _buildDetailRow('Safety Code Reference', _stairResult!.codeReport.ruleReference),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPresetChip(String label, VoidCallback onTap) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.brandGold)),
      backgroundColor: AppColors.bgElevated,
      side: const BorderSide(color: AppColors.borderSubtle),
      onPressed: onTap,
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.helperText),
          Text(value, style: AppTypography.inputText.copyWith(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
