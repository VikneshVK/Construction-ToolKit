import 'dart:math' as math;
import 'measurement.dart';

/// Rafter cutting angles and lengths.
class RafterResult {
  final Length commonRafterLength; // Theoretical line length (ridge to wall plate)
  final Length totalRafterLength;  // Including overhang
  final Length overhangLength;     // Sloped rafter extension length
  final Length overhangRun;        // Horizontal overhang projection beyond wall
  final Length totalRise;
  final Length totalRun;
  final RoofPitch pitch;
  final double plumbCutAngle;      // Angle for vertical cuts at ridge and plumb tail
  final double levelCutAngle;      // Angle for horizontal seat cut (bird's mouth)
  final double pitchAngleDegrees;

  const RafterResult({
    required this.commonRafterLength,
    required this.totalRafterLength,
    required this.overhangLength,
    required this.overhangRun,
    required this.totalRise,
    required this.totalRun,
    required this.pitch,
    required this.plumbCutAngle,
    required this.levelCutAngle,
    required this.pitchAngleDegrees,
  });
}

/// Result of "True-Cut" Jack Rafter calculation.
class JackRafterResult {
  final int jackIndex;             // 1, 2, 3...
  final Length onCenterSpacing;    // e.g. 16" or 24"
  final Length theoreticalLength;  // Centerline math length
  final Length trueCutLongPoint;   // Physical cut mark on the long-point edge of the bevel
  final Length bevelDeduction;     // Hip shortening deduction
  final Length hipShortening;      // Sloped hip shortening
  final double sideCutBevelAngle;  // Compound saw blade bevel tilt (e.g. 45° plan pitch tilt)

  const JackRafterResult({
    required this.jackIndex,
    required this.onCenterSpacing,
    required this.theoreticalLength,
    required this.trueCutLongPoint,
    required this.bevelDeduction,
    required this.hipShortening,
    required this.sideCutBevelAngle,
  });
}

/// Roofing trigonometry and "True-Cut" jack rafter offset engine.
class RoofingMath {
  /// Solves common rafter geometry from rise and run (or run and pitch).
  static RafterResult solveCommonRafter({
    required Length run,
    Length? rise,
    RoofPitch? pitch,
    Length? overhangRun,
  }) {
    final runInches = run.toInches();
    late double riseInches;
    late RoofPitch resolvedPitch;

    if (pitch != null) {
      resolvedPitch = pitch;
      riseInches = (runInches / 12.0) * pitch.riseIn12;
    } else if (rise != null) {
      riseInches = rise.toInches();
      resolvedPitch = RoofPitch.fromRiseAndRun(rise, run);
    } else {
      throw ArgumentError('Either rise or pitch must be provided');
    }

    final pitchAngle = resolvedPitch.pitchDegrees;
    final plumbAngle = 90.0 - pitchAngle;
    final levelAngle = pitchAngle;

    // Line length (hypotenuse)
    final lineLengthInches = math.sqrt(math.pow(runInches, 2) + math.pow(riseInches, 2));

    // Overhang line length
    final overRun = overhangRun ?? Length.zero;
    final overRunInches = overRun.toInches();
    final overRiseInches = (overRunInches / 12.0) * resolvedPitch.riseIn12;
    final overhangLineInches = math.sqrt(math.pow(overRunInches, 2) + math.pow(overRiseInches, 2));

    return RafterResult(
      commonRafterLength: Length.fromInches(lineLengthInches),
      totalRafterLength: Length.fromInches(lineLengthInches + overhangLineInches),
      overhangLength: Length.fromInches(overhangLineInches),
      overhangRun: overRun,
      totalRise: Length.fromInches(riseInches),
      totalRun: run,
      pitch: resolvedPitch,
      plumbCutAngle: plumbAngle,
      levelCutAngle: levelAngle,
      pitchAngleDegrees: pitchAngle,
    );
  }

  /// Calculates a series of "True-Cut" Jack Rafters along a regular 45° hip/valley rafter.
  /// 
  /// Shortening formula (half 45° hip thickness along roof slope):
  ///   hipShorteningInches = (hipThickness / 2) / sin(45°)
  ///   trueCutDeductionInches = hipShorteningInches * slopeMultiplier
  ///   physicalCutInches = max(0, theoreticalInches - trueCutDeductionInches)
  static List<JackRafterResult> calculateJackRafters({
    required RoofPitch pitch,
    required Length spacingOnCenter, // e.g. 16" or 24"
    required Length hipLumberThickness, // e.g. 1.5" (for 2x material) or 3.0"
    int count = 6,
  }) {
    final List<JackRafterResult> results = [];
    final slopeMultiplier = pitch.slopeMultiplier;
    final spacingInches = spacingOnCenter.toInches();
    final hipThickInches = hipLumberThickness.toInches();

    // 1. Sloped hip shortening deduction:
    final planAngleRad = 45.0 * (math.pi / 180.0);
    final hipShorteningInches = (hipThickInches / 2.0) / math.sin(planAngleRad);
    final trueCutDeductionInches = hipShorteningInches * slopeMultiplier;

    // Compound side-cut saw bevel angle for jack rafter cheek cut:
    // tan(side cut) = cos(pitch angle)
    final pitchRad = pitch.pitchDegrees * (math.pi / 180.0);
    final sideCutRad = math.atan(math.cos(pitchRad));
    final sideCutDeg = sideCutRad * (180.0 / math.pi);

    for (int i = 1; i <= count; i++) {
      final theoreticalInches = (spacingInches * i) * slopeMultiplier;
      final physicalCutInches = math.max(0.0, theoreticalInches - trueCutDeductionInches);

      results.add(JackRafterResult(
        jackIndex: i,
        onCenterSpacing: Length.fromInches(spacingInches * i),
        theoreticalLength: Length.fromInches(theoreticalInches),
        trueCutLongPoint: Length.fromInches(physicalCutInches),
        bevelDeduction: Length.fromInches(trueCutDeductionInches),
        hipShortening: Length.fromInches(trueCutDeductionInches),
        sideCutBevelAngle: sideCutDeg,
      ));
    }

    return results;
  }
}
