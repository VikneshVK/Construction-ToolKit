import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/math/measurement.dart';
import '../../core/math/concrete_math.dart';
import '../../core/math/framing_math.dart';
import '../../core/math/masonry_math.dart';
import '../../core/components/inputs/buildcalc_input.dart';
import '../../core/components/inputs/buildcalc_info_button.dart';
import '../../core/components/display/buildcalc_result_hero.dart';
import '../../core/components/controls/buildcalc_waste_slider.dart';
import '../../core/components/controls/buildcalc_unit_selector.dart';
import '../../core/persistence/local_storage.dart';

import '../../core/components/guides/visual_measurement_guide.dart';
import '../../core/components/display/trade_details_expansion.dart';

import '../../core/components/dialogs/unit_settings_dialog.dart';
import '../../core/theme/unit_settings.dart';

/// Materials Workflow Screen: Concrete, Framing Lumber & Board Feet, Masonry & Blocks.
class MaterialsScreen extends StatefulWidget {
  const MaterialsScreen({super.key});

  @override
  State<MaterialsScreen> createState() => _MaterialsScreenState();
}

class _MaterialsScreenState extends State<MaterialsScreen> {
  int _subTabIndex = 0; // 0: Concrete, 1: Lumber/Board Feet, 2: Masonry

  // --- Concrete State ---
  ConcreteStructureType _concreteType = ConcreteStructureType.slab;
  final _concDim1Ctrl = TextEditingController(text: '24');
  final _concDim2Ctrl = TextEditingController(text: '12');
  final _concDim3Ctrl = TextEditingController(text: '4');
  double _concWaste = 10.0;
  ConcreteResult? _concreteResult;

  // --- Lumber & Board Feet State ---
  NominalLumberSize _selectedLumber = NominalLumberSize.twoByFour;
  final _lumberLengthCtrl = TextEditingController(text: '12');
  final _lumberQtyCtrl = TextEditingController(text: '20');
  final _lumberCostCtrl = TextEditingController(text: '1.25');
  BoardFeetResult? _boardFeetResult;

  // --- Masonry State ---
  MasonryUnitType _selectedMasonry = MasonryUnitType.standardCmu8;
  final _wallLengthCtrl = TextEditingController(text: '30');
  final _wallHeightCtrl = TextEditingController(text: '8');
  double _masonryWaste = 10.0;
  MasonryResult? _masonryResult;

  // --- Dynamic Active Dimension State ---
  String _activeConcreteDim = 'length';
  String _activeMasonryDim = 'wallLength';

  @override
  void initState() {
    super.initState();
    // Default initial values based on current unit system
    _applyUnitDefaults();
    _recalculateConcrete();
    _recalculateLumber();
    _recalculateMasonry();
  }

  void _applyUnitDefaults() {
    final isMetric = UnitSettings.instance.isMetric;
    if (isMetric) {
      _concDim1Ctrl.text = '7.5'; // 7.5 m
      _concDim2Ctrl.text = '3.5'; // 3.5 m
      _concDim3Ctrl.text = '10';  // 10 cm
      _lumberLengthCtrl.text = '3.6'; // 3.6 m
      _wallLengthCtrl.text = '9.0'; // 9.0 m
      _wallHeightCtrl.text = '2.4'; // 2.4 m
    } else {
      _concDim1Ctrl.text = '24'; // 24 ft
      _concDim2Ctrl.text = '12'; // 12 ft
      _concDim3Ctrl.text = '4';  // 4 in
      _lumberLengthCtrl.text = '12'; // 12 ft
      _wallLengthCtrl.text = '30'; // 30 ft
      _wallHeightCtrl.text = '8';  // 8 ft
    }
  }

