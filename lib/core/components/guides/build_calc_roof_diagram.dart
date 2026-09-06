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

          // Selectable Measurement Controls: [ Pitch ] [ Run ] [ Overhang ] [ Rafter Length ]
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
                _buildModeButton(RoofMeasurementMode.rafterLength, 'Rafter Length'),
              ],
            ),
          ),

          // Short Explanation Block for the Active Measurement
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

    final wallLeftX = size.width * 0.24;
    final centerRidgeX = size.width * 0.50;
    final wallRightX = size.width * 0.76;
    final runVisualW = centerRidgeX - wallLeftX;

    // Visual rise proportional to pitch
    final slopeRatio = (pitchRise / 12.0);
    final visualRiseH = (runVisualW * slopeRatio * 0.95).clamp(26.0, size.height * 0.44);

    final wallPlateY = size.height * 0.60;
    final ridgeY = wallPlateY - visualRiseH;

    // Overhang proportional width
    final overhangRatio = (overhangInches / runInches).clamp(0.06, 0.40);
    final overhangVisualW = runVisualW * overhangRatio;
    final visualSlope = visualRiseH / runVisualW;

    final eavesLeftX = wallLeftX - overhangVisualW;
    final eavesLeftY = wallPlateY + (overhangVisualW * visualSlope);
    final eavesRightX = wallRightX + overhangVisualW;
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

    // 3. Draw Inactive Roof Skeleton & Stud Walls
    final skeletonPaint = Paint()
      ..color = const Color(0xFF475569)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final wallPaint = Paint()
      ..color = const Color(0xFF334155)
      ..strokeWidth = 1.5;

    // Wall Studs
    canvas.drawLine(pWallLeft, Offset(pWallLeft.dx, pWallLeft.dy + 32), wallPaint);
    canvas.drawLine(pWallRight, Offset(pWallRight.dx, pWallRight.dy + 32), wallPaint);

    // Center Plumb Line (dashed / subtle)
    final plumbPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 1.0;
    canvas.drawLine(pRidge, Offset(pRidge.dx, wallPlateY + 32), plumbPaint);

    // Base Rafter Profile
    final roofPath = Path()
      ..moveTo(pEavesLeft.dx, pEavesLeft.dy)
      ..lineTo(pRidge.dx, pRidge.dy)
      ..lineTo(pEavesRight.dx, pEavesRight.dy);
    canvas.drawPath(roofPath, skeletonPaint);

    // 4. Dimension Elevation Baseline Y
    final dimY = wallPlateY + 18.0;

    // 5. Draw Active Dimension Visualizations

    // --- A. PITCH MODE ---
    _paintPitchIndicator(
      canvas: canvas,
      rafterStart: pEavesLeft,
      rafterEnd: pRidge,
      isActive: isPitch,
    );

    // --- B. RUN MODE ---
    final runValStr = isMetric ? '${run.toMeters().toStringAsFixed(2)} m' : run.toFeetInchesFraction();
    _paintDimensionLine(
      canvas: canvas,
      start: Offset(pWallLeft.dx, dimY),
      end: Offset(pRidge.dx, dimY),
      label: 'RUN: $runValStr',
      isActive: isRun,
      pulseFactor: pulseFactor,
      labelOffset: const Offset(0, 14),
    );

    // --- C. OVERHANG MODE ---
    final overValStr = isMetric ? '${(overhang.toMillimeters() / 10).round()} cm' : overhang.toInchesFraction();
    _paintDimensionLine(
      canvas: canvas,
      start: Offset(pEavesLeft.dx, dimY),
      end: Offset(pWallLeft.dx, dimY),
      label: 'OVERHANG: $overValStr',
      isActive: isOverhang,
      pulseFactor: pulseFactor,
      labelOffset: const Offset(0, 14),
    );

    // --- D. RAFTER LENGTH MODE ---
    if (isRafter) {
      // Highlight the sloped rafter line with gold glow
      final rafterGlowPaint = Paint()
        ..color = AppColors.brandGold.withValues(alpha: 0.25 + 0.15 * pulseFactor)
        ..strokeWidth = 5.0
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(pWallLeft, pRidge, rafterGlowPaint);

      final rafterGoldPaint = Paint()
        ..color = AppColors.brandGold
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(pWallLeft, pRidge, rafterGoldPaint);

      // Sloped dimension line parallel to rafter
      final rafterValStr = isMetric ? '${rafterLength.toMeters().toStringAsFixed(3)} m' : rafterLength.toFeetInchesFraction();
      _paintSlopedDimension(
        canvas: canvas,
        start: pWallLeft,
        end: pRidge,
        label: 'RAFTER: $rafterValStr',
        pulseFactor: pulseFactor,
      );
    }

    // 6. Draw Reference Nodes (Ridge ●, Wall ●, Eaves ●)
    _drawNode(canvas, pRidge, isRun || isRafter);
    _drawNode(canvas, pWallLeft, isRun || isOverhang || isRafter);
    _drawNode(canvas, pEavesLeft, isOverhang);
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

  void _paintPitchIndicator({
    required Canvas canvas,
    required Offset rafterStart,
    required Offset rafterEnd,
    required bool isActive,
  }) {
    final color = isActive ? AppColors.brandGold : const Color(0xFF64748B);

    final dx = rafterEnd.dx - rafterStart.dx;
    final dy = rafterStart.dy - rafterEnd.dy;
    final slope = dx > 0 ? (dy / dx) : 0.6;

    final mid = Offset(
      (rafterStart.dx + rafterEnd.dx) * 0.5,
      (rafterStart.dy + rafterEnd.dy) * 0.5,
    );

    const triW = 34.0;
    final triH = triW * slope;

    final p0 = Offset(mid.dx - triW * 0.5 - 4, mid.dy - triH - 8);
    final p1 = Offset(p0.dx + triW, p0.dy);
    final p2 = Offset(p0.dx + triW, p0.dy + triH);

    final path = Path()
      ..moveTo(p0.dx, p0.dy)
      ..lineTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..close();

    if (isActive) {
      final fillPaint = Paint()
        ..color = AppColors.brandGold.withValues(alpha: 0.15 + 0.1 * pulseFactor)
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, fillPaint);
    }

    final strokePaint = Paint()
      ..color = color
      ..strokeWidth = isActive ? 2.2 : 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, strokePaint);

    // Right-angle symbol at P1
    const sqSize = 5.0;
    final sqPath = Path()
      ..moveTo(p1.dx - sqSize, p1.dy)
      ..lineTo(p1.dx - sqSize, p1.dy + sqSize)
      ..lineTo(p1.dx, p1.dy + sqSize);
    canvas.drawPath(sqPath, strokePaint..strokeWidth = 1.0);

    // Dimension text badge above triangle
    final pitchText = pitch.pitchNotation;
    final textSpan = TextSpan(
      text: 'PITCH: $pitchText',
      style: TextStyle(
        color: isActive ? AppColors.brandGold : const Color(0xFF94A3B8),
        fontSize: isActive ? 12.5 : 10.0,
        fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
        letterSpacing: 0.4,
      ),
    );

    final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr)..layout();
    final badgeCenter = Offset(p0.dx + triW * 0.5, p0.dy - 12);

    final badgeRect = Rect.fromCenter(
      center: badgeCenter,
      width: tp.width + (isActive ? 16 : 8),
      height: tp.height + (isActive ? 6 : 4),
    );

    if (isActive) {
      final glowBadge = Paint()
        ..color = AppColors.brandGold.withValues(alpha: 0.15 + 0.1 * pulseFactor)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(RRect.fromRectAndRadius(badgeRect.inflate(3), const Radius.circular(6)), glowBadge);
    }

    final bgBadge = Paint()
      ..color = isActive
          ? AppColors.bgSurface.withValues(alpha: 0.95)
          : const Color(0xFF0F172A).withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;
    final borderBadge = Paint()
      ..color = isActive
          ? AppColors.brandGold.withValues(alpha: 0.8 + 0.2 * pulseFactor)
          : const Color(0xFF334155)
      ..strokeWidth = isActive ? 1.6 : 0.8
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(RRect.fromRectAndRadius(badgeRect, const Radius.circular(4)), bgBadge);
    canvas.drawRRect(RRect.fromRectAndRadius(badgeRect, const Radius.circular(4)), borderBadge);

    tp.paint(canvas, Offset(badgeCenter.dx - tp.width * 0.5, badgeCenter.dy - tp.height * 0.5));
  }

  void _paintDimensionLine({
    required Canvas canvas,
    required Offset start,
    required Offset end,
    required String label,
    required bool isActive,
    required double pulseFactor,
    Offset labelOffset = Offset.zero,
  }) {
    final color = isActive ? AppColors.brandGold : const Color(0xFF64748B);
    final strokeWidth = isActive ? 3.0 : 1.4;

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(start, end, linePaint);
    _drawArrowOrTick(canvas, start, end, linePaint, isActive);
    _drawArrowOrTick(canvas, end, start, linePaint, isActive);

    final mid = Offset((start.dx + end.dx) * 0.5 + labelOffset.dx, (start.dy + end.dy) * 0.5 + labelOffset.dy);

    final textSpan = TextSpan(
      text: label,
      style: TextStyle(
        color: isActive ? AppColors.brandGold : const Color(0xFF94A3B8),
        fontSize: isActive ? 12.5 : 10.0,
        fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
        letterSpacing: 0.4,
      ),
    );

    final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr)..layout();
    final badgeRect = Rect.fromCenter(
      center: mid,
      width: textPainter.width + (isActive ? 16 : 8),
      height: textPainter.height + (isActive ? 6 : 4),
    );

    if (isActive) {
      final glowBadge = Paint()
        ..color = AppColors.brandGold.withValues(alpha: 0.15 + 0.1 * pulseFactor)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(RRect.fromRectAndRadius(badgeRect.inflate(3), const Radius.circular(6)), glowBadge);
    }

    final bgBadge = Paint()
      ..color = isActive
          ? AppColors.bgSurface.withValues(alpha: 0.95)
          : const Color(0xFF0F172A).withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;
    final borderBadge = Paint()
      ..color = isActive
          ? AppColors.brandGold.withValues(alpha: 0.8 + 0.2 * pulseFactor)
          : const Color(0xFF334155)
      ..strokeWidth = isActive ? 1.6 : 0.8
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(RRect.fromRectAndRadius(badgeRect, const Radius.circular(4)), bgBadge);
    canvas.drawRRect(RRect.fromRectAndRadius(badgeRect, const Radius.circular(4)), borderBadge);

    textPainter.paint(canvas, Offset(mid.dx - textPainter.width * 0.5, mid.dy - textPainter.height * 0.5));
  }

  void _paintSlopedDimension({
    required Canvas canvas,
    required Offset start,
    required Offset end,
    required String label,
    required double pulseFactor,
  }) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final len = math.sqrt(dx * dx + dy * dy);
    if (len == 0) return;

    // Offset line perpendicular to slope (upward)
    const offsetDist = 18.0;
    final perp = Offset(dy / len * offsetDist, -dx / len * offsetDist);

    final oStart = Offset(start.dx + perp.dx, start.dy + perp.dy);
    final oEnd = Offset(end.dx + perp.dx, end.dy + perp.dy);

    final linePaint = Paint()
      ..color = AppColors.brandGold
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(oStart, oEnd, linePaint);
    _drawArrowOrTick(canvas, oStart, oEnd, linePaint, true);
    _drawArrowOrTick(canvas, oEnd, oStart, linePaint, true);

    // Parallel text badge
    final mid = Offset((oStart.dx + oEnd.dx) * 0.5 + perp.dx * 0.7, (oStart.dy + oEnd.dy) * 0.5 + perp.dy * 0.7);

    final textSpan = TextSpan(
      text: label,
      style: const TextStyle(
        color: AppColors.brandGold,
        fontSize: 12.5,
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
