import 'measurement.dart';

/// Common masonry block and brick standard types.
enum MasonryUnitType {
  standardCmu8('8x8x16 CMU Block', 8.0, 8.0, 16.0),
  standardCmu6('6x8x16 CMU Block', 6.0, 8.0, 16.0),
  standardCmu4('4x8x16 CMU Block', 4.0, 8.0, 16.0),
  standardModularBrick('Modular Brick (3.5x2.25x7.625)', 3.5, 2.25, 7.625),
  kingSizeBrick('King Size Brick (3x2.75x9.625)', 3.0, 2.75, 9.625),
  retainingWallBlock('Retaining Wall Block (12x8x4)', 12.0, 4.0, 8.0);

  final String label;
  final double widthInches;
  final double heightInches;
  final double lengthInches;

  const MasonryUnitType(this.label, this.widthInches, this.heightInches, this.lengthInches);
}

/// Output of a masonry estimation.
class MasonryResult {
  final int totalUnitsRequired;
  final int netUnitsRequired;
  final int coursesHigh;
  final int unitsPerCourse;
  final double wallSquareFeet;
  final double mortarBagsEstimated; // Standard 80 lb bags
  final double wastePercent;

  const MasonryResult({
    required this.totalUnitsRequired,
    required this.netUnitsRequired,
    required this.coursesHigh,
    required this.unitsPerCourse,
    required this.wallSquareFeet,
    required this.mortarBagsEstimated,
    required this.wastePercent,
  });
}

/// Calculation engine for masonry bricks and CMU retaining wall blocks.
class MasonryMath {
  /// Calculates unit count for a wall: Wall Length x Wall Height.
  static MasonryResult calculateWall({
    required Length wallLength,
    required Length wallHeight,
    required double unitLengthInches,
    required double unitHeightInches,
    double mortarJointThicknessInches = 0.375, // 3/8" default
    double wastePercent = 10.0,
  }) {
    final effLengthInches = unitLengthInches + mortarJointThicknessInches;
    final effHeightInches = unitHeightInches + mortarJointThicknessInches;

    final wallLengthInches = wallLength.toInches();
    final wallHeightInches = wallHeight.toInches();

    final unitsPerCourse = (wallLengthInches / effLengthInches).ceil();
    final coursesHigh = (wallHeightInches / effHeightInches).ceil();

    final baseUnitCount = unitsPerCourse * coursesHigh;
    final totalWithWaste = (baseUnitCount * (1.0 + (wastePercent / 100.0))).ceil();

    final wallSqFt = wallLength.toFeet() * wallHeight.toFeet();

    // Standard rule of thumb: ~3 bags of mortar per 100 modular bricks or ~3 bags per 30 CMU blocks
    final isBlock = unitHeightInches >= 6.0;
    final mortarBags = isBlock
        ? (totalWithWaste / 30.0) * 3.0
        : (totalWithWaste / 100.0) * 3.5;

    return MasonryResult(
      totalUnitsRequired: totalWithWaste,
      netUnitsRequired: baseUnitCount,
      coursesHigh: coursesHigh,
      unitsPerCourse: unitsPerCourse,
      wallSquareFeet: wallSqFt,
      mortarBagsEstimated: (mortarBags * 10).ceil() / 10.0,
      wastePercent: wastePercent,
    );
  }
}