  void _recalculateConcrete() {
    final isMetric = UnitSettings.instance.isMetric;
    final d1 = double.tryParse(_concDim1Ctrl.text) ?? 0.0;
    final d2 = double.tryParse(_concDim2Ctrl.text) ?? 0.0;
    final d3 = double.tryParse(_concDim3Ctrl.text) ?? 0.0;

    ConcreteResult res;
    if (isMetric) {
      switch (_concreteType) {
        case ConcreteStructureType.slab:
          res = ConcreteMath.calculateSlab(
            length: Length.fromMeters(d1),
            width: Length.fromMeters(d2),
            thickness: Length.fromCentimeters(d3),
            wastePercent: _concWaste,
          );
          break;
        case ConcreteStructureType.footing:
          res = ConcreteMath.calculateFooting(
            length: Length.fromMeters(d1),
            width: Length.fromCentimeters(d2),
            depth: Length.fromCentimeters(d3),
            wastePercent: _concWaste,
          );
          break;
        case ConcreteStructureType.column:
          res = ConcreteMath.calculateColumn(
            diameter: Length.fromCentimeters(d1),
            height: Length.fromMeters(d2),
            quantity: d3.toInt() > 0 ? d3.toInt() : 1,
            wastePercent: _concWaste,
          );
          break;
        case ConcreteStructureType.wall:
          res = ConcreteMath.calculateWall(
            length: Length.fromMeters(d1),
            height: Length.fromMeters(d2),
            thickness: Length.fromCentimeters(d3),
            wastePercent: _concWaste,
          );
          break;
      }
    } else {
      switch (_concreteType) {
        case ConcreteStructureType.slab:
          res = ConcreteMath.calculateSlab(
            length: Length.fromFeet(d1),
            width: Length.fromFeet(d2),
            thickness: Length.fromInches(d3),
            wastePercent: _concWaste,
          );
          break;
        case ConcreteStructureType.footing:
          res = ConcreteMath.calculateFooting(
            length: Length.fromFeet(d1),
            width: Length.fromInches(d2),
            depth: Length.fromInches(d3),
            wastePercent: _concWaste,
          );
          break;
        case ConcreteStructureType.column:
          res = ConcreteMath.calculateColumn(
            diameter: Length.fromInches(d1),
            height: Length.fromFeet(d2),
            quantity: d3.toInt() > 0 ? d3.toInt() : 1,
            wastePercent: _concWaste,
          );
          break;
        case ConcreteStructureType.wall:
          res = ConcreteMath.calculateWall(
            length: Length.fromFeet(d1),
            height: Length.fromFeet(d2),
            thickness: Length.fromInches(d3),
            wastePercent: _concWaste,
          );
          break;
      }
    }

    setState(() => _concreteResult = res);
  }

  void _recalculateLumber() {
    final l = double.tryParse(_lumberLengthCtrl.text) ?? 12.0;
    final q = int.tryParse(_lumberQtyCtrl.text) ?? 20;
    final c = double.tryParse(_lumberCostCtrl.text) ?? 1.25;

    final res = FramingMath.calculateBoardFeet(
      nominalThicknessInches: _selectedLumber.actualThicknessInches == 1.5 ? 2.0 : (_selectedLumber.actualThicknessInches == 3.5 ? 4.0 : 1.0),
      nominalWidthInches: _selectedLumber.actualWidthInches == 3.5 ? 4.0 : (_selectedLumber.actualWidthInches == 5.5 ? 6.0 : 8.0),
      length: (UnitSettings.instance.isMetric ? Length.fromMeters(l) : Length.fromFeet(l)),
      quantity: q,
      costPerBoardFoot: c,
    );

    setState(() => _boardFeetResult = res);
  }

  void _recalculateMasonry() {
    final isMetric = UnitSettings.instance.isMetric;
    final l = double.tryParse(_wallLengthCtrl.text) ?? (isMetric ? 9.0 : 30.0);
    final h = double.tryParse(_wallHeightCtrl.text) ?? (isMetric ? 2.4 : 8.0);

    final res = MasonryMath.calculateWall(
      wallLength: isMetric ? Length.fromMeters(l) : Length.fromFeet(l),
      wallHeight: isMetric ? Length.fromMeters(h) : Length.fromFeet(h),
      unitLengthInches: _selectedMasonry.lengthInches,
      unitHeightInches: _selectedMasonry.heightInches,
      wastePercent: _masonryWaste,
    );

    setState(() => _masonryResult = res);
  }

