import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../math/roofing_math.dart';

/// Dynamic vector blueprint painter for roof rafters.
class RafterBlueprintPainter extends CustomPainter {
  final RafterResult result;

  const RafterBlueprintPainter({required this.result});

  @override
  void paint(Canvas canvas, Size size) {
    final rafterPaint = Paint()
      ..color = AppColors.categoryRoofing
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = AppColors.categoryRoofing.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    final textStyle = const TextStyle(
      color: AppColors.textPrimary,
      fontSize: 11,
      fontWeight: FontWeight.w600,
    );

    const padLeft = 40.0;
    const padRight = 40.0;
    const padTop = 30.0;
    const padBottom = 30.0;

    final pRidge = Offset(size.width - padRight, padTop);
    final pWall = Offset(padLeft + 30, size.height - padBottom);
    final pTail = Offset(padLeft, size.height - padBottom + 12);
    final pCorner = Offset(size.width - padRight, size.height - padBottom);

    // Rafter triangle path
    final path = Path()
      ..moveTo(pRidge.dx, pRidge.dy)
      ..lineTo(pWall.dx, pWall.dy)
      ..lineTo(pTail.dx, pTail.dy)
      ..lineTo(pWall.dx, pWall.dy)
      ..lineTo(pCorner.dx, pCorner.dy)
      ..close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, rafterPaint);

    // Dimension: Rafter Length text along hypotenuse
    final midHypotenuse = Offset((pRidge.dx + pWall.dx) / 2 - 40, (pRidge.dy + pWall.dy) / 2 - 16);
    _drawText(canvas, 'Rafter: ${result.commonRafterLength.toFeetInchesFraction()}', midHypotenuse, textStyle.copyWith(color: AppColors.brandGold));

    // Pitch label
    final pitchText = 'Pitch: ${result.pitch.pitchNotation} (${result.pitchAngleDegrees.toStringAsFixed(1)}°)';
    _drawText(canvas, pitchText, Offset(pCorner.dx - 110, pCorner.dy - 18), textStyle);

    // Plumb Cut Annotation
    _drawText(canvas, 'Plumb: ${result.plumbCutAngle.toStringAsFixed(1)}°', Offset(pRidge.dx - 70, pRidge.dy - 18), textStyle.copyWith(color: AppColors.textSecondary));
  }

  void _drawText(Canvas canvas, String text, Offset offset, TextStyle style) {
    final span = TextSpan(text: text, style: style);
    final tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant RafterBlueprintPainter oldDelegate) {
    return oldDelegate.result != result;
  }
}
