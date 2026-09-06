import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_radii.dart';
import '../../math/measurement.dart';

/// Selectable measurement modes for the interactive roof diagram.
enum RoofMeasurementMode {
  pitch,
  run,
  overhang,
  rafterLength,
}

/// Reusable interactive roof blueprint diagram that visually explains roof geometry
/// and dynamically highlights selectable measurements (Pitch, Run, Overhang, Rafter Length).
class BuildCalcRoofDiagram extends StatefulWidget {
  final RoofPitch pitch;
  final Length run;
  final Length rise;
  final Length overhang;
  final Length rafterLength;
  final RoofMeasurementMode activeMeasurement;
  final ValueChanged<RoofMeasurementMode>? onMeasurementSelected;
  final bool isMetric;
  final double height;

  const BuildCalcRoofDiagram({
    super.key,
    required this.pitch,
    required this.run,
    required this.rise,
    required this.overhang,
    required this.rafterLength,
    required this.activeMeasurement,
    this.onMeasurementSelected,
    this.isMetric = false,
    this.height = 200,
  });

  @override
  State<BuildCalcRoofDiagram> createState() => _BuildCalcRoofDiagramState();
}

class _BuildCalcRoofDiagramState extends State<BuildCalcRoofDiagram> with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
      value: 1.0,
    );
  }

  @override
  void didUpdateWidget(covariant BuildCalcRoofDiagram oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeMeasurement != widget.activeMeasurement ||
        oldWidget.pitch.riseIn12 != widget.pitch.riseIn12 ||
        oldWidget.run != widget.run ||
        oldWidget.overhang != widget.overhang) {
      _animCtrl.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  String _formatValue(RoofMeasurementMode mode) {
    switch (mode) {
      case RoofMeasurementMode.pitch:
        return widget.pitch.pitchNotation;
      case RoofMeasurementMode.run:
        return widget.isMetric
            ? '${widget.run.toMeters().toStringAsFixed(2)} m'
            : widget.run.toFeetInchesFraction();
      case RoofMeasurementMode.overhang:
        return widget.isMetric
            ? '${(widget.overhang.toMillimeters() / 10).round()} cm'
            : widget.overhang.toInchesFraction();
      case RoofMeasurementMode.rafterLength:
        return widget.isMetric
            ? '${widget.rafterLength.toMeters().toStringAsFixed(3)} m'
            : widget.rafterLength.toFeetInchesFraction();
    }
  }

  _ModeExplanation _getExplanation(RoofMeasurementMode mode) {
    switch (mode) {
      case RoofMeasurementMode.pitch:
        final riseNum = widget.pitch.riseIn12 % 1 == 0
            ? widget.pitch.riseIn12.toInt().toString()
            : widget.pitch.riseIn12.toStringAsFixed(1);
        return _ModeExplanation(
          title: 'PITCH',
          valueText: '${widget.pitch.pitchNotation} (${widget.pitch.pitchDegrees.toStringAsFixed(1)}°)',
          description: '$riseNum" vertical rise for every 12" of horizontal run.',
        );
      case RoofMeasurementMode.run:
        return _ModeExplanation(
          title: 'HORIZONTAL RUN',
          valueText: _formatValue(RoofMeasurementMode.run),
          description: 'Horizontal distance from the ridge plumb reference to the wall reference.',
        );
      case RoofMeasurementMode.overhang:
        return _ModeExplanation(
          title: 'EAVE OVERHANG',
          valueText: _formatValue(RoofMeasurementMode.overhang),
          description: 'Horizontal projection of the roof rafter beyond the exterior wall line.',
        );
      case RoofMeasurementMode.rafterLength:
        return _ModeExplanation(
          title: 'RAFTER LENGTH',
          valueText: _formatValue(RoofMeasurementMode.rafterLength),
          description: 'True sloped line length of the common rafter from ridge peak to wall plate.',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final explanation = _getExplanation(widget.activeMeasurement);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: AppRadii.cardRadius,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Category Title + Active Mode Badge
          Padding(
            padding: const EdgeInsets.only(left: 14, right: 14, top: 12, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.roofing_outlined,
                      size: 18,
                      color: AppColors.brandGold,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'COMMON RAFTER',
                      style: AppTypography.inputText.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.brandGold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.brandGold.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    explanation.title,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brandGold,
                      letterSpacing: 0.3,
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
                height: widget.height,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1219),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF1E293B)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CustomPaint(
                    painter: _RoofBlueprintPainter(
                      pitch: widget.pitch,
                      run: widget.run,
                      rise: widget.rise,
                      overhang: widget.overhang,
                      rafterLength: widget.rafterLength,
                      activeMeasurement: widget.activeMeasurement,
                      pulseFactor: _animCtrl.value,
                      isMetric: widget.isMetric,
                    ),
                    size: Size.infinite,
                  ),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                _buildModeButton(RoofMeasurementMode.pitch, 'Pitch'),
                const SizedBox(width: 6),
                _buildModeButton(RoofMeasurementMode.run, 'Run'),
                const SizedBox(width: 6),
                _buildModeButton(RoofMeasurementMode.overhang, 'Overhang'),
                const SizedBox(width: 6),
                _buildModeButton(RoofMeasurementMode.rafterLength, 'Rafter'),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 10, right: 10, bottom: 12, top: 2),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.bgElevated,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: AppColors.brandGold,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            explanation.title,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.brandGold,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            explanation.valueText,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        explanation.description,
                        style: AppTypography.helperText.copyWith(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton(RoofMeasurementMode mode, String label) {
    final isActive = widget.activeMeasurement == mode;
    final valStr = _formatValue(mode);

    return Expanded(
      child: Semantics(
        button: true,
        selected: isActive,
        label: '$label: $valStr',
        child: InkWell(
          onTap: () => widget.onMeasurementSelected?.call(mode),
          borderRadius: BorderRadius.circular(6),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.brandGold.withValues(alpha: 0.18)
                  : AppColors.bgElevated,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isActive ? AppColors.brandGold : AppColors.borderSubtle,
                width: isActive ? 1.5 : 1.0,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive ? AppColors.brandGold : AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                          color: isActive ? AppColors.brandGold : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  valStr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isActive ? AppColors.textPrimary : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeExplanation {
  final String title;
  final String valueText;
  final String description;

  const _ModeExplanation({
    required this.title,
    required this.valueText,
    required this.description,
  });
}

/// CustomPainter rendering proportional roof geometry and active mode highlight.
class _RoofBlueprintPainter extends CustomPainter {
  final RoofPitch pitch;
  final Length run;
  final Length rise;
  final Length overhang;
  final Length rafterLength;
  final RoofMeasurementMode activeMeasurement;
  final double pulseFactor;
  final bool isMetric;

  const _RoofBlueprintPainter({
    required this.pitch,
    required this.run,
    required this.rise,
    required this.overhang,
    required this.rafterLength,
    required this.activeMeasurement,
    required this.pulseFactor,
    required this.isMetric,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Subtle Blueprint Grid
    _paintGrid(canvas, size);

    // 2. Proportional Geometry Calculations
    final runInches = run.toInches().clamp(12.0, 600.0);
    final pitchRise = pitch.riseIn12.clamp(1.0, 24.0);
    final overhangInches = overhang.toInches().clamp(0.0, runInches * 0.5);

    // Centered symmetrical truss with safe margins to prevent any edge clipping
    final centerRidgeX = size.width * 0.50;
    final rawOverhangW = (overhangInches / runInches) * (size.width * 0.28);
    final overhangVisualW = rawOverhangW.clamp(38.0, 52.0);
    // Allow at least 52px margin on left and right borders
    final sideMargin = math.max(52.0, size.width * 0.12);
    final runVisualW = centerRidgeX - sideMargin - overhangVisualW;

    final wallLeftX = centerRidgeX - runVisualW;
    final wallRightX = centerRidgeX + runVisualW;
    final eavesLeftX = wallLeftX - overhangVisualW;
    final eavesRightX = wallRightX + overhangVisualW;

    // Visual rise proportional to pitch
    final slopeRatio = (pitchRise / 12.0);
    final visualRiseH = (runVisualW * slopeRatio * 0.88).clamp(28.0, size.height * 0.42);

    final wallPlateY = size.height * 0.52;
    final ridgeY = wallPlateY - visualRiseH;
    final visualSlope = visualRiseH / runVisualW;

    final eavesLeftY = wallPlateY + (overhangVisualW * visualSlope);
    final eavesRightY = eavesLeftY;

    final pRidge = Offset(centerRidgeX, ridgeY);
    final pWallLeft = Offset(wallLeftX, wallPlateY);
    final pWallRight = Offset(wallRightX, wallPlateY);
    final pEavesLeft = Offset(eavesLeftX, eavesLeftY);
    final pEavesRight = Offset(eavesRightX, eavesRightY);

    final isPitch = activeMeasurement == RoofMeasurementMode.pitch;
    final isRun = activeMeasurement == RoofMeasurementMode.run;
    final isOverhang = activeMeasurement == RoofMeasurementMode.overhang;
    final isRafter = activeMeasurement == RoofMeasurementMode.rafterLength;

    // 3. Draw Blueprint Reference Planes & Guidelines
    final bottomRefY = size.height - 18.0;

    // Center Plumb Line
    _drawDashedVerticalLine(
      canvas,
      centerRidgeX,
      ridgeY,
      bottomRefY,
      isRun || isRafter ? AppColors.brandGold.withValues(alpha: 0.7) : const Color(0xFF2A374A),
    );
    _drawReferenceLabel(
      canvas,
      Offset(centerRidgeX, bottomRefY + 4),
      'RIDGE PLUMB',
      isRun || isRafter,
    );

    // Wall Reference Line
    _drawDashedVerticalLine(
      canvas,
      wallLeftX,
      wallPlateY,
      bottomRefY,
      isRun || isOverhang || isRafter ? AppColors.brandGold.withValues(alpha: 0.7) : const Color(0xFF2A374A),
    );
    _drawReferenceLabel(
      canvas,
      Offset(wallLeftX, bottomRefY + 4),
      'WALL',
      isRun || isOverhang || isRafter,
    );

    // Eave Reference Line
    _drawDashedVerticalLine(
      canvas,
      eavesLeftX,
      eavesLeftY,
      bottomRefY,
      isOverhang ? AppColors.brandGold.withValues(alpha: 0.7) : const Color(0xFF2A374A),
    );
    _drawReferenceLabel(
      canvas,
      Offset(eavesLeftX, bottomRefY + 4),
      'EAVE',
      isOverhang,
    );

    // Structural Wall Studs & Tie Beam (Technical Blueprint lines, strictly STROKE)
    final studPaint = Paint()
      ..color = const Color(0xFF334155)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(pWallLeft, Offset(pWallLeft.dx, wallPlateY + 28), studPaint);
    canvas.drawLine(pWallRight, Offset(pWallRight.dx, wallPlateY + 28), studPaint);

    final tieBeamPaint = Paint()
      ..color = const Color(0xFF2A374A)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(pWallLeft, pWallRight, tieBeamPaint);

    // 4. Draw Inactive Roof Skeleton (STROKE ONLY)
    final skeletonPaint = Paint()
      ..color = const Color(0xFF475569)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final roofPath = Path()
      ..moveTo(pEavesLeft.dx, pEavesLeft.dy)
      ..lineTo(pRidge.dx, pRidge.dy)
      ..lineTo(pEavesRight.dx, pEavesRight.dy);
    canvas.drawPath(roofPath, skeletonPaint);

    // 5. Dimension Elevation Baseline Y (Clean vertical gap below wallPlateY)
    final dimY = wallPlateY + 22.0;

    // --- A. PITCH MODE ---
    if (isPitch) {
      _paintPitchIndicator(
        canvas: canvas,
        size: size,
        rafterStart: pEavesLeft,
        rafterEnd: pRidge,
        isActive: true,
      );
    }

    // --- B. RUN MODE ---
    if (isRun) {
      final runValStr = isMetric ? '${run.toMeters().toStringAsFixed(2)} m' : run.toFeetInchesFraction();
      _paintDimensionLine(
        canvas: canvas,
        size: size,
        start: Offset(pWallLeft.dx, dimY),
        end: Offset(pRidge.dx, dimY),
        label: 'RUN: $runValStr',
        isActive: true,
        pulseFactor: pulseFactor,
      );
    }

    // --- C. OVERHANG MODE ---
    if (isOverhang) {
      final overValStr = isMetric ? '${(overhang.toMillimeters() / 10).round()} cm' : overhang.toInchesFraction();
      _paintDimensionLine(
        canvas: canvas,
        size: size,
        start: Offset(pEavesLeft.dx, dimY),
        end: Offset(pWallLeft.dx, dimY),
        label: 'OVERHANG: $overValStr',
        isActive: true,
        pulseFactor: pulseFactor,
      );
    }

    // --- D. RAFTER LENGTH MODE ---
    if (isRafter) {
      // Highlight the sloped rafter line from ridge to wall with gold glow
      final rafterGlowPaint = Paint()
        ..color = AppColors.brandGold.withValues(alpha: 0.25 + 0.15 * pulseFactor)
        ..strokeWidth = 5.0
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      canvas.drawLine(pWallLeft, pRidge, rafterGlowPaint);

      final rafterGoldPaint = Paint()
        ..color = AppColors.brandGold
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      canvas.drawLine(pWallLeft, pRidge, rafterGoldPaint);

      // Sloped dimension line parallel to rafter
      final rafterValStr = isMetric ? '${rafterLength.toMeters().toStringAsFixed(3)} m' : rafterLength.toFeetInchesFraction();
      _paintSlopedDimension(
        canvas: canvas,
        size: size,
        start: pWallLeft,
        end: pRidge,
        label: 'RAFTER: $rafterValStr',
        pulseFactor: pulseFactor,
      );
    }

    // 6. Draw Reference Nodes for Active Mode
    if (isRun) {
      _drawNode(canvas, pRidge, true);
      _drawNode(canvas, pWallLeft, true);
    } else if (isOverhang) {
      _drawNode(canvas, pEavesLeft, true);
      _drawNode(canvas, pWallLeft, true);
    } else if (isRafter) {
      _drawNode(canvas, pRidge, true);
      _drawNode(canvas, pWallLeft, true);
    }
  }

  void _paintGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFF1E293B).withValues(alpha: 0.45)
      ..strokeWidth = 0.5;

    const step = 16.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  void _drawDashedVerticalLine(Canvas canvas, double x, double startY, double endY, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0;

    const dashH = 4.0;
    const spaceH = 3.0;
    double currentY = startY;
    while (currentY < endY) {
      final y2 = (currentY + dashH).clamp(startY, endY);
      canvas.drawLine(Offset(x, currentY), Offset(x, y2), paint);
      currentY += dashH + spaceH;
    }
  }

  void _drawReferenceLabel(Canvas canvas, Offset p, String label, bool isActive) {
    final textSpan = TextSpan(
      text: label,
      style: TextStyle(
        fontSize: 8.5,
        fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
        color: isActive ? AppColors.brandGold : const Color(0xFF64748B),
        letterSpacing: 0.4,
      ),
    );
    final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr)..layout();
    tp.paint(canvas, Offset(p.dx - tp.width * 0.5, p.dy));
  }

  void _paintPitchIndicator({
    required Canvas canvas,
    required Size size,
    required Offset rafterStart,
    required Offset rafterEnd,
    required bool isActive,
  }) {
    final dx = rafterEnd.dx - rafterStart.dx;
    final dy = rafterStart.dy - rafterEnd.dy;
    final slope = dx > 0 ? (dy / dx) : 0.6;

    final mid = Offset(
      (rafterStart.dx + rafterEnd.dx) * 0.5,
      (rafterStart.dy + rafterEnd.dy) * 0.5,
    );

    const triW = 38.0;
    final triH = triW * slope;

    final p0 = Offset(mid.dx - triW * 0.5 - 4, mid.dy - triH - 8);
    final p1 = Offset(p0.dx + triW, p0.dy);
    final p2 = Offset(p0.dx + triW, p0.dy + triH);

    final path = Path()
      ..moveTo(p0.dx, p0.dy)
      ..lineTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..close();

    final fillPaint = Paint()
      ..color = AppColors.brandGold.withValues(alpha: 0.15 + 0.1 * pulseFactor)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    final strokePaint = Paint()
      ..color = AppColors.brandGold
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, strokePaint);

    // Right-angle symbol at P1
    const sqSize = 5.0;
    final sqPath = Path()
      ..moveTo(p1.dx - sqSize, p1.dy)
      ..lineTo(p1.dx - sqSize, p1.dy + sqSize)
      ..lineTo(p1.dx, p1.dy + sqSize);
    canvas.drawPath(sqPath, strokePaint..strokeWidth = 1.0);

    // Horizontal run leg annotation (12")
    final run12Span = const TextSpan(
      text: '12"',
      style: TextStyle(
        color: AppColors.brandGold,
        fontSize: 8.5,
        fontWeight: FontWeight.w700,
      ),
    );
    final run12Tp = TextPainter(text: run12Span, textDirection: TextDirection.ltr)..layout();
    run12Tp.paint(canvas, Offset(p0.dx + (triW - run12Tp.width) * 0.5, p0.dy - 10));

    // Vertical rise leg annotation (e.g. 4")
    final riseNum = pitch.riseIn12 % 1 == 0
        ? pitch.riseIn12.toInt().toString()
        : pitch.riseIn12.toStringAsFixed(1);
    final riseSpan = TextSpan(
      text: '$riseNum"',
      style: const TextStyle(
        color: AppColors.brandGold,
        fontSize: 8.5,
        fontWeight: FontWeight.w700,
      ),
    );
    final riseTp = TextPainter(text: riseSpan, textDirection: TextDirection.ltr)..layout();
    riseTp.paint(canvas, Offset(p1.dx + 4, p0.dy + (triH - riseTp.height) * 0.5));

    // Dimension text badge above triangle
    final pitchText = '${pitch.pitchNotation} (${pitch.pitchDegrees.toStringAsFixed(1)}°)';
    final textSpan = TextSpan(
      text: 'PITCH: $pitchText',
      style: const TextStyle(
        color: AppColors.brandGold,
        fontSize: 11.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.4,
      ),
    );

    final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr)..layout();
    final badgeWidth = tp.width + 16;
    final badgeHeight = tp.height + 6;

    // Clamp badge safely within canvas boundaries
    final rawCenterX = p0.dx + triW * 0.5;
    final clampedCenterX = rawCenterX.clamp(badgeWidth * 0.5 + 8, size.width - badgeWidth * 0.5 - 8);
    final badgeCenter = Offset(clampedCenterX, p0.dy - 20);

    final badgeRect = Rect.fromCenter(
      center: badgeCenter,
      width: badgeWidth,
      height: badgeHeight,
    );

    final glowBadge = Paint()
      ..color = AppColors.brandGold.withValues(alpha: 0.15 + 0.1 * pulseFactor)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(badgeRect.inflate(3), const Radius.circular(6)), glowBadge);

    final bgBadge = Paint()
      ..color = AppColors.bgSurface.withValues(alpha: 0.95)
      ..style = PaintingStyle.fill;
    final borderBadge = Paint()
      ..color = AppColors.brandGold.withValues(alpha: 0.8 + 0.2 * pulseFactor)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(RRect.fromRectAndRadius(badgeRect, const Radius.circular(4)), bgBadge);
    canvas.drawRRect(RRect.fromRectAndRadius(badgeRect, const Radius.circular(4)), borderBadge);

    tp.paint(canvas, Offset(badgeCenter.dx - tp.width * 0.5, badgeCenter.dy - tp.height * 0.5));
  }

  void _paintDimensionLine({
    required Canvas canvas,
    required Size size,
    required Offset start,
    required Offset end,
    required String label,
    required bool isActive,
    required double pulseFactor,
    Offset labelOffset = Offset.zero,
  }) {
    final color = AppColors.brandGold;
    final strokeWidth = 2.5;

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(start, end, linePaint);
    _drawArrowOrTick(canvas, start, end, linePaint, isActive);
    _drawArrowOrTick(canvas, end, start, linePaint, isActive);

    final textSpan = TextSpan(
      text: label,
      style: const TextStyle(
        color: AppColors.brandGold,
        fontSize: 11.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.4,
      ),
    );

    final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr)..layout();
    final badgeWidth = textPainter.width + 16;
    final badgeHeight = textPainter.height + 6;

    final rawMidX = (start.dx + end.dx) * 0.5 + labelOffset.dx;
    // Strictly clamp the badge within canvas to guarantee NO clipping
    final clampedMidX = rawMidX.clamp(badgeWidth * 0.5 + 8, size.width - badgeWidth * 0.5 - 8);
    final mid = Offset(clampedMidX, (start.dy + end.dy) * 0.5 + labelOffset.dy);

    final badgeRect = Rect.fromCenter(
      center: mid,
      width: badgeWidth,
      height: badgeHeight,
    );

    final glowBadge = Paint()
      ..color = AppColors.brandGold.withValues(alpha: 0.15 + 0.1 * pulseFactor)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(badgeRect.inflate(3), const Radius.circular(6)), glowBadge);

    final bgBadge = Paint()
      ..color = AppColors.bgSurface.withValues(alpha: 0.95)
      ..style = PaintingStyle.fill;
    final borderBadge = Paint()
      ..color = AppColors.brandGold.withValues(alpha: 0.8 + 0.2 * pulseFactor)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(RRect.fromRectAndRadius(badgeRect, const Radius.circular(4)), bgBadge);
    canvas.drawRRect(RRect.fromRectAndRadius(badgeRect, const Radius.circular(4)), borderBadge);

    textPainter.paint(canvas, Offset(mid.dx - textPainter.width * 0.5, mid.dy - textPainter.height * 0.5));
  }

  void _paintSlopedDimension({
    required Canvas canvas,
    required Size size,
    required Offset start,
    required Offset end,
    required String label,
    required double pulseFactor,
  }) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final len = math.sqrt(dx * dx + dy * dy);
    if (len == 0) return;

    const offsetDist = 18.0;
    final perp = Offset(dy / len * offsetDist, -dx / len * offsetDist);

    final oStart = Offset(start.dx + perp.dx, start.dy + perp.dy);
    final oEnd = Offset(end.dx + perp.dx, end.dy + perp.dy);

    final linePaint = Paint()
      ..color = AppColors.brandGold
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(oStart, oEnd, linePaint);
    _drawArrowOrTick(canvas, oStart, oEnd, linePaint, true);
    _drawArrowOrTick(canvas, oEnd, oStart, linePaint, true);

    final mid = Offset((oStart.dx + oEnd.dx) * 0.5 + perp.dx * 0.6, (oStart.dy + oEnd.dy) * 0.5 + perp.dy * 0.6);

    final textSpan = TextSpan(
      text: label,
      style: const TextStyle(
        color: AppColors.brandGold,
        fontSize: 11.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.4,
      ),
    );

    final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr)..layout();
    final badgeRect = Rect.fromCenter(
      center: Offset.zero,
      width: tp.width + 16,
      height: tp.height + 6,
    );

    canvas.save();
    canvas.translate(mid.dx, mid.dy);
    double rot = math.atan2(dy, dx);
    if (rot > math.pi / 2) {
      rot -= math.pi;
    } else if (rot < -math.pi / 2) {
      rot += math.pi;
    }
    canvas.rotate(rot);

    final glowBadge = Paint()
      ..color = AppColors.brandGold.withValues(alpha: 0.15 + 0.1 * pulseFactor)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(badgeRect.inflate(3), const Radius.circular(6)), glowBadge);

    final bgBadge = Paint()
      ..color = AppColors.bgSurface.withValues(alpha: 0.95)
      ..style = PaintingStyle.fill;
    final borderBadge = Paint()
      ..color = AppColors.brandGold.withValues(alpha: 0.8 + 0.2 * pulseFactor)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(RRect.fromRectAndRadius(badgeRect, const Radius.circular(4)), bgBadge);
    canvas.drawRRect(RRect.fromRectAndRadius(badgeRect, const Radius.circular(4)), borderBadge);

    tp.paint(canvas, Offset(-tp.width * 0.5, -tp.height * 0.5));
    canvas.restore();
  }

  void _drawNode(Canvas canvas, Offset p, bool isActive) {
    final dotPaint = Paint()
      ..color = isActive ? AppColors.brandGold : const Color(0xFF64748B)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(p, isActive ? 4.0 : 3.0, dotPaint);

    if (isActive) {
      final ringPaint = Paint()
        ..color = AppColors.brandGold.withValues(alpha: 0.4)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(p, 7.0, ringPaint);
    }
  }

  void _drawArrowOrTick(Canvas canvas, Offset p, Offset towards, Paint paint, bool isActive) {
    final dx = towards.dx - p.dx;
    final dy = towards.dy - p.dy;
    final len = (dx * dx + dy * dy);
    if (len == 0) return;

    final perpX = -dy / (len > 0 ? (dx * dx + dy * dy) : 1);
    final perpY = dx / (len > 0 ? (dx * dx + dy * dy) : 1);
    final tickLen = isActive ? 7.0 : 4.5;

    canvas.drawLine(
      Offset(p.dx - perpX * tickLen * 5, p.dy - perpY * tickLen * 5),
      Offset(p.dx + perpX * tickLen * 5, p.dy + perpY * tickLen * 5),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _RoofBlueprintPainter oldDelegate) {
    return oldDelegate.pitch != pitch ||
        oldDelegate.run != run ||
        oldDelegate.rise != rise ||
        oldDelegate.overhang != overhang ||
        oldDelegate.rafterLength != rafterLength ||
        oldDelegate.activeMeasurement != activeMeasurement ||
        oldDelegate.pulseFactor != pulseFactor ||
        oldDelegate.isMetric != isMetric;
  }
}
