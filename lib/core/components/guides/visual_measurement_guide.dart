import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_radii.dart';

/// Type of measurement guide diagram.
enum MeasurementGuideType {
  slab,
  footing,
  column,
  stairs,
  roof,
  masonry,
}

/// Visual "Where Do I Measure?" interactive dynamic blueprint guide with live dimension highlighting.
class VisualMeasurementGuide extends StatefulWidget {
  final MeasurementGuideType type;
  final String? activeDimension; // e.g. 'length', 'width', 'thickness', 'rise', 'tread', 'run', 'pitch', 'overhang'
  final Map<String, String>? values; // e.g. {'length': '24 ft', 'width': '12 ft', 'thickness': '4"'}
  final ValueChanged<String>? onDimensionSelected;

  const VisualMeasurementGuide({
    super.key,
    required this.type,
    this.activeDimension,
    this.values,
    this.onDimensionSelected,
  });

  @override
  State<VisualMeasurementGuide> createState() => _VisualMeasurementGuideState();
}

class _VisualMeasurementGuideState extends State<VisualMeasurementGuide> with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      value: 1.0,
    );
  }

  @override
  void didUpdateWidget(covariant VisualMeasurementGuide oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeDimension != widget.activeDimension) {
      _animCtrl.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeDim = widget.activeDimension ?? _getDefaultDimension();
    final info = _getDimensionInfo(activeDim);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: AppRadii.cardRadius,
        border: Border.all(
          color: widget.activeDimension != null
              ? AppColors.brandGold.withValues(alpha: 0.6)
              : AppColors.borderSubtle,
          width: widget.activeDimension != null ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Category Title + Active Dimension Tag
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 12, top: 10, bottom: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _getCategoryIcon(),
                      size: 16,
                      color: AppColors.brandGold,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _getTitle(),
                      style: AppTypography.inputText.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.brandGold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.brandGold.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    info.title,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brandGold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Center Dynamic Blueprint Canvas
          AnimatedBuilder(
            animation: _animCtrl,
            builder: (context, child) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1219),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF1E293B)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CustomPaint(
                    painter: _DynamicGuidePainter(
                      type: widget.type,
                      activeDimension: activeDim,
                      values: widget.values ?? {},
                      pulseFactor: _animCtrl.value,
                    ),
                    size: Size.infinite,
                  ),
                ),
              );
            },
          ),

          // Bottom Instruction Bar: Dynamic Live Tip for the Active Dimension
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 12, bottom: 10, top: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.arrow_right_alt_rounded,
                  color: AppColors.brandGold,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    info.measuringTip,
                    style: AppTypography.helperText.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Dimension Quick-Switch Chips
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, bottom: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _getDimensionChips().map((chipKey) {
                  final chipInfo = _getDimensionInfo(chipKey);
                  final isSelected = activeDim.toLowerCase() == chipKey.toLowerCase();
                  final val = widget.values?[chipKey];

                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: InkWell(
                      onTap: () {
                        widget.onDimensionSelected?.call(chipKey);
                      },
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.brandGold.withValues(alpha: 0.2)
                              : AppColors.bgElevated,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isSelected ? AppColors.brandGold : AppColors.borderSubtle,
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected ? AppColors.brandGold : AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              val != null && val.isNotEmpty
                                  ? '${chipInfo.shortLabel}: $val'
                                  : chipInfo.shortLabel,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected ? AppColors.brandGold : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getDefaultDimension() {
    switch (widget.type) {
      case MeasurementGuideType.slab:
      case MeasurementGuideType.footing:
        return 'length';
      case MeasurementGuideType.column:
        return 'diameter';
      case MeasurementGuideType.stairs:
        return 'rise';
      case MeasurementGuideType.roof:
        return 'run';
      case MeasurementGuideType.masonry:
        return 'wallLength';
    }
  }

  List<String> _getDimensionChips() {
    switch (widget.type) {
      case MeasurementGuideType.slab:
        return ['length', 'width', 'thickness'];
      case MeasurementGuideType.footing:
        return ['length', 'width', 'depth'];
      case MeasurementGuideType.column:
        return ['diameter', 'height'];
      case MeasurementGuideType.stairs:
        return ['rise', 'tread', 'run'];
      case MeasurementGuideType.roof:
        return ['run', 'pitch', 'overhang'];
      case MeasurementGuideType.masonry:
        return ['wallLength', 'wallHeight'];
    }
  }

  IconData _getCategoryIcon() {
    switch (widget.type) {
      case MeasurementGuideType.slab:
      case MeasurementGuideType.footing:
      case MeasurementGuideType.column:
        return Icons.layers_outlined;
      case MeasurementGuideType.stairs:
        return Icons.stairs_outlined;
      case MeasurementGuideType.roof:
        return Icons.roofing_outlined;
      case MeasurementGuideType.masonry:
        return Icons.grid_view_rounded;
    }
  }

  String _getTitle() {
    switch (widget.type) {
      case MeasurementGuideType.slab:
        return 'Concrete Slab Guide';
      case MeasurementGuideType.footing:
        return 'Trench Footing Guide';
      case MeasurementGuideType.column:
        return 'Round Column Guide';
      case MeasurementGuideType.stairs:
        return 'Staircase Rise & Run Guide';
      case MeasurementGuideType.roof:
        return 'Roof Rafter & Pitch Guide';
      case MeasurementGuideType.masonry:
        return 'Masonry Wall Guide';
    }
  }

  _DimensionInfo _getDimensionInfo(String key) {
    switch (key.toLowerCase()) {
      case 'length':
        return const _DimensionInfo(
          title: 'Length (L)',
          shortLabel: 'Length',
          measuringTip: 'Measure along the longest side of your form boards from corner to corner.',
        );
      case 'width':
        return const _DimensionInfo(
          title: 'Width (W)',
          shortLabel: 'Width',
          measuringTip: 'Measure across the shorter side perpendicular to length between form boards.',
        );
      case 'thickness':
      case 'depth':
        return const _DimensionInfo(
          title: 'Thickness (Depth)',
          shortLabel: 'Thickness',
          measuringTip: 'Vertical pour thickness from compacted gravel subbase to top of form boards (e.g. 4" patio, 6" driveway).',
        );
      case 'diameter':
        return const _DimensionInfo(
          title: 'Tube Diameter (D)',
          shortLabel: 'Diameter',
          measuringTip: 'Inside diameter of sonotube or auger hole across the center.',
        );
      case 'height':
        return const _DimensionInfo(
          title: 'Height (H)',
          shortLabel: 'Height',
          measuringTip: 'Vertical height from bottom of hole to top of pier form.',
        );
      case 'rise':
        return const _DimensionInfo(
          title: 'Total Rise (Height)',
          shortLabel: 'Total Rise',
          measuringTip: 'Total vertical height from lower finished floor to upper landing floor level.',
        );
      case 'tread':
        return const _DimensionInfo(
          title: 'Step Depth (Tread)',
          shortLabel: 'Step Tread',
          measuringTip: 'Horizontal walking surface depth where your foot lands on each step (10" is standard).',
        );
      case 'run':
        if (widget.type == MeasurementGuideType.roof) {
          return const _DimensionInfo(
            title: 'Horizontal Run (Half-Span)',
            shortLabel: 'Roof Run',
            measuringTip: 'Horizontal distance from outside edge of exterior wall to the center roof ridge.',
          );
        }
        return const _DimensionInfo(
          title: 'Total Run (Length)',
          shortLabel: 'Total Run',
          measuringTip: 'Total horizontal distance required along the lower floor for the stair stringer base.',
        );
      case 'pitch':
        return const _DimensionInfo(
          title: 'Roof Slope (Pitch)',
          shortLabel: 'Slope (Pitch)',
          measuringTip: 'Vertical rise in inches per 12 inches of horizontal run (e.g., 4:12 = 4" rise per 12" run).',
        );
      case 'overhang':
        return const _DimensionInfo(
          title: 'Eaves Overhang',
          shortLabel: 'Overhang',
          measuringTip: 'Horizontal distance rafters extend past the exterior wall to protect siding from rain.',
        );
      case 'walllength':
        return const _DimensionInfo(
          title: 'Wall Length',
          shortLabel: 'Length',
          measuringTip: 'Total horizontal length of the brick or CMU block wall.',
        );
      case 'wallheight':
        return const _DimensionInfo(
          title: 'Wall Height',
          shortLabel: 'Height',
          measuringTip: 'Total vertical height of the wall from top of footing to the top course.',
        );
      default:
        return _DimensionInfo(
          title: key,
          shortLabel: key,
          measuringTip: 'Enter jobsite dimension measured with tape or laser.',
        );
    }
  }
}

class _DimensionInfo {
  final String title;
  final String shortLabel;
  final String measuringTip;

  const _DimensionInfo({
    required this.title,
    required this.shortLabel,
    required this.measuringTip,
  });
}

class _DynamicGuidePainter extends CustomPainter {
  final MeasurementGuideType type;
  final String activeDimension;
  final Map<String, String> values;
  final double pulseFactor; // 0.0 to 1.0

  const _DynamicGuidePainter({
    required this.type,
    required this.activeDimension,
    required this.values,
    required this.pulseFactor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw subtle blueprint grid background
    _paintGrid(canvas, size);

    switch (type) {
      case MeasurementGuideType.slab:
      case MeasurementGuideType.footing:
        _paintIsometricSlab(canvas, size);
        break;
      case MeasurementGuideType.column:
        _paintCylinder(canvas, size);
        break;
      case MeasurementGuideType.stairs:
        _paintStairs(canvas, size);
        break;
      case MeasurementGuideType.roof:
        _paintRoof(canvas, size);
        break;
      case MeasurementGuideType.masonry:
        _paintMasonry(canvas, size);
        break;
    }
  }

  void _paintGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFF1E293B).withValues(alpha: 0.5)
      ..strokeWidth = 0.5;

    const step = 16.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  void _paintIsometricSlab(Canvas canvas, Size size) {
    final isLengthActive = activeDimension.toLowerCase() == 'length';
    final isWidthActive = activeDimension.toLowerCase() == 'width';
    final isThicknessActive = activeDimension.toLowerCase() == 'thickness' || activeDimension.toLowerCase() == 'depth';

    final center = Offset(size.width * 0.5, size.height * 0.48);

    // 4 Top Face Vertices (Isometric Diamond)
    final pLeft = Offset(center.dx - 90, center.dy);
    final pTop = Offset(center.dx, center.dy - 35);
    final pRight = Offset(center.dx + 90, center.dy);
    final pBottom = Offset(center.dx, center.dy + 35);

    final slabThickness = 22.0;

    // 4 Bottom Face Vertices
    final bLeft = Offset(pLeft.dx, pLeft.dy + slabThickness);
    final bRight = Offset(pRight.dx, pRight.dy + slabThickness);
    final bBottom = Offset(pBottom.dx, pBottom.dy + slabThickness);

    // 1. Top Face Fill
    final topPath = Path()
      ..moveTo(pTop.dx, pTop.dy)
      ..lineTo(pRight.dx, pRight.dy)
      ..lineTo(pBottom.dx, pBottom.dy)
      ..lineTo(pLeft.dx, pLeft.dy)
      ..close();

    final topPaint = Paint()
      ..color = const Color(0xFF1E293B).withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;
    canvas.drawPath(topPath, topPaint);

    // Top Face Outline
    final outlinePaint = Paint()
      ..color = const Color(0xFF475569)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(topPath, outlinePaint);

    // 2. Left Front Face (Length edge extrusion)
    final leftFace = Path()
      ..moveTo(pLeft.dx, pLeft.dy)
      ..lineTo(pBottom.dx, pBottom.dy)
      ..lineTo(bBottom.dx, bBottom.dy)
      ..lineTo(bLeft.dx, bLeft.dy)
      ..close();

    final leftFacePaint = Paint()
      ..color = (isLengthActive || isThicknessActive)
          ? AppColors.brandGold.withValues(alpha: 0.18 + 0.1 * pulseFactor)
          : const Color(0xFF151D2A)
      ..style = PaintingStyle.fill;
    canvas.drawPath(leftFace, leftFacePaint);
    canvas.drawPath(leftFace, outlinePaint);

    // 3. Right Front Face (Width edge extrusion)
    final rightFace = Path()
      ..moveTo(pBottom.dx, pBottom.dy)
      ..lineTo(pRight.dx, pRight.dy)
      ..lineTo(bRight.dx, bRight.dy)
      ..lineTo(bBottom.dx, bBottom.dy)
      ..close();

    final rightFacePaint = Paint()
      ..color = (isWidthActive || isThicknessActive)
          ? AppColors.brandGold.withValues(alpha: 0.18 + 0.1 * pulseFactor)
          : const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;
    canvas.drawPath(rightFace, rightFacePaint);
    canvas.drawPath(rightFace, outlinePaint);

    // --- Dynamic Dimension Arrows & Labels ---

    // A. LENGTH DIMENSION LINE (along front-left bottom edge)
    final lenVal = values['length'] ?? '';
    final lenLabel = lenVal.isNotEmpty ? 'Length: $lenVal' : 'LENGTH';
    _paintDimensionLine(
      canvas: canvas,
      start: Offset(bLeft.dx - 8, bLeft.dy + 8),
      end: Offset(bBottom.dx - 8, bBottom.dy + 8),
      label: lenLabel,
      isActive: isLengthActive,
      pulseFactor: pulseFactor,
      labelOffset: const Offset(-8, 12),
    );

    // B. WIDTH DIMENSION LINE (along front-right bottom edge)
    final widthVal = values['width'] ?? '';
    final widthLabel = widthVal.isNotEmpty ? 'Width: $widthVal' : 'WIDTH';
    _paintDimensionLine(
      canvas: canvas,
      start: Offset(bBottom.dx + 8, bBottom.dy + 8),
      end: Offset(bRight.dx + 8, bRight.dy + 8),
      label: widthLabel,
      isActive: isWidthActive,
      pulseFactor: pulseFactor,
      labelOffset: const Offset(8, 12),
    );

    // C. THICKNESS / DEPTH DIMENSION LINE (along left vertical edge)
    final thickVal = values['thickness'] ?? values['depth'] ?? '';
    final thickLabel = thickVal.isNotEmpty ? 'Depth: $thickVal' : 'THICKNESS';
    _paintDimensionLine(
      canvas: canvas,
      start: Offset(pLeft.dx - 18, pLeft.dy),
      end: Offset(bLeft.dx - 18, bLeft.dy),
      label: thickLabel,
      isActive: isThicknessActive,
      pulseFactor: pulseFactor,
      labelOffset: const Offset(-24, 0),
    );
  }

  void _paintCylinder(Canvas canvas, Size size) {
    final isDiaActive = activeDimension.toLowerCase() == 'diameter';
    final isHeightActive = activeDimension.toLowerCase() == 'height';

    final center = Offset(size.width * 0.5, size.height * 0.5);
    final radiusX = 45.0;
    final radiusY = 14.0;
    final height = 65.0;

    final topCenter = Offset(center.dx, center.dy - height * 0.45);
    final bottomCenter = Offset(center.dx, center.dy + height * 0.45);

    // Cylinder Body Fill
    final bodyPath = Path()
      ..moveTo(topCenter.dx - radiusX, topCenter.dy)
      ..lineTo(bottomCenter.dx - radiusX, bottomCenter.dy)
      ..arcTo(Rect.fromCenter(center: bottomCenter, width: radiusX * 2, height: radiusY * 2), 3.14159, -3.14159, false)
      ..lineTo(topCenter.dx + radiusX, topCenter.dy)
      ..arcTo(Rect.fromCenter(center: topCenter, width: radiusX * 2, height: radiusY * 2), 0, 3.14159, false)
      ..close();

    final bodyPaint = Paint()
      ..color = const Color(0xFF1E293B).withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;
    canvas.drawPath(bodyPath, bodyPaint);

    // Top Cap Fill
    final capRect = Rect.fromCenter(center: topCenter, width: radiusX * 2, height: radiusY * 2);
    final capPaint = Paint()
      ..color = isDiaActive
          ? AppColors.brandGold.withValues(alpha: 0.2 + 0.1 * pulseFactor)
          : const Color(0xFF334155)
      ..style = PaintingStyle.fill;
    canvas.drawOval(capRect, capPaint);
    canvas.drawOval(capRect, Paint()..color = const Color(0xFF475569)..style = PaintingStyle.stroke..strokeWidth = 1.0);

    // Cylinder Outline
    final outlinePaint = Paint()..color = const Color(0xFF475569)..style = PaintingStyle.stroke..strokeWidth = 1.0;
    canvas.drawLine(Offset(topCenter.dx - radiusX, topCenter.dy), Offset(bottomCenter.dx - radiusX, bottomCenter.dy), outlinePaint);
    canvas.drawLine(Offset(topCenter.dx + radiusX, topCenter.dy), Offset(bottomCenter.dx + radiusX, bottomCenter.dy), outlinePaint);

    // Diameter Dimension Line
    final diaVal = values['diameter'] ?? '';
    _paintDimensionLine(
      canvas: canvas,
      start: Offset(topCenter.dx - radiusX, topCenter.dy - 12),
      end: Offset(topCenter.dx + radiusX, topCenter.dy - 12),
      label: diaVal.isNotEmpty ? 'Diameter: $diaVal' : 'DIAMETER',
      isActive: isDiaActive,
      pulseFactor: pulseFactor,
      labelOffset: const Offset(0, -10),
    );

    // Height Dimension Line
    final hVal = values['height'] ?? '';
    _paintDimensionLine(
      canvas: canvas,
      start: Offset(topCenter.dx + radiusX + 16, topCenter.dy),
      end: Offset(bottomCenter.dx + radiusX + 16, bottomCenter.dy),
      label: hVal.isNotEmpty ? 'Height: $hVal' : 'HEIGHT',
      isActive: isHeightActive,
      pulseFactor: pulseFactor,
      labelOffset: const Offset(26, 0),
    );
  }

  void _paintStairs(Canvas canvas, Size size) {
    final isRiseActive = activeDimension.toLowerCase() == 'rise';
    final isTreadActive = activeDimension.toLowerCase() == 'tread';
    final isRunActive = activeDimension.toLowerCase() == 'run';

    final start = Offset(size.width * 0.22, size.height * 0.82);
    final numSteps = 4;
    final stepW = 32.0;
    final stepH = 18.0;

    final stairPath = Path()..moveTo(start.dx, start.dy);
    double curX = start.dx;
    double curY = start.dy;

    for (int i = 0; i < numSteps; i++) {
      curX += stepW;
      stairPath.lineTo(curX, curY); // Tread
      curY -= stepH;
      stairPath.lineTo(curX, curY); // Rise
    }
    // Top landing
    stairPath.lineTo(curX + 24, curY);

    // Stair Outline & Glow
    final stairPaint = Paint()
      ..color = const Color(0xFF64748B)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(stairPath, stairPaint);

    // Total Rise Vertical Dimension Line (Right Side)
    final riseVal = values['rise'] ?? '';
    _paintDimensionLine(
      canvas: canvas,
      start: Offset(curX + 32, start.dy),
      end: Offset(curX + 32, curY),
      label: riseVal.isNotEmpty ? 'Rise: $riseVal' : 'TOTAL RISE (HEIGHT)',
      isActive: isRiseActive,
      pulseFactor: pulseFactor,
      labelOffset: const Offset(20, 0),
    );

    // Single Tread Depth Dimension Line (Top Step)
    final treadVal = values['tread'] ?? '';
    final step2X = start.dx + stepW * 2;
    final step2Y = start.dy - stepH * 2;
    _paintDimensionLine(
      canvas: canvas,
      start: Offset(step2X, step2Y - 8),
      end: Offset(step2X + stepW, step2Y - 8),
      label: treadVal.isNotEmpty ? 'Tread: $treadVal' : 'STEP TREAD',
      isActive: isTreadActive,
      pulseFactor: pulseFactor,
      labelOffset: const Offset(0, -10),
    );

    // Total Run Dimension Line (Bottom Base)
    final runVal = values['run'] ?? '';
    _paintDimensionLine(
      canvas: canvas,
      start: Offset(start.dx, start.dy + 12),
      end: Offset(curX, start.dy + 12),
      label: runVal.isNotEmpty ? 'Run: $runVal' : 'TOTAL RUN (LENGTH)',
      isActive: isRunActive,
      pulseFactor: pulseFactor,
      labelOffset: const Offset(0, 10),
    );
  }

  void _paintRoof(Canvas canvas, Size size) {
    final isRunActive = activeDimension.toLowerCase() == 'run';
    final isPitchActive = activeDimension.toLowerCase() == 'pitch';
    final isOverhangActive = activeDimension.toLowerCase() == 'overhang';

    final centerRidge = Offset(size.width * 0.5, size.height * 0.22);
    final wallLeft = Offset(size.width * 0.24, size.height * 0.68);
    final eavesLeft = Offset(size.width * 0.12, size.height * 0.80);
    final wallRight = Offset(size.width * 0.76, size.height * 0.68);
    final eavesRight = Offset(size.width * 0.88, size.height * 0.80);

    // Roof Truss Outline
    final roofPath = Path()
      ..moveTo(eavesLeft.dx, eavesLeft.dy)
      ..lineTo(centerRidge.dx, centerRidge.dy)
      ..lineTo(eavesRight.dx, eavesRight.dy);

    final roofPaint = Paint()
      ..color = const Color(0xFF64748B)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(roofPath, roofPaint);

    // Exterior Wall Indicators
    final wallPaint = Paint()
      ..color = const Color(0xFF334155)
      ..strokeWidth = 1.5;
    canvas.drawLine(wallLeft, Offset(wallLeft.dx, wallLeft.dy + 20), wallPaint);
    canvas.drawLine(wallRight, Offset(wallRight.dx, wallRight.dy + 20), wallPaint);

    // Horizontal Run Dimension Line (From Wall to Center Ridge)
    final runVal = values['run'] ?? '';
    _paintDimensionLine(
      canvas: canvas,
      start: Offset(wallLeft.dx, wallLeft.dy + 10),
      end: Offset(centerRidge.dx, wallLeft.dy + 10),
      label: runVal.isNotEmpty ? 'Run: $runVal' : 'HORIZONTAL RUN (HALF-SPAN)',
      isActive: isRunActive,
      pulseFactor: pulseFactor,
      labelOffset: const Offset(0, 10),
    );

    // Roof Pitch Slope Triangle (on left rafter)
    final midRafter = Offset(
      (centerRidge.dx + wallLeft.dx) * 0.5,
      (centerRidge.dy + wallLeft.dy) * 0.5,
    );
    final pitchVal = values['pitch'] ?? '';
    _paintSlopeTriangle(
      canvas: canvas,
      origin: midRafter,
      pitchText: pitchVal.isNotEmpty ? '$pitchVal:12' : 'PITCH / 12',
      isActive: isPitchActive,
      pulseFactor: pulseFactor,
    );

    // Overhang Dimension Line
    final overhangVal = values['overhang'] ?? '';
    _paintDimensionLine(
      canvas: canvas,
      start: Offset(eavesLeft.dx, eavesLeft.dy + 10),
      end: Offset(wallLeft.dx, eavesLeft.dy + 10),
      label: overhangVal.isNotEmpty ? 'Eaves: $overhangVal' : 'OVERHANG',
      isActive: isOverhangActive,
      pulseFactor: pulseFactor,
      labelOffset: const Offset(0, 10),
    );
  }

  void _paintMasonry(Canvas canvas, Size size) {
    final isLenActive = activeDimension.toLowerCase() == 'walllength' || activeDimension.toLowerCase() == 'length';
    final isHeightActive = activeDimension.toLowerCase() == 'wallheight' || activeDimension.toLowerCase() == 'height';

    final left = size.width * 0.2;
    final right = size.width * 0.8;
    final top = size.height * 0.25;
    final bottom = size.height * 0.75;

    // Wall Outline Grid
    final wallRect = Rect.fromLTRB(left, top, right, bottom);
    final wallFill = Paint()..color = const Color(0xFF1E293B)..style = PaintingStyle.fill;
    final wallStroke = Paint()..color = const Color(0xFF475569)..strokeWidth = 1.0..style = PaintingStyle.stroke;
    canvas.drawRect(wallRect, wallFill);

    // Draw grid courses
    const rows = 3;
    const cols = 6;
    final rowH = (bottom - top) / rows;
    final colW = (right - left) / cols;

    for (int r = 1; r < rows; r++) {
      canvas.drawLine(Offset(left, top + r * rowH), Offset(right, top + r * rowH), wallStroke);
    }
    for (int c = 1; c < cols; c++) {
      canvas.drawLine(Offset(left + c * colW, top), Offset(left + c * colW, bottom), wallStroke);
    }
    canvas.drawRect(wallRect, wallStroke);

    // Wall Length Line (Top)
    final lVal = values['wallLength'] ?? values['length'] ?? '';
    _paintDimensionLine(
      canvas: canvas,
      start: Offset(left, top - 12),
      end: Offset(right, top - 12),
      label: lVal.isNotEmpty ? 'Length: $lVal' : 'WALL LENGTH',
      isActive: isLenActive,
      pulseFactor: pulseFactor,
      labelOffset: const Offset(0, -10),
    );

    // Wall Height Line (Right)
    final hVal = values['wallHeight'] ?? values['height'] ?? '';
    _paintDimensionLine(
      canvas: canvas,
      start: Offset(right + 14, top),
      end: Offset(right + 14, bottom),
      label: hVal.isNotEmpty ? 'Height: $hVal' : 'WALL HEIGHT',
      isActive: isHeightActive,
      pulseFactor: pulseFactor,
      labelOffset: const Offset(20, 0),
    );
  }

  void _paintDimensionLine({
    required Canvas canvas,
    required Offset start,
    required Offset end,
    required String label,
    required bool isActive,
    required double pulseFactor,
    required Offset labelOffset,
  }) {
    final color = isActive
        ? AppColors.brandGold
        : const Color(0xFF64748B);
    final strokeWidth = isActive ? 2.2 : 1.2;

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Line
    canvas.drawLine(start, end, linePaint);

    // Arrowheads / Ticks
    _drawArrowOrTick(canvas, start, end, linePaint, isActive);
    _drawArrowOrTick(canvas, end, start, linePaint, isActive);

    // Glowing Badge / Text Label at Center
    final mid = Offset((start.dx + end.dx) * 0.5 + labelOffset.dx, (start.dy + end.dy) * 0.5 + labelOffset.dy);

    final textSpan = TextSpan(
      text: label,
      style: TextStyle(
        color: isActive ? AppColors.brandGold : const Color(0xFF94A3B8),
        fontSize: isActive ? 10 : 9,
        fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
        letterSpacing: 0.3,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    final badgeRect = Rect.fromCenter(
      center: mid,
      width: textPainter.width + (isActive ? 12 : 8),
      height: textPainter.height + 4,
    );

    final bgBadge = Paint()
      ..color = isActive
          ? AppColors.bgSurface.withValues(alpha: 0.95)
          : const Color(0xFF0F172A).withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;
    final borderBadge = Paint()
      ..color = isActive
          ? AppColors.brandGold.withValues(alpha: 0.7 + 0.3 * pulseFactor)
          : const Color(0xFF334155)
      ..strokeWidth = isActive ? 1.2 : 0.8
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(RRect.fromRectAndRadius(badgeRect, const Radius.circular(4)), bgBadge);
    canvas.drawRRect(RRect.fromRectAndRadius(badgeRect, const Radius.circular(4)), borderBadge);

    textPainter.paint(canvas, Offset(mid.dx - textPainter.width * 0.5, mid.dy - textPainter.height * 0.5));
  }

  void _drawArrowOrTick(Canvas canvas, Offset p, Offset towards, Paint paint, bool isActive) {
    final dx = towards.dx - p.dx;
    final dy = towards.dy - p.dy;
    final len = (dx * dx + dy * dy);
    if (len == 0) return;

    // Perpendicular Tick
    final perpX = -dy / (len > 0 ? (dx * dx + dy * dy) : 1);
    final perpY = dx / (len > 0 ? (dx * dx + dy * dy) : 1);
    final tickLen = isActive ? 5.0 : 3.5;

    canvas.drawLine(
      Offset(p.dx - perpX * tickLen * 5, p.dy - perpY * tickLen * 5),
      Offset(p.dx + perpX * tickLen * 5, p.dy + perpY * tickLen * 5),
      paint,
    );
  }

  void _paintSlopeTriangle({
    required Canvas canvas,
    required Offset origin,
    required String pitchText,
    required bool isActive,
    required double pulseFactor,
  }) {
    final color = isActive ? AppColors.brandGold : const Color(0xFF64748B);
    final paint = Paint()
      ..color = color
      ..strokeWidth = isActive ? 1.8 : 1.0
      ..style = PaintingStyle.stroke;

    const triW = 20.0;
    const triH = 10.0;

    final path = Path()
      ..moveTo(origin.dx, origin.dy)
      ..lineTo(origin.dx + triW, origin.dy)
      ..lineTo(origin.dx + triW, origin.dy - triH)
      ..close();

    canvas.drawPath(path, paint);

    final textSpan = TextSpan(
      text: pitchText,
      style: TextStyle(
        color: color,
        fontSize: 9,
        fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
      ),
    );

    final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr)..layout();
    tp.paint(canvas, Offset(origin.dx + 2, origin.dy - triH - 12));
  }

  @override
  bool shouldRepaint(covariant _DynamicGuidePainter oldDelegate) {
    return oldDelegate.type != type ||
        oldDelegate.activeDimension != activeDimension ||
        oldDelegate.pulseFactor != pulseFactor ||
        oldDelegate.values != values;
  }
}
