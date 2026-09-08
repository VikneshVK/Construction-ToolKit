import 'package:flutter_test/flutter_test.dart';
import 'package:buildcalc/core/math/measurement.dart';
import 'package:buildcalc/core/math/fraction.dart';
import 'package:buildcalc/core/math/concrete_math.dart';
import 'package:buildcalc/core/math/stair_math.dart';
import 'package:buildcalc/core/math/roofing_math.dart';
import 'package:buildcalc/core/math/masonry_math.dart';
import 'package:buildcalc/core/math/framing_math.dart';

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
      expect(constrainedResult.codeReport.codeLabel, 'DIMENSION CHECK: PASS');
    });

    test('Separate Code Compliance from Comfort Guidance Labels', () {
      final rise = Length.fromInches(98.5);
      final result = StairMath.solve(
        totalRise: rise,
        preferredTread: Length.fromInches(10),
      );

      expect(result.codeReport.codeLabel, 'DIMENSION CHECK: PASS');
      expect(result.codeReport.comfortLabel, 'COMFORT: Optimal');
      expect(result.codeReport.isComfortCompliant, true);
    });

    test('Stair Riser Fractional Rounding to 1/16" (8\' 1/4" total rise with 13 risers)', () {
      // 8' 1/4" = 96.25 inches
      // 13 risers -> exact riser height = 96.25 / 13 = 7.403846"
      // Decimal remainder = 0.403846"
      // 0.403846 * 16 = 6.4615 -> rounds to 6/16 = 3/8" (0.375")
      // Distance to 3/8" (0.375"): |7.403846 - 7.375| = 0.0288"
      // Distance to 7/16" (0.4375"): |7.403846 - 7.4375| = 0.0336"
      // Must display as 7 3/8"
      final totalRise = Length.fromInches(96.25);
      final result = StairMath.solve(
        totalRise: totalRise,
        mode: StairSolveMode.fixedTotalRun,
        availableRun: Length.fromFeet(10),
      );

      expect(result.numberOfRisers, 13);
      expect(result.riserHeight.toInches(), closeTo(7.4038, 0.0001));
      expect(result.riserHeight.toInchesFraction(), '7 3/8"');
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
      // 4/12 Pitch Test (slopeMultiplier = sqrt(144 + 16)/12 = 1.0540925)
      // 16" O.C. spacing, 1.5" hip thickness:
      // Jack #1 Centerline = 16 * 1.0540925 = 16.8655" (~1' 4 7/8")
      // Hip shortening = (1.5 / (2 * sin(45°))) * 1.0540925 = 1.06066 * 1.0540925 = 1.1180" (~1 1/8")
      // Long-point cut length = 16.8655 - 1.1180 = 15.7475" (~1' 3 3/4")
      final jacks = RoofingMath.calculateJackRafters(
        pitch: const RoofPitch(4.0),
        spacingOnCenter: Length.fromInches(16.0),
        hipLumberThickness: Length.fromInches(1.5),
        count: 3,
      );

      expect(jacks.length, 3);
      expect(jacks[0].theoreticalLength.toInches(), closeTo(16.865, 0.01));
      expect(jacks[0].hipShortening.toInches(), closeTo(1.118, 0.01));
      expect(jacks[0].trueCutLongPoint.toInches(), closeTo(15.747, 0.01));
      expect(jacks[0].sideCutBevelAngle, closeTo(43.50, 0.05));

      // Jack #2: Centerline = 33.731", Cut = 33.731 - 1.118 = 32.613" (~2' 8 5/8")
      expect(jacks[1].theoreticalLength.toInches(), closeTo(33.731, 0.01));
      expect(jacks[1].trueCutLongPoint.toInches(), closeTo(32.613, 0.01));
    });
  });

  group('Masonry Math & Generic Mortar Estimate Tests', () {
    test('Calculates CMU blocks and whole mortar bags based on 32 CMU per 80-lb bag on modular grid', () {
      // 30 ft x 8 ft CMU 8x8x16 wall with 10% waste:
      // Standard manufactured CMU: 15.625" length x 7.625" height
      // effLength = 15.625 + 0.375 = 16.0 in modular -> 360 / 16.0 = 22.5 -> ceil = 23 units/course
      // effHeight = 7.625 + 0.375 = 8.0 in modular -> 96 / 8.0 = 12 courses
      // baseUnitCount = 23 * 12 = 276
      // totalWithWaste = ceil(276 * 1.10) = ceil(303.6) = 304 blocks
      // 304 / 32 = 9.5 -> ceil to 10 bags
      final cmu = MasonryUnitType.standardCmu8;
      final res = MasonryMath.calculateWall(
        wallLength: Length.fromFeet(30),
        wallHeight: Length.fromFeet(8),
        unitLengthInches: cmu.lengthInches,
        unitHeightInches: cmu.heightInches,
        wastePercent: 10.0,
      );

      expect(res.unitsPerCourse, 23);
      expect(res.coursesHigh, 12);
      expect(res.netUnitsRequired, 276);
      expect(res.totalUnitsRequired, 304);
      expect(res.mortarBagsEstimated, 10.0);
    });

    test('Retaining wall block uses 12" face length and calculates zero mortar bags (dry-stacked)', () {
      final block = MasonryUnitType.retainingWallBlock;
      expect(block.lengthInches, 12.0);
      expect(block.heightInches, 4.0);
      expect(block.isDryStacked, true);

      // 10 ft (120") x 3 ft (36") retaining wall
      final res = MasonryMath.calculateWall(
        wallLength: Length.fromFeet(10),
        wallHeight: Length.fromFeet(3),
        unitLengthInches: block.lengthInches,
        unitHeightInches: block.heightInches,
        isDryStacked: block.isDryStacked,
        wastePercent: 10.0,
      );

      expect(res.unitsPerCourse, 10);
      expect(res.coursesHigh, 9);
      expect(res.netUnitsRequired, 90);
      expect(res.totalUnitsRequired, 99);
      expect(res.mortarBagsEstimated, 0.0);
    });
  });

  group('Framing Math & Board Feet Tests', () {
    test('6x6 Timber Post calculates correct board feet using nominal 6"x6"', () {
      // 10 pcs of 6x6 @ 12 ft:
      // (6 * 6 * 12) / 12 * 10 = 36 * 10 = 360 BF
      final lumber = NominalLumberSize.sixBySix;
      expect(lumber.nominalThicknessInches, 6.0);
      expect(lumber.nominalWidthInches, 6.0);

      final res = FramingMath.calculateBoardFeet(
        nominalThicknessInches: lumber.nominalThicknessInches,
        nominalWidthInches: lumber.nominalWidthInches,
        length: Length.fromFeet(12),
        quantity: 10,
        costPerBoardFoot: 1.50,
      );

      expect(res.totalBoardFeet, 360.0);
      expect(res.totalEstimatedCost, 540.0);
    });

    test('2x10 and 2x12 Joists calculate correct board feet', () {
      // 20 pcs of 2x10 @ 16 ft: (2 * 10 * 16) / 12 * 20 = 533.33 BF
      final lumber2x10 = NominalLumberSize.twoByTen;
      expect(lumber2x10.nominalThicknessInches, 2.0);
      expect(lumber2x10.nominalWidthInches, 10.0);

      final res2x10 = FramingMath.calculateBoardFeet(
        nominalThicknessInches: lumber2x10.nominalThicknessInches,
        nominalWidthInches: lumber2x10.nominalWidthInches,
        length: Length.fromFeet(16),
        quantity: 20,
      );
      expect(res2x10.totalBoardFeet, closeTo(533.33, 0.01));

      // 15 pcs of 2x12 @ 16 ft: (2 * 12 * 16) / 12 * 15 = 480.0 BF
      final lumber2x12 = NominalLumberSize.twoByTwelve;
      expect(lumber2x12.nominalThicknessInches, 2.0);
      expect(lumber2x12.nominalWidthInches, 12.0);

      final res2x12 = FramingMath.calculateBoardFeet(
        nominalThicknessInches: lumber2x12.nominalThicknessInches,
        nominalWidthInches: lumber2x12.nominalWidthInches,
        length: Length.fromFeet(16),
        quantity: 15,
      );
      expect(res2x12.totalBoardFeet, 480.0);
    });
  });

  group('Ready-Mix Batch Plant Rounding Tests', () {
    test('Rounds up to nearest quarter-yard (0.25 yd3)', () {
      // 3.10 yd³ -> recommended order 3.25 yd³
      final slab = ConcreteMath.calculateSlab(
        length: Length.fromFeet(20),
        width: Length.fromFeet(10),
        thickness: Length.fromInches(4),
        wastePercent: 25.0, // 20 * 10 * (4/12) = 66.67 cu ft = 2.469 yd3 * 1.25 = 3.086 yd3 -> 3.25 yd3
      );
      expect(slab.recommendedOrderYards, 3.25);
    });
  });

  group('Dimensional Converter Decimal Feet Tests', () {
    test('Decimal feet entry does not truncate fractional feet', () {
      // 12.5 ft = 150 inches = 12' 6"
      final val = 12.5;
      final frac = Fraction.zero;
      final len = Length.fromInches((val * 12.0) + frac.toDouble());

      expect(len.totalInches, 150.0);
      expect(len.toFeet(), 12.5);
      expect(len.toFeetInchesFraction(), '12\' 6"');
    });

    test('Whole feet plus fractional inches works correctly', () {
      // 12 ft + 3/8" = 144.375 inches = 12' 3/8"
      final val = 12.0;
      final frac = Fraction.raw(3, 8);
      final len = Length.fromInches((val * 12.0) + frac.toDouble());

      expect(len.totalInches, 144.375);
      expect(len.toFeetInchesFraction(), '12\' 3/8"');
    });
  });
}
