import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Pixel-perfect vector representation of the BuildCalc Golden House Framing Logo.
/// Featuring the architectural gable truss, ruler calibration tick marks, and framing plumb square.
class BuildCalcAppLogo extends StatelessWidget {
  final double size;
  final bool withBackground;

  const BuildCalcAppLogo({
    super.key,
    this.size = 48,
    this.withBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget icon = CustomPaint(
      size: Size(size, size),
      painter: BuildCalcLogoPainter(),
    );

    if (withBackground) {
      return Container(
        width: size * 1.25,
        height: size * 1.25,
        padding: EdgeInsets.all(size * 0.12),
        decoration: BoxDecoration(
          color: const Color(0xFF13171E),
          borderRadius: BorderRadius.circular(size * 0.28),
          border: Border.all(
            color: AppColors.brandGold.withValues(alpha: 0.25),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(child: icon),
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: icon,
    );
  }
}

class BuildCalcLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Linear Gold Gradient for realistic brushed metal look
    final goldShader = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFFFDF7A),
        Color(0xFFD4AF37),
        Color(0xFFAA8012),
        Color(0xFFFFE680),
      ],
      stops: [0.0, 0.45, 0.85, 1.0],
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    final goldPaint = Paint()
      ..shader = goldShader
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = const Color(0xFF5C4308)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    // 1. GABLE ROOF CHEVRON (Top Peak)
    final roofPath = Path()
      ..moveTo(w * 0.50, h * 0.08) // Top apex
      ..lineTo(w * 0.90, h * 0.48) // Right eave outer
      ..lineTo(w * 0.76, h * 0.58) // Right eave inner cut
      ..lineTo(w * 0.50, h * 0.32) // Peak underside
      ..lineTo(w * 0.24, h * 0.58) // Left eave inner cut
      ..lineTo(w * 0.10, h * 0.48) // Left eave outer
      ..close();

    canvas.drawPath(roofPath, goldPaint);
    canvas.drawPath(roofPath, shadowPaint);

    // 2. LEFT RULER STUD (Vertical post with ruler tick marks)
    final rulerLeft = w * 0.10;
    final rulerRight = w * 0.28;
    final rulerTop = h * 0.48;
    final rulerBottom = h * 0.90;

    final rulerRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(rulerLeft, rulerTop, rulerRight, rulerBottom),
      const Radius.circular(2),
    );
    canvas.drawRRect(rulerRect, goldPaint);
    canvas.drawRRect(rulerRect, shadowPaint);

    // Ruler calibration tick marks
    final tickPaint = Paint()
      ..color = const Color(0xFF1E170A)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    const tickCount = 6;
    final tickStep = (rulerBottom - rulerTop) / (tickCount + 1);
    for (int i = 1; i <= tickCount; i++) {
      final ty = rulerTop + i * tickStep;
      final tickLen = (i % 2 == 0) ? (rulerRight - rulerLeft) * 0.55 : (rulerRight - rulerLeft) * 0.35;
      canvas.drawLine(Offset(rulerLeft, ty), Offset(rulerLeft + tickLen, ty), tickPaint);
    }

    // 3. RIGHT PLUMB SQUARE / L-FRAMING BRACE
    final plumbPath = Path()
      ..moveTo(w * 0.48, h * 0.36) // Center post top
      ..lineTo(w * 0.62, h * 0.48)
      ..lineTo(w * 0.62, h * 0.74) // Down
      ..lineTo(w * 0.88, h * 0.74) // Right foot
      ..lineTo(w * 0.88, h * 0.90) // Base right
      ..lineTo(w * 0.48, h * 0.90) // Base left
      ..close();

    canvas.drawPath(plumbPath, goldPaint);
    canvas.drawPath(plumbPath, shadowPaint);

    // 4. HORIZONTAL TIE MEMBERS / JOISTS
    final tiePaint = Paint()
      ..shader = goldShader
      ..style = PaintingStyle.fill;

    // Upper collar tie
    canvas.drawRect(Rect.fromLTWH(w * 0.28, h * 0.52, w * 0.20, h * 0.07), tiePaint);
    // Lower floor tie
    canvas.drawRect(Rect.fromLTWH(w * 0.28, h * 0.66, w * 0.20, h * 0.07), tiePaint);
    // Center vertical king post strut
    canvas.drawRect(Rect.fromLTWH(w * 0.36, h * 0.52, w * 0.06, h * 0.21), tiePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