  void _saveCurrentCalculation(String title, String primary, String subtitle, Map<String, String> inputs, List<String> details) {
    LocalStorageService.instance.addCalculation(SavedCalculation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      category: 'materials',
      primaryResult: primary,
      subtitle: subtitle,
      inputs: inputs,
      details: details,
      timestamp: DateTime.now(),
    ));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Calculation saved to project log!'),
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
            title: const Text('Materials & Estimating'),
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
                    items: const [0, 1, 2],
                    selectedItem: _subTabIndex,
                    labelBuilder: (i) => ['Concrete', isMetric ? 'Lumber (m³ / BF)' : 'Lumber (BF)', 'Masonry Block'][i],
                    onSelected: (i) => setState(() => _subTabIndex = i),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  if (_subTabIndex == 0) _buildConcreteTab(isMetric),
                  if (_subTabIndex == 1) _buildLumberTab(isMetric),
                  if (_subTabIndex == 2) _buildMasonryTab(isMetric),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildConcreteTab(bool isMetric) {
    final lenUnit = isMetric ? 'm' : 'ft';
    final thickUnit = isMetric ? 'cm' : 'in';

    // Calculate approximate pre-mixed 80lb / 36kg bags (1 bag ≈ 0.6 cu ft = 0.017 m³)
    final totalCuFt = _concreteResult != null ? _concreteResult!.grossVolume.toCubicFeet() : 0.0;
    final bagCount = (totalCuFt / 0.6).ceil();

    MeasurementGuideType guideType = MeasurementGuideType.slab;
    Map<String, String> guideVals = {};

    if (_concreteType == ConcreteStructureType.slab) {
      guideType = MeasurementGuideType.slab;
      guideVals = {
        'length': '${_concDim1Ctrl.text} $lenUnit',
        'width': '${_concDim2Ctrl.text} $lenUnit',
        'thickness': '${_concDim3Ctrl.text} $thickUnit',
      };
    } else if (_concreteType == ConcreteStructureType.footing) {
      guideType = MeasurementGuideType.footing;
      guideVals = {
        'length': '${_concDim1Ctrl.text} $lenUnit',
        'width': '${_concDim2Ctrl.text} $thickUnit',
        'depth': '${_concDim3Ctrl.text} $thickUnit',
      };
    } else if (_concreteType == ConcreteStructureType.column) {
      guideType = MeasurementGuideType.column;
      guideVals = {
        'diameter': '${_concDim1Ctrl.text} $thickUnit',
        'height': '${_concDim2Ctrl.text} $lenUnit',
      };
    } else {
      guideType = MeasurementGuideType.slab;
      guideVals = {
        'length': '${_concDim1Ctrl.text} $lenUnit',
        'width': '${_concDim2Ctrl.text} $lenUnit',
        'thickness': '${_concDim3Ctrl.text} $thickUnit',
      };
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VisualMeasurementGuide(
          type: guideType,
          activeDimension: _activeConcreteDim,
          values: guideVals,
          onDimensionSelected: (dim) => setState(() => _activeConcreteDim = dim),
        ),
        const SizedBox(height: AppSpacing.md),

        BuildCalcTabSelector<ConcreteStructureType>(
          items: ConcreteStructureType.values,
          selectedItem: _concreteType,
          labelBuilder: (t) => t.label,
          onSelected: (t) {
            setState(() {
              _concreteType = t;
              if (t == ConcreteStructureType.column) {
                _activeConcreteDim = 'diameter';
              } else {
                _activeConcreteDim = 'length';
              }
            });
            _recalculateConcrete();
          },
        ),
        const SizedBox(height: AppSpacing.md),

        // Quick presets
        if (_concreteType == ConcreteStructureType.slab) ...[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildPresetChip('Walkway / Patio (10cm / 4")', () {
                  _concDim3Ctrl.text = isMetric ? '10' : '4';
                  _activeConcreteDim = 'thickness';
                  _recalculateConcrete();
                }),
                const SizedBox(width: 6),
                _buildPresetChip('Driveway / Garage (15cm / 6")', () {
                  _concDim3Ctrl.text = isMetric ? '15' : '6';
                  _activeConcreteDim = 'thickness';
                  _recalculateConcrete();
                }),
                const SizedBox(width: 6),
                _buildPresetChip('Heavy Base (20cm / 8")', () {
                  _concDim3Ctrl.text = isMetric ? '20' : '8';
                  _activeConcreteDim = 'thickness';
                  _recalculateConcrete();
                }),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],

        if (_concreteType == ConcreteStructureType.slab) ...[
          Row(
            children: [
              Expanded(
                child: BuildCalcInput(
                  label: 'Length of Area',
                  unit: lenUnit,
                  controller: _concDim1Ctrl,
                  infoDescription: 'The longest horizontal side of your pour area.',
                  infoTip: 'Measure with a tape along the form boards from corner to corner.',
                  infoTradeTerm: 'Slab Length (L)',
                  onTap: () => setState(() => _activeConcreteDim = 'length'),
                  onFocusChange: (f) {
                    if (f) setState(() => _activeConcreteDim = 'length');
                  },
                  onChanged: (_) => _recalculateConcrete(),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: BuildCalcInput(
                  label: 'Width of Area',
                  unit: lenUnit,
                  controller: _concDim2Ctrl,
                  infoDescription: 'The shorter side of your rectangular pour area.',
                  infoTip: 'Measure perpendicular across from form board to form board.',
                  infoTradeTerm: 'Slab Width (W)',
                  onTap: () => setState(() => _activeConcreteDim = 'width'),
                  onFocusChange: (f) {
                    if (f) setState(() => _activeConcreteDim = 'width');
                  },
                  onChanged: (_) => _recalculateConcrete(),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          BuildCalcInput(
            label: 'Pour Thickness (Depth)',
            unit: thickUnit,
            controller: _concDim3Ctrl,
            infoDescription: 'How deep the concrete slab will be poured.',
            infoTip: 'Standard patio/walkway is 4" (10 cm). Vehicle driveways require 6" (15 cm).',
            infoTradeTerm: 'Slab Thickness / Depth (T)',
            onTap: () => setState(() => _activeConcreteDim = 'thickness'),
            onFocusChange: (f) {
              if (f) setState(() => _activeConcreteDim = 'thickness');
            },
            onChanged: (_) => _recalculateConcrete(),
          ),
        ] else if (_concreteType == ConcreteStructureType.footing) ...[
          BuildCalcInput(
            label: 'Trench Length',
            unit: lenUnit,
            controller: _concDim1Ctrl,
            infoDescription: 'Total continuous length of your foundation footing trench.',
            infoTip: 'Add up the lengths of all outer foundation perimeter walls.',
            infoTradeTerm: 'Footing Run',
            onTap: () => setState(() => _activeConcreteDim = 'length'),
            onFocusChange: (f) {
              if (f) setState(() => _activeConcreteDim = 'length');
            },
            onChanged: (_) => _recalculateConcrete(),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: BuildCalcInput(
                  label: 'Trench Width',
                  unit: thickUnit,
                  controller: _concDim2Ctrl,
                  infoDescription: 'Horizontal width across the dug footing trench.',
                  infoTradeTerm: 'Footing Width',
                  onTap: () => setState(() => _activeConcreteDim = 'width'),
                  onFocusChange: (f) {
                    if (f) setState(() => _activeConcreteDim = 'width');
                  },
                  onChanged: (_) => _recalculateConcrete(),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: BuildCalcInput(
                  label: 'Trench Depth',
                  unit: thickUnit,
                  controller: _concDim3Ctrl,
                  infoDescription: 'Vertical depth of concrete poured into the trench.',
                  infoTradeTerm: 'Footing Thickness / Depth',
                  onTap: () => setState(() => _activeConcreteDim = 'depth'),
                  onFocusChange: (f) {
                    if (f) setState(() => _activeConcreteDim = 'depth');
                  },
                  onChanged: (_) => _recalculateConcrete(),
                ),
              ),
            ],
          ),
        ] else if (_concreteType == ConcreteStructureType.column) ...[
          Row(
            children: [
              Expanded(
                child: BuildCalcInput(
                  label: 'Pier Diameter',
                  unit: thickUnit,
                  controller: _concDim1Ctrl,
                  infoDescription: 'Width across the circular Sonotube form or hole.',
                  infoTip: 'Standard deck pier tubes are 8", 10", or 12" (20-30 cm).',
                  infoTradeTerm: 'Column Diameter (Ø)',
                  onTap: () => setState(() => _activeConcreteDim = 'diameter'),
                  onFocusChange: (f) {
                    if (f) setState(() => _activeConcreteDim = 'diameter');
                  },
                  onChanged: (_) => _recalculateConcrete(),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: BuildCalcInput(
                  label: 'Pier Height',
                  unit: lenUnit,
                  controller: _concDim2Ctrl,
                  infoDescription: 'Total depth from ground base to top of pier.',
                  infoTip: 'Must extend below your local winter frost line.',
                  infoTradeTerm: 'Pier Depth / Height',
                  onTap: () => setState(() => _activeConcreteDim = 'height'),
                  onFocusChange: (f) {
                    if (f) setState(() => _activeConcreteDim = 'height');
                  },
                  onChanged: (_) => _recalculateConcrete(),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          BuildCalcInput(
            label: 'Number of Piers',
            unit: 'count',
            controller: _concDim3Ctrl,
            infoDescription: 'How many identical round posts/piers you are pouring.',
            onChanged: (_) => _recalculateConcrete(),
          ),
        ] else ...[
          Row(
            children: [
              Expanded(
                child: BuildCalcInput(
                  label: 'Wall Length',
                  unit: lenUnit,
                  controller: _concDim1Ctrl,
                  infoDescription: 'Length of the poured concrete wall.',
                  onTap: () => setState(() => _activeConcreteDim = 'length'),
                  onFocusChange: (f) {
                    if (f) setState(() => _activeConcreteDim = 'length');
                  },
                  onChanged: (_) => _recalculateConcrete(),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: BuildCalcInput(
                  label: 'Wall Height',
                  unit: lenUnit,
                  controller: _concDim2Ctrl,
                  infoDescription: 'Vertical height of the wall.',
                  onTap: () => setState(() => _activeConcreteDim = 'width'),
                  onFocusChange: (f) {
                    if (f) setState(() => _activeConcreteDim = 'width');
                  },
                  onChanged: (_) => _recalculateConcrete(),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          BuildCalcInput(
            label: 'Wall Thickness',
            unit: thickUnit,
            controller: _concDim3Ctrl,
            infoDescription: 'Thickness of the poured foundation wall.',
            onTap: () => setState(() => _activeConcreteDim = 'thickness'),
            onFocusChange: (f) {
              if (f) setState(() => _activeConcreteDim = 'thickness');
            },
            onChanged: (_) => _recalculateConcrete(),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),

        BuildCalcWasteSlider(
          value: _concWaste,
          onChanged: (val) {
            setState(() => _concWaste = val);
            _recalculateConcrete();
          },
        ),
        const SizedBox(height: AppSpacing.xl),

        if (_concreteResult != null) ...[
          BuildCalcResultHero(
            title: 'Total Concrete Needed',
            primaryResult: isMetric
                ? '${_concreteResult!.grossVolume.toCubicMeters().toStringAsFixed(2)} m³'
                : '${_concreteResult!.grossVolume.toCubicYards().toStringAsFixed(2)} yd³',
            primaryUnit: 'Total Volume',
            subtitle: '≈ $bagCount pre-mixed bags (80 lb / 36 kg) with ${_concWaste.round()}% safety buffer',
            secondaryMetrics: [
              if (isMetric)
                '≈ ${(_concreteResult!.grossVolume.toCubicMeters() * 1000).toStringAsFixed(0)} Liters'
              else
                '≈ ${_concreteResult!.grossVolume.toCubicFeet().toStringAsFixed(1)} Cubic Feet',
            ],
            recommendedOrder: isMetric
                ? 'Ready-Mix Truck Order: ${((_concreteResult!.grossVolume.toCubicMeters() * 10).ceil() / 10.0).toStringAsFixed(1)} m³'
                : 'Ready-Mix Truck Order: ${_concreteResult!.recommendedOrderYards.toStringAsFixed(1)} yd³',
            accentColor: AppColors.categoryMaterials,
            onSave: () {
              _saveCurrentCalculation(
                'Concrete ${_concreteType.label}',
                isMetric
                    ? '${_concreteResult!.grossVolume.toCubicMeters().toStringAsFixed(2)} m³'
                    : '${_concreteResult!.grossVolume.toCubicYards().toStringAsFixed(2)} yd³',
                '≈ $bagCount Bags | Truck Order: ${isMetric ? ((_concreteResult!.grossVolume.toCubicMeters() * 10).ceil() / 10.0).toStringAsFixed(1) : _concreteResult!.recommendedOrderYards.toStringAsFixed(1)} ${isMetric ? "m³" : "yd³"}',
                {'Type': _concreteType.label, 'Waste': '${_concWaste.round()}%', 'System': isMetric ? 'Metric' : 'Imperial'},
                [
                  'Net: ${isMetric ? _concreteResult!.netVolume.toCubicMeters().toStringAsFixed(2) : _concreteResult!.netVolume.toCubicYards().toStringAsFixed(2)} ${isMetric ? "m³" : "yd³"}',
                  'Total with ${_concWaste.round()}% buffer: ${isMetric ? _concreteResult!.grossVolume.toCubicMeters().toStringAsFixed(2) : _concreteResult!.grossVolume.toCubicYards().toStringAsFixed(2)} ${isMetric ? "m³" : "yd³"}',
                  'Bag Count: ≈ $bagCount bags (80 lb / 36 kg)',
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),

          TradeDetailsExpansion(
            title: 'Show Supplier Specs & Ready-Mix Details',
            children: [
              _buildDetailRow('Net Pour Volume (Exact)', isMetric ? '${_concreteResult!.netVolume.toCubicMeters().toStringAsFixed(3)} m³' : '${_concreteResult!.netVolume.toCubicYards().toStringAsFixed(3)} yd³'),
              _buildDetailRow('Safety Buffer (Waste)', '+${_concWaste.round()}% added for ground spill & form bow'),
              _buildDetailRow('Dual Standard Readout', isMetric ? '${_concreteResult!.grossVolume.toCubicYards().toStringAsFixed(2)} yd³ (Imperial)' : '${_concreteResult!.grossVolume.toCubicMeters().toStringAsFixed(2)} m³ (Metric)'),
              _buildDetailRow('Equivalent Weight', '≈ ${(totalCuFt * 145).toStringAsFixed(0)} lbs (~${((totalCuFt * 145) * 0.453592).toStringAsFixed(0)} kg)'),
            ],
          ),
        ],
      ],
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

  Widget _buildLumberTab(bool isMetric) {
    final cubicMeters = (_boardFeetResult != null) ? _boardFeetResult!.totalBoardFeet * 0.00235974 : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Standard Board Size', style: AppTypography.fieldLabel),
            const SizedBox(width: 4),
            const BuildCalcInfoButton(
              title: 'Standard Board Size',
              description: 'Nominal wood dimensions before mill planing. A "2x4" has actual finished dimensions of 1.5" x 3.5" (38 x 89 mm).',
              measuringTip: 'Pick your framing stud or joist lumber dimension from the menu.',
              tradeTerm: 'Nominal Lumber Dimension',
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
            child: DropdownButton<NominalLumberSize>(
              value: _selectedLumber,
              dropdownColor: AppColors.bgElevated,
              isExpanded: true,
              style: AppTypography.inputText,
              items: NominalLumberSize.values.map((size) {
                final metricDims = '${(size.actualThicknessInches * 25.4).round()}x${(size.actualWidthInches * 25.4).round()}mm';
                final labelText = isMetric ? '${size.label} ($metricDims)' : size.label;
                return DropdownMenuItem(value: size, child: Text(labelText));
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedLumber = val);
                  _recalculateLumber();
                }
              },
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        Row(
          children: [
            Expanded(
              child: BuildCalcInput(
                label: 'Board Length',
                unit: isMetric ? 'm' : 'ft',
                controller: _lumberLengthCtrl,
                infoDescription: 'The length of each individual board.',
                infoTip: 'Standard lumber is sold in 8, 10, 12, 14, or 16 ft (2.4m - 4.8m) lengths.',
                onChanged: (_) => _recalculateLumber(),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: BuildCalcInput(
                label: 'Board Count',
                unit: 'pcs',
                controller: _lumberQtyCtrl,
                infoDescription: 'How many identical boards you are buying or estimating.',
                onChanged: (_) => _recalculateLumber(),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        BuildCalcInput(
          label: isMetric ? 'Cost per Board or Unit (Optional)' : 'Cost per Board Foot (Optional)',
          unit: isMetric ? '\$/m³ or \$/BF' : '\$/BF',
          controller: _lumberCostCtrl,
          infoDescription: 'Price per Board Foot or cubic unit to calculate your total wood cost.',
          onChanged: (_) => _recalculateLumber(),
        ),
        const SizedBox(height: AppSpacing.xl),

        if (_boardFeetResult != null) ...[
          BuildCalcResultHero(
            title: isMetric ? 'Total Lumber Volume' : 'Total Board Feet',
            primaryResult: isMetric
                ? '${cubicMeters.toStringAsFixed(3)} m³'
                : '${_boardFeetResult!.totalBoardFeet.toStringAsFixed(1)} BF',
            primaryUnit: isMetric ? 'Volume' : 'Board Feet',
            subtitle: '${_boardFeetResult!.pieceCount} boards of ${_selectedLumber.label} (${_lumberLengthCtrl.text} ${isMetric ? 'm' : 'ft'} long)',
            secondaryMetrics: [
              if (_boardFeetResult!.totalEstimatedCost != null)
                'Estimated Total Cost: \$${_boardFeetResult!.totalEstimatedCost!.toStringAsFixed(2)}',
            ],
            accentColor: AppColors.categoryMaterials,
            onSave: () {
              _saveCurrentCalculation(
                'Lumber: ${_selectedLumber.label}',
                isMetric ? '${cubicMeters.toStringAsFixed(3)} m³' : '${_boardFeetResult!.totalBoardFeet.toStringAsFixed(2)} BF',
                '${_boardFeetResult!.pieceCount} pcs @ ${_lumberLengthCtrl.text} ${isMetric ? 'm' : 'ft'}',
                {'Size': _selectedLumber.label, 'Qty': '${_boardFeetResult!.pieceCount}'},
                [
                  'Total BF: ${_boardFeetResult!.totalBoardFeet.toStringAsFixed(2)} BF',
                  'Total Volume: ${cubicMeters.toStringAsFixed(3)} m³',
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),

          TradeDetailsExpansion(
            title: 'Show Lumber Yard & Wood Specs',
            children: [
              _buildDetailRow('Single Board Volume', '${(_boardFeetResult!.totalBoardFeet / _boardFeetResult!.pieceCount).toStringAsFixed(2)} BF (${(cubicMeters / _boardFeetResult!.pieceCount).toStringAsFixed(4)} m³)'),
              _buildDetailRow('Actual Finished Dimensions', '${_selectedLumber.actualThicknessInches}" × ${_selectedLumber.actualWidthInches}" (${(_selectedLumber.actualThicknessInches * 25.4).round()} × ${(_selectedLumber.actualWidthInches * 25.4).round()} mm)'),
              _buildDetailRow('Total Board Feet (BF)', '${_boardFeetResult!.totalBoardFeet.toStringAsFixed(2)} BF'),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildMasonryTab(bool isMetric) {
    final areaSqMeters = (_masonryResult != null) ? _masonryResult!.wallSquareFeet * 0.092903 : 0.0;
    final lengthUnit = isMetric ? 'm' : 'ft';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VisualMeasurementGuide(
          type: MeasurementGuideType.masonry,
          activeDimension: _activeMasonryDim,
          values: {
            'wallLength': '${_wallLengthCtrl.text} $lengthUnit',
            'wallHeight': '${_wallHeightCtrl.text} $lengthUnit',
          },
          onDimensionSelected: (dim) => setState(() => _activeMasonryDim = dim),
        ),
        const SizedBox(height: AppSpacing.md),

        Row(
          children: [
            const Text('Cinder Block / Brick Style', style: AppTypography.fieldLabel),
            const SizedBox(width: 4),
            const BuildCalcInfoButton(
              title: 'Cinder Block & Brick Type',
              description: 'Standard concrete cinder blocks (CMUs) or red bricks including 3/8" (10 mm) mortar joint spacing.',
              tradeTerm: 'Masonry Unit Type (CMU / Brick)',
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
            child: DropdownButton<MasonryUnitType>(
              value: _selectedMasonry,
              dropdownColor: AppColors.bgElevated,
              isExpanded: true,
              style: AppTypography.inputText,
              items: MasonryUnitType.values.map((size) {
                final metricDims = '${(size.lengthInches * 25.4).round()}x${(size.heightInches * 25.4).round()} mm';
                final labelText = isMetric ? '${size.label} ($metricDims)' : size.label;
                return DropdownMenuItem(value: size, child: Text(labelText));
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedMasonry = val);
                  _recalculateMasonry();
                }
              },
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        Row(
          children: [
            Expanded(
              child: BuildCalcInput(
                label: 'Wall Length',
                unit: lengthUnit,
                controller: _wallLengthCtrl,
                infoDescription: 'Total horizontal length of the block or brick wall.',
                onTap: () => setState(() => _activeMasonryDim = 'wallLength'),
                onFocusChange: (f) {
                  if (f) setState(() => _activeMasonryDim = 'wallLength');
                },
                onChanged: (_) => _recalculateMasonry(),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: BuildCalcInput(
                label: 'Wall Height',
                unit: lengthUnit,
                controller: _wallHeightCtrl,
                infoDescription: 'Vertical height from footing base to top course.',
                onTap: () => setState(() => _activeMasonryDim = 'wallHeight'),
                onFocusChange: (f) {
                  if (f) setState(() => _activeMasonryDim = 'wallHeight');
                },
                onChanged: (_) => _recalculateMasonry(),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        BuildCalcWasteSlider(
          value: _masonryWaste,
          onChanged: (val) {
            setState(() => _masonryWaste = val);
            _recalculateMasonry();
          },
        ),
        const SizedBox(height: AppSpacing.xl),

        if (_masonryResult != null) ...[
          BuildCalcResultHero(
            title: 'Total Blocks & Mortar Needed',
            primaryResult: '${_masonryResult!.totalUnitsRequired}',
            primaryUnit: 'Blocks / Bricks',
            subtitle: '≈ ${_masonryResult!.mortarBagsEstimated.toStringAsFixed(1)} bags of mortar mix (80 lb / 36 kg) included',
            secondaryMetrics: [
              'Wall Area: ${isMetric ? "${areaSqMeters.toStringAsFixed(1)} m²" : "${_masonryResult!.wallSquareFeet.toStringAsFixed(1)} sq ft"}',
            ],
            recommendedOrder: 'Recommended order with buffer: ${_masonryResult!.totalUnitsRequired} units',
            accentColor: AppColors.categoryMaterials,
            onSave: () {
              _saveCurrentCalculation(
                'Masonry: ${_selectedMasonry.label}',
                '${_masonryResult!.totalUnitsRequired} Units',
                '${_masonryResult!.coursesHigh} Horizontal Rows | Mortar: ${_masonryResult!.mortarBagsEstimated.toStringAsFixed(1)} bags',
                {'Type': _selectedMasonry.label, 'Wall': '${_wallLengthCtrl.text}x${_wallHeightCtrl.text} ${isMetric ? 'm' : 'ft'}'},
                [
                  'Units: ${_masonryResult!.totalUnitsRequired}',
                  'Area: ${isMetric ? areaSqMeters.toStringAsFixed(2) : _masonryResult!.wallSquareFeet.toStringAsFixed(1)} ${isMetric ? 'm²' : 'sq ft'}',
                  'Mortar: ${_masonryResult!.mortarBagsEstimated.toStringAsFixed(1)} bags',
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),

          TradeDetailsExpansion(
            title: 'Show Masonry Rows & Mortar Breakdown',
            children: [
              _buildDetailRow('Horizontal Rows (Courses)', '${_masonryResult!.coursesHigh} rows high (${_masonryResult!.unitsPerCourse} blocks per row)'),
              _buildDetailRow('Net Units (Without Waste)', '${_masonryResult!.netUnitsRequired} units'),
              _buildDetailRow('Mortar Mix Weight', '≈ ${(_masonryResult!.mortarBagsEstimated * 36.3).toStringAsFixed(0)} kg (~${(_masonryResult!.mortarBagsEstimated * 80).toStringAsFixed(0)} lbs)'),
            ],
          ),
        ],
      ],
    );
  }
}
