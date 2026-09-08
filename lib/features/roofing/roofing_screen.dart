import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/math/measurement.dart';
import '../../core/math/roofing_math.dart';
import '../../core/components/inputs/buildcalc_input.dart';
import '../../core/components/display/buildcalc_result_hero.dart';
import '../../core/components/controls/buildcalc_unit_selector.dart';
import '../../core/persistence/local_storage.dart';
import '../../core/components/dialogs/unit_settings_dialog.dart';
import '../../core/theme/unit_settings.dart';
import '../../core/components/guides/build_calc_roof_diagram.dart';
import '../../core/components/display/trade_details_expansion.dart';
import '../../core/components/display/buildcalc_info_card.dart';

/// Roofing Workflow Screen: Common Rafters, Pitch Slope Trigonometry, True-Cut Jack Rafters.
class RoofingScreen extends StatefulWidget {
  const RoofingScreen({super.key});

  @override
  State<RoofingScreen> createState() => _RoofingScreenState();
}

class _RoofingScreenState extends State<RoofingScreen> {
  int _subTabIndex = 0; // 0: Common Rafter & Pitch, 1: True-Cut Jack Schedule

  final TextEditingController _runFeetCtrl = TextEditingController(text: '12');
  final TextEditingController _pitchCtrl = TextEditingController(text: '4');
  final TextEditingController _overhangCtrl = TextEditingController(text: '12');

  double _spacingOnCenter = 16.0; // 16" or 24" O.C. (or mm in metric)
  double _hipLumberThickness = 1.5; // 1.5" (2x) or 3.0" (4x/double)
  final int _jackCount = 5;

  RafterResult? _rafterResult;
  List<JackRafterResult> _jackResults = [];

  RoofMeasurementMode _activeRoofMode = RoofMeasurementMode.run;

  @override
  void initState() {
    super.initState();
    _applyUnitDefaults();
    _recalculate();
  }

  void _applyUnitDefaults() {
    final isMetric = UnitSettings.instance.isMetric;
    if (isMetric) {
      _runFeetCtrl.text = '3.65'; // 3.65 m
      _pitchCtrl.text = '4';     // 4/12
      _overhangCtrl.text = '30'; // 30 cm
    } else {
      _runFeetCtrl.text = '12';  // 12 ft
      _pitchCtrl.text = '4';     // 4/12
      _overhangCtrl.text = '12'; // 12 in
    }
  }

  void _recalculate() {
    final isMetric = UnitSettings.instance.isMetric;
    final runVal = double.tryParse(_runFeetCtrl.text) ?? (isMetric ? 3.65 : 12.0);
    final pitchRise = double.tryParse(_pitchCtrl.text) ?? 4.0;
    final overhangVal = double.tryParse(_overhangCtrl.text) ?? (isMetric ? 30.0 : 12.0);

    final run = isMetric ? Length.fromMeters(runVal) : Length.fromFeet(runVal);
    final pitch = RoofPitch(pitchRise);
    final overhang = isMetric ? Length.fromMillimeters(overhangVal * 10) : Length.fromInches(overhangVal);

    final rafter = RoofingMath.solveCommonRafter(
      run: run,
      pitch: pitch,
      overhangRun: overhang,
    );

    final jacks = RoofingMath.calculateJackRafters(
      pitch: pitch,
      spacingOnCenter: Length.fromInches(_spacingOnCenter),
      hipLumberThickness: Length.fromInches(_hipLumberThickness),
      count: _jackCount,
    );

    setState(() {
      _rafterResult = rafter;
      _jackResults = jacks;
    });
  }

