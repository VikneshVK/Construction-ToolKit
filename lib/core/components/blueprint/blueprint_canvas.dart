import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_radii.dart';

/// High-contrast blueprint container for rendering proportional 2D vector technical drawings.
class BlueprintCanvas extends StatelessWidget {
  final CustomPainter painter;
  final double height;
  final String? title;

  const BlueprintCanvas({
    super.key,
    required this.painter,
    this.height = 180,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: AppRadii.cardRadius,
        border: Border.all(color: AppColors.borderSubtle, width: 1.0),
      ),
      child: ClipRRect(
        borderRadius: AppRadii.cardRadius,
        child: Stack(
          children: [
            // Background subtle CAD grid
            const Positioned.fill(child: CustomPaint(painter: _CadGridPainter())),
            
            // Dynamic Geometry Drawing
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: CustomPaint(painter: painter),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CadGridPainter extends CustomPainter {
  const _CadGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.borderSubtle.withValues(alpha: 0.35)
      ..strokeWidth = 0.75;

    const step = 20.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
