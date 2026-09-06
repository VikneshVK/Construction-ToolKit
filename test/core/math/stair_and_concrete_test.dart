import 'package:flutter_test/flutter_test.dart';
import 'package:buildcalc/core/math/measurement.dart';
import 'package:buildcalc/core/math/concrete_math.dart';
import 'package:buildcalc/core/math/stair_math.dart';
import 'package:buildcalc/core/math/roofing_math.dart';

void main() {
  group('Concrete Math Tests', () {
    test('Concrete Slab with 10% Waste', () {
      // 24 ft x 12 ft x 4 in (0.333 ft)
      // Volume = 24 * 12 * (4/12) = 96 cu ft = 3.555 yd³
      // + 10% waste = 3.911 yd³ -> recommended 4.0 yd³
      final result = ConcreteMath.calculateSlab(
        length: Length.fromFeet(24),
        width: Length.fromFeet(12),
        thickness: Length.fromInches(4),
        wastePercent: 10.0,
      );

      expect(result.netVolume.toCubicFeet(), closeTo(96.0, 0.01));
      expect(result.netVolume.toCubicYards(), closeTo(3.555, 0.01));
      expect(result.grossVolume.toCubicYards(), closeTo(3.911, 0.01));
      expect(result.recommendedOrderYards, 4.0);
    });

    test('Metric Conversion Drift Check (0.975 m³ bug prevention)', () {
      final vol = Volume.fromCubicMeters(0.975);
      expect(vol.toCubicMeters(), closeTo(0.975, 0.001));
      expect(vol.toCubicYards(), closeTo(1.275, 0.01));
    });
  });

  group('Stair Solver & IRC Code Sentinel Tests', () {
    test('Standard Residential 98 1/2" Rise Solves to Compliant Config', () {
      final rise = Length.fromInches(98.5); // 98 1/2"
      final result = StairMath.solve(
        totalRise: rise,
        preferredTread: Length.fromInches(10),
      );

      // 98.5 / 7.0 = 14 risers -> 98.5 / 14 = 7.035" per riser (approx 7 1/16")
      expect(result.numberOfRisers, 14);
      expect(result.numberOfTreads, 13);
      expect(result.riserHeight.toInches(), closeTo(7.035, 0.01));
      expect(result.codeReport.status, StairCodeStatus.pass);
      expect(result.codeReport.isRiserCompliant, true);
      expect(result.codeReport.isTreadCompliant, true);
    });

    test('Comfort Mode vs Constrained Space Mode Produce Mode-Specific Solving Results', () {
      final rise = Length.fromInches(98.5); // 98 1/2"

      final comfortResult = StairMath.solve(
        totalRise: rise,
        mode: StairSolveMode.comfortableTread,
        preferredTread: Length.fromInches(10),
      );

      final constrainedResult = StairMath.solve(
        totalRise: rise,
        mode: StairSolveMode.fixedTotalRun,
        preferredTread: Length.fromInches(10),
      );

      // Comfort mode targets ~7" riser -> 14 risers @ 7.035"
      expect(comfortResult.numberOfRisers, 14);
      expect(comfortResult.numberOfTreads, 13);
      expect(comfortResult.totalRun.toInches(), 130.0);

      // Constrained mode targets max code riser (up to 7.75") -> 13 risers @ 7.576" (7 9/16")
      expect(constrainedResult.numberOfRisers, 13);
      expect(constrainedResult.numberOfTreads, 12);
      expect(constrainedResult.totalRun.toInches(), 120.0);
      expect(constrainedResult.riserHeight.toInches(), closeTo(7.576, 0.01));
      expect(constrainedResult.codeReport.isRiserCompliant, true);
      expect(constrainedResult.codeReport.codeLabel, 'CODE: PASS');
    });

    test('Separate Code Compliance from Comfort Guidance Labels', () {
      final rise = Length.fromInches(98.5);
      final result = StairMath.solve(
        totalRise: rise,
        preferredTread: Length.fromInches(10),
      );

      expect(result.codeReport.codeLabel, 'CODE: PASS');
      expect(result.codeReport.comfortLabel, 'COMFORT: Optimal');
      expect(result.codeReport.isComfortCompliant, true);
    });
  });

  group('Roofing & True-Cut Jack Rafter Tests', () {
    test('Common Rafter 4/12 Pitch with 12 ft Run', () {
      final result = RoofingMath.solveCommonRafter(
        run: Length.fromFeet(12),
        pitch: const RoofPitch(4.0),
        overhangRun: Length.fromInches(12),
      );

      // Hypotenuse for 12 run and 4 rise = sqrt(144 + 16) = 12.649 ft
      expect(result.commonRafterLength.toFeet(), closeTo(12.649, 0.01));
      expect(result.pitchAngleDegrees, closeTo(18.43, 0.01));
      expect(result.plumbCutAngle, closeTo(71.56, 0.01));
    });

    test('True-Cut Jack Rafter Deducts Lumber Thickness for Long-Point', () {
      final jacks = RoofingMath.calculateJackRafters(
        pitch: const RoofPitch(6.0),
        spacingOnCenter: Length.fromInches(16.0),
        hipLumberThickness: Length.fromInches(1.5),
        count: 3,
      );

      expect(jacks.length, 3);
      // Long-point must be strictly less than theoretical centerline length
      expect(jacks[0].trueCutLongPoint.toInches() < jacks[0].theoreticalLength.toInches(), true);
      expect(jacks[0].bevelDeduction.toInches(), greaterThan(0));
    });
  });
}