  void _saveCalculation() {
    if (_rafterResult == null) return;
    final isMetric = UnitSettings.instance.isMetric;

    final primaryStr = isMetric
        ? '${_rafterResult!.commonRafterLength.toMeters().toStringAsFixed(3)} m (${_rafterResult!.commonRafterLength.toFeetInchesFraction()})'
        : _rafterResult!.commonRafterLength.toFeetInchesFraction();

    final totalStr = isMetric
        ? '${_rafterResult!.totalRafterLength.toMeters().toStringAsFixed(3)} m'
        : _rafterResult!.totalRafterLength.toFeetInchesFraction();

    LocalStorageService.instance.addCalculation(SavedCalculation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Roof Rafter: ${_rafterResult!.pitch.pitchNotation} Pitch',
      category: 'roofing',
      primaryResult: primaryStr,
      subtitle: 'Plumb: ${_rafterResult!.plumbCutAngle.toStringAsFixed(1)}° | Seat: ${_rafterResult!.levelCutAngle.toStringAsFixed(1)}°',
      inputs: {
        'Run': '${_runFeetCtrl.text} ${isMetric ? 'm' : 'ft'}',
        'Pitch': '${_pitchCtrl.text}/12',
        'Overhang': '${_overhangCtrl.text} ${isMetric ? 'cm' : 'in'}',
      },
      details: [
        'Total w/ Overhang: $totalStr',
        'Line Length: $primaryStr',
        'Opposite Unit: ${isMetric ? _rafterResult!.commonRafterLength.toFeetInchesFraction() : "${_rafterResult!.commonRafterLength.toMeters().toStringAsFixed(3)} m"}',
      ],
      timestamp: DateTime.now(),
    ));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Roofing calculation saved to project log!'),
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
            title: const Text('Roofing & Rafter Cuts'),
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
                  // 1. One Unified Interactive Roof Model
                  if (_rafterResult != null) ...[
                    BuildCalcRoofDiagram(
                      pitch: _rafterResult!.pitch,
                      run: _rafterResult!.totalRun,
                      rise: _rafterResult!.totalRise,
                      overhang: _rafterResult!.overhangRun,
                      rafterLength: _rafterResult!.commonRafterLength,
                      activeMeasurement: _activeRoofMode,
                      isMetric: isMetric,
                      onMeasurementSelected: (mode) => setState(() => _activeRoofMode = mode),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],

                  // 2. Quick slope presets
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildPresetChip('Gentle Slope (4/12 · 18°)', () {
                          _pitchCtrl.text = '4';
                          _activeRoofMode = RoofMeasurementMode.pitch;
                          _recalculate();
                        }),
                        const SizedBox(width: 6),
                        _buildPresetChip('Standard Roof (6/12 · 26°)', () {
                          _pitchCtrl.text = '6';
                          _activeRoofMode = RoofMeasurementMode.pitch;
                          _recalculate();
                        }),
                        const SizedBox(width: 6),
                        _buildPresetChip('Steep Gable (8/12 · 34°)', () {
                          _pitchCtrl.text = '8';
                          _activeRoofMode = RoofMeasurementMode.pitch;
                          _recalculate();
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // 3. Tab Selector
                  BuildCalcTabSelector<int>(
                    items: const [0, 1],
                    selectedItem: _subTabIndex,
                    labelBuilder: (i) => ['Common Rafter & Slope', 'True-Cut Jack Rafters'][i],
                    onSelected: (i) => setState(() => _subTabIndex = i),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  if (_subTabIndex == 0) ...[
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth < 340) {
                          return Column(
                            children: [
                              BuildCalcInput(
                                label: 'Common Rafter Run',
                                unit: isMetric ? 'm' : 'ft',
                                controller: _runFeetCtrl,
                                infoDescription: 'Horizontal distance from the ridge plumb reference to the wall reference.',
                                infoTip: 'This is half the total building width if you have a centered gable roof.',
                                infoTradeTerm: 'Common Rafter Run (Run)',
                                onTap: () => setState(() => _activeRoofMode = RoofMeasurementMode.run),
                                onFocusChange: (f) {
                                  if (f) setState(() => _activeRoofMode = RoofMeasurementMode.run);
                                },
                                onChanged: (_) => _recalculate(),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              BuildCalcInput(
                                label: 'Roof Slope (Rise / 12)',
                                unit: 'in/12',
                                controller: _pitchCtrl,
                                infoDescription: 'How steep the roof is. A 4/12 pitch rises 4 inches vertically for every 12 inches of horizontal run.',
                                infoTradeTerm: 'Roof Pitch (Slope)',
                                onTap: () => setState(() => _activeRoofMode = RoofMeasurementMode.pitch),
                                onFocusChange: (f) {
                                  if (f) setState(() => _activeRoofMode = RoofMeasurementMode.pitch);
                                },
                                onChanged: (_) => _recalculate(),
                              ),
                            ],
                          );
                        }
                        return Row(
                          children: [
                            Expanded(
                              child: BuildCalcInput(
                                label: 'Common Rafter Run',
                                unit: isMetric ? 'm' : 'ft',
                                controller: _runFeetCtrl,
                                infoDescription: 'Horizontal distance from the ridge plumb reference to the wall reference.',
                                infoTip: 'This is half the total building width if you have a centered gable roof.',
                                infoTradeTerm: 'Common Rafter Run (Run)',
                                onTap: () => setState(() => _activeRoofMode = RoofMeasurementMode.run),
                                onFocusChange: (f) {
                                  if (f) setState(() => _activeRoofMode = RoofMeasurementMode.run);
                                },
                                onChanged: (_) => _recalculate(),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: BuildCalcInput(
                                label: 'Roof Slope (Rise / 12)',
                                unit: 'in/12',
                                controller: _pitchCtrl,
                                infoDescription: 'How steep the roof is. A 4/12 pitch rises 4 inches vertically for every 12 inches of horizontal run.',
                                infoTradeTerm: 'Roof Pitch (Slope)',
                                onTap: () => setState(() => _activeRoofMode = RoofMeasurementMode.pitch),
                                onFocusChange: (f) {
                                  if (f) setState(() => _activeRoofMode = RoofMeasurementMode.pitch);
                                },
                                onChanged: (_) => _recalculate(),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    BuildCalcInput(
                      label: 'Eave Overhang (Run)',
                      unit: isMetric ? 'cm' : 'in',
                      controller: _overhangCtrl,
                      infoDescription: 'Horizontal projection of the roof rafter beyond the exterior wall line.',
                      infoTip: 'Standard overhang is 12" (30 cm).',
                      infoTradeTerm: 'Eave Overhang',
                      onTap: () => setState(() => _activeRoofMode = RoofMeasurementMode.overhang),
                      onFocusChange: (f) {
                        if (f) setState(() => _activeRoofMode = RoofMeasurementMode.overhang);
                      },
                      onChanged: (_) => _recalculate(),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],

                  if (_subTabIndex == 0 && _rafterResult != null) ...[
                    BuildCalcResultHero(
                      title: 'Rafter Cut Length',
                      primaryResult: isMetric
                          ? '${_rafterResult!.commonRafterLength.toMeters().toStringAsFixed(3)} m'
                          : _rafterResult!.commonRafterLength.toFeetInchesFraction(),
                      primaryUnit: 'Line Length',
                      subtitle: 'From roof peak ridge to exterior wall at ${_rafterResult!.pitch.pitchNotation} slope (${_rafterResult!.pitchAngleDegrees.toStringAsFixed(1)}°)',
                      secondaryMetrics: [
                        'Total Board with Overhang: ${isMetric ? "${_rafterResult!.totalRafterLength.toMeters().toStringAsFixed(3)} m (${_rafterResult!.totalRafterLength.toMillimeters().toStringAsFixed(0)} mm)" : _rafterResult!.totalRafterLength.toFeetInchesFraction()}',
                      ],
                      accentColor: AppColors.categoryRoofing,
                      onSave: _saveCalculation,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    TradeDetailsExpansion(
                      title: 'Show Saw Angles & Birdsmouth Notches',
                      children: [
                        _buildDetailRow('Top Ridge Plumb Cut Saw Angle', '${_rafterResult!.plumbCutAngle.toStringAsFixed(1)}° (Set miter saw)'),
                        _buildDetailRow('Wall Seat Cut (Birdsmouth Notch)', '${_rafterResult!.levelCutAngle.toStringAsFixed(1)}° flat level notch'),
                        _buildDetailRow('Total Length with Overhang', isMetric ? '${_rafterResult!.totalRafterLength.toMeters().toStringAsFixed(3)} m' : _rafterResult!.totalRafterLength.toFeetInchesFraction()),
                        _buildDetailRow('Roof Incline Slope', '${_rafterResult!.pitchAngleDegrees.toStringAsFixed(1)}° angle (${_rafterResult!.pitch.pitchNotation})'),
                      ],
                    ),
                  ],

                  if (_subTabIndex == 1) ...[
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        const Text('True-Cut Jack Schedule', style: AppTypography.sectionHeader),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            _buildOptionChip(isMetric ? '400mm (16")' : '16" O.C.', _spacingOnCenter == 16.0, () {
                              setState(() => _spacingOnCenter = 16.0);
                              _recalculate();
                            }),
                            _buildOptionChip(isMetric ? '600mm (24")' : '24" O.C.', _spacingOnCenter == 24.0, () {
                              setState(() => _spacingOnCenter = 24.0);
                              _recalculate();
                            }),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        const Text('Hip Lumber Thickness:', style: AppTypography.helperText),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            _buildOptionChip(isMetric ? '38mm (2x)' : '1.5" (2x)', _hipLumberThickness == 1.5, () {
                              setState(() => _hipLumberThickness = 1.5);
                              _recalculate();
                            }),
                            _buildOptionChip(isMetric ? '76mm (4x)' : '3.0" (4x/Dbl)', _hipLumberThickness == 3.0, () {
                              setState(() => _hipLumberThickness = 3.0);
                              _recalculate();
                            }),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    ..._jackResults.map((jack) {
                      final titleStr = isMetric
                          ? 'Jack #${jack.jackIndex} (${(jack.onCenterSpacing.toMillimeters()).round()} mm O.C.)'
                          : 'Jack #${jack.jackIndex} (${jack.onCenterSpacing.toInchesFraction()} O.C.)';
                      final cutStr = isMetric
                          ? '${(jack.trueCutLongPoint.toMillimeters()).round()} mm'
                          : jack.trueCutLongPoint.toFeetInchesFraction();
                      final descStr = isMetric
                          ? 'Centerline: ${(jack.theoreticalLength.toMillimeters()).round()} mm\nHip shortening: ${(jack.hipShortening.toMillimeters()).round()} mm\nCut length to long point: $cutStr\nSaw bevel: ${jack.sideCutBevelAngle.toStringAsFixed(1)}°'
                          : 'Centerline: ${jack.theoreticalLength.toFeetInchesFraction()}\nHip shortening: ${jack.hipShortening.toInchesFraction()}\nCut length to long point: $cutStr\nSaw bevel: ${jack.sideCutBevelAngle.toStringAsFixed(1)}°';

                      return BuildCalcInfoCard(
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        topic: titleStr,
                        value: cutStr,
                        description: descStr,
                        icon: Icons.carpenter_outlined,
                      );
                    }),
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
          Expanded(
            child: Text(label, style: AppTypography.helperText),
          ),
          const SizedBox(width: 8),
          Text(value, style: AppTypography.inputText.copyWith(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildOptionChip(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandGold : AppColors.bgElevated,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: isSelected ? AppColors.brandGold : AppColors.borderSubtle),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isSelected ? AppColors.textInverse : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
