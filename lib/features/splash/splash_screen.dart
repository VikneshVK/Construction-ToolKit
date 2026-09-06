import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/components/icons/buildcalc_app_logo.dart';
import '../../app_shell.dart';

/// Full-screen Startup Splash / Boot Screen for BuildCalc.
/// Features:
/// - Technical CAD blueprint background grid.
/// - Golden Gable Truss framing logo with ruler ticks and square brace.
/// - Two-tone BuildCalc wordmark + "BUILT FOR THE JOBSITE".
/// - Intricate architectural CAD house wireframe vector illustration.
/// - Centered spaced blueprint steps: MEASURE, CALCULATE, BUILD.
/// - Animated gold progress loading bar.
/// - 4 hallmark feature pillars: Fast, Offline, Precise, Built for Pros.
class SplashScreen extends StatefulWidget {
  final Duration duration;
  final VoidCallback? onFinished;

  const SplashScreen({
    super.key,
    this.duration = const Duration(milliseconds: 1800),
    this.onFinished,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _progressAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );

    _controller.forward().then((_) {
      if (mounted) {
        if (widget.onFinished != null) {
          widget.onFinished!();
        } else {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const AppShell(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 350),
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F17),
      body: Stack(
        children: [
          // 1. Blueprint Grid Background
          Positioned.fill(
            child: CustomPaint(
              painter: _BlueprintGridPainter(),
            ),
          ),

          // 2. Main Content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 24),
                // Top Brand Header: Golden Truss Logo
                const BuildCalcAppLogo(size: 68, withBackground: false),
                const SizedBox(height: 12),
                
                // Two-Tone Wordmark
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Build',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w900,
                          fontSize: 34,
                          letterSpacing: 0.5,
                        ),
                      ),
                      TextSpan(
                        text: 'Calc',
                        style: TextStyle(
                          color: AppColors.brandGold,
                          fontWeight: FontWeight.w900,
                          fontSize: 34,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                
                // Tagline
                const Text(
                  'BUILT FOR THE JOBSITE',
                  style: TextStyle(
                    color: Color(0xFFC7CCD6),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.2,
                  ),
                ),

                const Spacer(flex: 1),

                // Center Architectural CAD House Wireframe Illustration
                SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: _CadHouseWireframePainter(),
                  ),
                ),

                const SizedBox(height: 16),

                // Spaced Uppercase Subtitle
                Column(
                  children: const [
                    Text(
                      'M E A S U R E',
                      style: TextStyle(
                        color: Color(0xFFCFD6E2),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 3.5,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'C A L C U L A T E',
                      style: TextStyle(
                        color: Color(0xFFCFD6E2),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 3.5,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'B U I L D',
                      style: TextStyle(
                        color: Color(0xFFCFD6E2),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 3.5,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Animated Gold Loading Progress Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 54),
                  child: AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      return Container(
                        height: 5,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F2633),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                width: constraints.maxWidth * _progressAnimation.value,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: AppColors.brandGold,
                                  borderRadius: BorderRadius.circular(3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.brandGold.withValues(alpha: 0.6),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),

                const Spacer(flex: 2),

                // Bottom 4 Feature Pillars with Dividers
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Color(0xFF1D2635), width: 1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildFeatureColumn(
                        icon: Icons.bolt,
                        title: 'Fast',
                        subtitle: 'Opens instantly',
                      ),
                      _buildDivider(),
                      _buildFeatureColumn(
                        icon: Icons.shield_outlined,
                        title: 'Offline',
                        subtitle: 'No signal needed',
                      ),
                      _buildDivider(),
                      _buildFeatureColumn(
                        icon: Icons.my_location_outlined,
                        title: 'Precise',
                        subtitle: 'Fractions done right',
                      ),
                      _buildDivider(),
                      _buildFeatureColumn(
                        icon: Icons.hardware_outlined,
                        title: 'Built for Pros',
                        subtitle: 'Real work. Real tools.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureColumn({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.brandGold, size: 24),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF8E99A8),
              fontSize: 10,
              height: 1.1,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 38,
      color: const Color(0xFF1F2837),
    );
  }
}

/// Subtle blueprint grid background
class _BlueprintGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFF141E2D)
      ..strokeWidth = 0.6;

    const step = 24.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// CAD House Wireframe architectural drawing painter
class _CadHouseWireframePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final primaryLinePaint = Paint()
      ..color = const Color(0xFF426588)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final brightLinePaint = Paint()
      ..color = const Color(0xFF6EA8D9)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    final faintLinePaint = Paint()
      ..color = const Color(0xFF22374E)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    final cx = w * 0.5;
    final houseWidth = w * 0.58;
    final houseLeft = cx - houseWidth / 2;
    final houseRight = cx + houseWidth / 2;
    final eaveY = h * 0.45;
    final peakY = h * 0.08;
    final groundY = h * 0.94;

    // Background projection guideline rays
    canvas.drawLine(Offset(w * 0.12, h * 0.80), Offset(cx, h * -0.05), faintLinePaint);
    canvas.drawLine(Offset(w * 0.88, h * 0.80), Offset(cx, h * -0.05), faintLinePaint);
    canvas.drawLine(Offset(w * 0.05, eaveY), Offset(w * 0.95, eaveY), faintLinePaint);

    // Main Outer Gable Roof Truss
    final outerRoof = Path()
      ..moveTo(cx, peakY)
      ..lineTo(houseRight + 12, eaveY + 6)
      ..lineTo(houseLeft - 12, eaveY + 6)
      ..close();
    canvas.drawPath(outerRoof, brightLinePaint);

    // Inner Gable Roof Line
    final innerRoof = Path()
      ..moveTo(cx, peakY + 12)
      ..lineTo(houseRight, eaveY)
      ..lineTo(houseLeft, eaveY)
      ..close();
    canvas.drawPath(innerRoof, primaryLinePaint);

    // King Post & Web Struts (Internal Truss Framing)
    canvas.drawLine(Offset(cx, peakY + 12), Offset(cx, eaveY), brightLinePaint);
    canvas.drawLine(Offset(cx - houseWidth * 0.25, eaveY), Offset(cx, peakY + 28), primaryLinePaint);
    canvas.drawLine(Offset(cx + houseWidth * 0.25, eaveY), Offset(cx, peakY + 28), primaryLinePaint);

    // House Walls (Exterior Frame)
    canvas.drawRect(
      Rect.fromLTRB(houseLeft, eaveY, houseRight, groundY),
      brightLinePaint,
    );

    // Center Demising Wall / Post
    canvas.drawLine(Offset(cx, eaveY), Offset(cx, groundY), primaryLinePaint);

    // Left Garage / Window Framing
    final leftBayLeft = houseLeft + houseWidth * 0.08;
    final leftBayRight = cx - houseWidth * 0.08;
    final bayTop = eaveY + (groundY - eaveY) * 0.20;
    canvas.drawRect(
      Rect.fromLTRB(leftBayLeft, bayTop, leftBayRight, groundY),
      primaryLinePaint,
    );
    // Panel line
    canvas.drawLine(
      Offset(leftBayLeft, bayTop + (groundY - bayTop) * 0.5),
      Offset(leftBayRight, bayTop + (groundY - bayTop) * 0.5),
      faintLinePaint,
    );

    // Right Entry & Window Framing
    final rightBayLeft = cx + houseWidth * 0.10;
    final rightBayRight = houseRight - houseWidth * 0.10;
    final windowBottom = eaveY + (groundY - eaveY) * 0.65;
    canvas.drawRect(
      Rect.fromLTRB(rightBayLeft, bayTop, rightBayRight, windowBottom),
      primaryLinePaint,
    );
    // Window cross mullions
    final winMidX = (rightBayLeft + rightBayRight) / 2;
    final winMidY = (bayTop + windowBottom) / 2;
    canvas.drawLine(Offset(winMidX, bayTop), Offset(winMidX, windowBottom), faintLinePaint);
    canvas.drawLine(Offset(rightBayLeft, winMidY), Offset(rightBayRight, winMidY), faintLinePaint);

    // Dimension Ticks and Blueprint Markers
    final dimPaint = Paint()
      ..color = const Color(0xFF3B5675)
      ..strokeWidth = 0.8;

    // Center plumb tick mark
    canvas.drawLine(Offset(cx - 5, peakY - 8), Offset(cx + 5, peakY - 8), dimPaint);
    canvas.drawLine(Offset(cx, peakY - 12), Offset(cx, peakY - 4), dimPaint);

    // Baseline Ground Line
    canvas.drawLine(Offset(w * 0.08, groundY), Offset(w * 0.92, groundY), primaryLinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
