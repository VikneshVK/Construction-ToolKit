import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../math/stair_math.dart';

/// Dynamic vector painter for staircase geometry.
/// Renders proportional steps, stringer line, rise & run dimension annotations.
class StairBlueprintPainter extends CustomPainter {
  final StairResult result;

  const StairBlueprintPainter({required this.result});

  @override
  void paint(Canvas canvas, Size size) {
    if (result.numberOfRisers <= 0) return;

    final stepPaint = Paint()
      ..color = AppColors.brandGold
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = AppColors.brandGold.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    final dimensionPaint = Paint()
      ..color = AppColors.textSecondary
      ..strokeWidth = 1.0;

    final textStyle = TextStyle(
      color: AppColors.textPrimary,
      fontSize: 11,
      fontWeight: FontWeight.w600,
    );

    // Coordinate system setup
    final risers = result.numberOfRisers.clamp(1, 16);
    final treads = risers - 1;

    const padLeft = 40.0;
    const padRight = 50.0;
    const padTop = 30.0;
    const padBottom = 30.0;

    final drawWidth = size.width - padLeft - padRight;
    final drawHeight = size.height - padTop - padBottom;

    final stepWidth = drawWidth / (treads > 0 ? treads : 1);
    final stepHeight = drawHeight / risers;

    final path = Path();
    double currX = padLeft;
    double currY = size.height - padBottom;

    path.moveTo(currX, currY);

    // Draw steps
    for (int i = 0; i < risers; i++) {
      currY -= stepHeight;
      path.lineTo(currX, currY); // Riser up
      if (i < treads) {
        currX += stepWidth;
        path.lineTo(currX, currY); // Tread across
      }
    }

    // Stringer bottom line to complete fill polygon
    final fillPath = Path.from(path)
      ..lineTo(currX, size.height - padBottom)
      ..close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, stepPaint);

    // Dimension: Total Rise (Right Vertical Line)
    final rightX = size.width - 30;
    canvas.drawLine(Offset(rightX, size.height - padBottom), Offset(rightX, padTop), dimensionPaint);
    _drawArrow(canvas, Offset(rightX, size.height - padBottom), Offset(rightX, padTop), dimensionPaint);
    _drawText(
      canvas,
      'Rise: ${result.totalRise.toInchesFraction()}',
      Offset(rightX - 35, padTop - 18),
      textStyle.copyWith(color: AppColors.brandGold),
    );

    // Dimension: Total Run (Bottom Horizontal Line)
    final bottomY = size.height - 12;
    canvas.drawLine(Offset(padLeft, bottomY), Offset(currX, bottomY), dimensionPaint);
    _drawArrow(canvas, Offset(padLeft, bottomY), Offset(currX, bottomY), dimensionPaint);
    _drawText(
      canvas,
      'Total Run: ${result.totalRun.toInchesFraction()}',
      Offset((padLeft + currX) / 2 - 35, bottomY - 16),
      textStyle.copyWith(color: AppColors.textPrimary),
    );
  }

  void _drawArrow(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const size = 4.0;
    // Tick marks
    canvas.drawLine(Offset(p1.dx - size, p1.dy), Offset(p1.dx + size, p1.dy), paint);
    canvas.drawLine(Offset(p2.dx - size, p2.dy), Offset(p2.dx + size, p2.dy), paint);
  }

  void _drawText(Canvas canvas, String text, Offset offset, TextStyle style, {double rotation = 0}) {
    final span = TextSpan(text: text, style: style);
    final tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();

    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    if (rotation != 0) {
      canvas.rotate(rotation);
    }
    tp.paint(canvas, Offset.zero);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant StairBlueprintPainter oldDelegate) {
    return oldDelegate.result != result;
  }
}
