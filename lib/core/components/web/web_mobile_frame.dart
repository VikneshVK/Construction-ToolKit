import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../icons/buildcalc_app_logo.dart';

/// Wraps the application inside a realistic Mobile Device Emulator chassis
/// when viewed on desktop browsers or tablets, while seamlessly adapting
/// to full screen on actual mobile devices.
class WebMobileFrame extends StatelessWidget {
  final Widget child;

  const WebMobileFrame({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // If not running on web, or on a compact screen width (real mobile phone), render directly
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!kIsWeb || constraints.maxWidth < 520) {
          return child;
        }

        // On desktop web, present inside a sleek smartphone device frame
        return Scaffold(
          backgroundColor: const Color(0xFF070A0F),
          body: Stack(
            children: [
              // Background technical blueprint grid
              Positioned.fill(
                child: CustomPaint(
                  painter: _DesktopGridPainter(),
                ),
              ),

              // Centered Mobile Device Emulator
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Top indicator bar
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const BuildCalcAppLogo(size: 18, withBackground: false),
                          const SizedBox(width: 8),
                          RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Build',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Calc',
                                  style: TextStyle(
                                    color: AppColors.brandGold,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF141B26),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColors.brandGold.withValues(alpha: 0.35),
                                width: 1,
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.smartphone, size: 13, color: AppColors.brandGold),
                                SizedBox(width: 5),
                                Text(
                                  'Live Mobile Emulator View',
                                  style: TextStyle(
                                    color: Color(0xFFB0BDD0),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Smartphone Chassis
                      Container(
                        width: 395,
                        height: 830,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D1219),
                          borderRadius: BorderRadius.circular(46),
                          border: Border.all(
                            color: const Color(0xFF283446),
                            width: 6,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.85),
                              blurRadius: 45,
                              spreadRadius: 8,
                              offset: const Offset(0, 16),
                            ),
                            BoxShadow(
                              color: AppColors.brandGold.withValues(alpha: 0.12),
                              blurRadius: 30,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: Stack(
                            children: [
                              // The Live App
                              child,

                              // Top Dynamic Island / Speaker cutout
                              Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: Container(
                                    margin: const EdgeInsets.only(top: 8),
                                    width: 115,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF192330),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          width: 44,
                                          height: 4,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF222F42),
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // Bottom Home Indicator Line
                              Positioned(
                                bottom: 6,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: Container(
                                    width: 120,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.25),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DesktopGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0F1724)
      ..strokeWidth = 0.6;

    const step = 28.0;
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
