import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_radii.dart';

/// Type of measurement guide diagram.
enum MeasurementGuideType {
  slab,
  stairs,
  roof,
}

/// Visual "Where Do I Measure?" mini-guide card with dimension callout arrows.
class VisualMeasurementGuide extends StatelessWidget {
  final MeasurementGuideType type;

  const VisualMeasurementGuide({
    super.key,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: AppRadii.cardRadius,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            height: 64,
            child: CustomPaint(
              painter: _GuidePainter(type: type),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_getTitle(), style: AppTypography.inputText.copyWith(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 2),
                Text(_getTip(), style: AppTypography.helperText),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTitle() {
    switch (type) {
      case MeasurementGuideType.slab:
        return 'Measuring Concrete Slabs';
      case MeasurementGuideType.stairs:
        return 'Measuring Stair Height';
      case MeasurementGuideType.roof:
        return 'Measuring Roof Run & Slope';
    }
  }

  String _getTip() {
    switch (type) {
      case MeasurementGuideType.slab:
        return 'Measure outer Length, Width, and pour Depth (Thickness).';
      case MeasurementGuideType.stairs:
        return 'Measure vertical Floor-to-Floor height (Total Rise).';
      case MeasurementGuideType.roof:
        return 'Measure horizontal distance from exterior wall to ridge.';
    }
  }
}

class _GuidePainter extends CustomPainter {
  final MeasurementGuideType type;

  const _GuidePainter({required this.type});

  @override
  void paint(Canvas canvas, Size size) {
    switch (type) {
      case MeasurementGuideType.slab:
        _paintSlab(canvas, size);
        break;
      case MeasurementGuideType.stairs:
        _paintStairs(canvas, size);
        break;
      case MeasurementGuideType.roof:
        _paintRoof(canvas, size);
        break;
    }
  }

  void _paintSlab(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = AppColors.categoryMaterials.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = AppColors.categoryMaterials
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final goldPaint = Paint()
      ..color = AppColors.brandGold
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Isometric slab
    final path = Path();
    path.moveTo(size.width * 0.2, size.height * 0.5);
    path.lineTo(size.width * 0.6, size.height * 0.25);
    path.lineTo(size.width * 0.85, size.height * 0.5);
    path.lineTo(size.width * 0.45, size.height * 0.75);
    path.close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);

    // Thickness front face
    final frontPath = Path();
    frontPath.moveTo(size.width * 0.2, size.height * 0.5);
    frontPath.lineTo(size.width * 0.45, size.height * 0.75);
    frontPath.lineTo(size.width * 0.45, size.height * 0.9);
    frontPath.lineTo(size.width * 0.2, size.height * 0.65);
    frontPath.close();
    canvas.drawPath(frontPath, fillPaint);
    canvas.drawPath(frontPath, strokePaint);

    // Thickness arrow
    canvas.drawLine(
      Offset(size.width * 0.12, size.height * 0.5),
      Offset(size.width * 0.12, size.height * 0.65),
      goldPaint,
    );
  }

  void _paintStairs(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = AppColors.brandGold
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    final arrowPaint = Paint()
      ..color = AppColors.categoryStairs
      ..strokeWidth = 1.5;

    final path = Path();
    path.moveTo(size.width * 0.2, size.height * 0.85);
    path.lineTo(size.width * 0.35, size.height * 0.85); // Tread 1
    path.lineTo(size.width * 0.35, size.height * 0.6);  // Rise 1
    path.lineTo(size.width * 0.5, size.height * 0.6);   // Tread 2
    path.lineTo(size.width * 0.5, size.height * 0.35);  // Rise 2
    path.lineTo(size.width * 0.65, size.height * 0.35); // Tread 3
    path.lineTo(size.width * 0.65, size.height * 0.1);  // Rise 3
    path.lineTo(size.width * 0.8, size.height * 0.1);   // Top floor

    canvas.drawPath(path, strokePaint);

    // Vertical Rise Arrow Callout
    canvas.drawLine(
      Offset(size.width * 0.9, size.height * 0.1),
      Offset(size.width * 0.9, size.height * 0.85),
      arrowPaint,
    );
  }

  void _paintRoof(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = AppColors.categoryRoofing
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    final goldPaint = Paint()
      ..color = AppColors.brandGold
      ..strokeWidth = 1.5;

    // Roof triangle
    final path = Path();
    path.moveTo(size.width * 0.1, size.height * 0.75); // Eaves left
    path.lineTo(size.width * 0.5, size.height * 0.2);  // Ridge
    path.lineTo(size.width * 0.9, size.height * 0.75); // Eaves right

    canvas.drawPath(path, strokePaint);

    // Horizontal Run line
    canvas.drawLine(
      Offset(size.width * 0.15, size.height * 0.75),
      Offset(size.width * 0.5, size.height * 0.75),
      goldPaint,
    );
    // Vertical Rise line
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.2),
      Offset(size.width * 0.5, size.height * 0.75),
      goldPaint..strokeWidth = 1.0,
    );
  }

  @override
  bool shouldRepaint(covariant _GuidePainter oldDelegate) => oldDelegate.type != type;
}
