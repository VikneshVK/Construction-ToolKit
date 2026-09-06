import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Custom crafted category graphic icons matching the mockup art style.
class CustomCategoryIcon extends StatelessWidget {
  final String type; // 'materials', 'roofing', 'stairs', 'measurements'
  final double size;

  const CustomCategoryIcon({
    super.key,
    required this.type,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case 'materials':
        return SizedBox(
          width: size,
          height: size,
          child: CustomPaint(painter: _BrickWallIconPainter()),
        );
      case 'roofing':
        return SizedBox(
          width: size,
          height: size,
          child: CustomPaint(painter: _RoofGableIconPainter()),
        );
      case 'stairs':
        return SizedBox(
          width: size,
          height: size,
          child: CustomPaint(painter: _StairBlockIconPainter()),
        );
      case 'measurements':
        return SizedBox(
          width: size,
          height: size,
          child: CustomPaint(painter: _DraftingSquareIconPainter()),
        );
      default:
        return Icon(Icons.calculate, color: AppColors.brandGold, size: size);
    }
  }
}

/// 3-tier orange brick wall icon matching mockup
class _BrickWallIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.categoryMaterials
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;
    final brickH = h / 3.6;
    final gap = 2.5;

    // Row 1 (Top): 2 bricks
    final r1w = (w - gap) / 2;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, r1w, brickH), const Radius.circular(3)), paint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(r1w + gap, 0, r1w, brickH), const Radius.circular(3)), paint);

    // Row 2 (Middle): 1 half, 1 full, 1 half
    final r2y = brickH + gap;
    final fullW = (w - (2 * gap)) / 1.7;
    final halfW = (w - fullW - (2 * gap)) / 2;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, r2y, halfW, brickH), const Radius.circular(3)), paint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(halfW + gap, r2y, fullW, brickH), const Radius.circular(3)), paint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(halfW + fullW + (2 * gap), r2y, halfW, brickH), const Radius.circular(3)), paint);

    // Row 3 (Bottom): 2 bricks
    final r3y = (brickH + gap) * 2;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, r3y, r1w, brickH), const Radius.circular(3)), paint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(r1w + gap, r3y, r1w, brickH), const Radius.circular(3)), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Blue Gable Roof Peak Icon matching mockup
class _RoofGableIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.categoryRoofing
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // Roof chevron
    final path = Path()
      ..moveTo(w / 2, 2)
      ..lineTo(w - 2, h * 0.65)
      ..lineTo(w * 0.78, h * 0.65)
      ..lineTo(w / 2, h * 0.3)
      ..lineTo(w * 0.22, h * 0.65)
      ..lineTo(2, h * 0.65)
      ..close();

    canvas.drawPath(path, paint);

    // Sub-roof block
    final baseRect = Rect.fromLTWH(w * 0.28, h * 0.65, w * 0.44, h * 0.32);
    canvas.drawRRect(RRect.fromRectAndRadius(baseRect, const Radius.circular(3)), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 3-step solid purple staircase icon matching mockup
class _StairBlockIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.categoryStairs
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;
    final stepW = w / 3;
    final stepH = h / 3;

    final path = Path()
      ..moveTo(0, h)
      ..lineTo(0, h - stepH)
      ..lineTo(stepW, h - stepH)
      ..lineTo(stepW, h - (2 * stepH))
      ..lineTo(stepW * 2, h - (2 * stepH))
      ..lineTo(stepW * 2, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h)
      ..close();

    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h), const Radius.circular(4)),
      Paint()..color = Colors.transparent,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Green 45-degree drafting triangle / set-square ruler with ticks matching mockup
class _DraftingSquareIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.categoryMeasurements
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // Outer right-triangle
    final outer = Path()
      ..moveTo(0, 0)
      ..lineTo(0, h)
      ..lineTo(w, h)
      ..close();

    // Inner cutout triangle
    final inner = Path()
      ..moveTo(w * 0.22, h * 0.45)
      ..lineTo(w * 0.22, h * 0.78)
      ..lineTo(w * 0.55, h * 0.78)
      ..close();

    final combined = Path.combine(PathOperation.difference, outer, inner);
    canvas.drawPath(combined, paint);

    // Subtle tick marks on the hypotenuse
    final tickPaint = Paint()
      ..color = AppColors.bgCanvas
      ..strokeWidth = 1.5;

    canvas.drawLine(Offset(w * 0.35, h * 0.35), Offset(w * 0.42, h * 0.42), tickPaint);
    canvas.drawLine(Offset(w * 0.55, h * 0.55), Offset(w * 0.62, h * 0.62), tickPaint);
    canvas.drawLine(Offset(w * 0.75, h * 0.75), Offset(w * 0.82, h * 0.82), tickPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
