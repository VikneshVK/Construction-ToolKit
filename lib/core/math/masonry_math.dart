import 'measurement.dart';

/// Common masonry block and brick standard types.
enum MasonryUnitType {
  standardCmu8('8x8x16 CMU Block', 7.625, 7.625, 15.625),
  standardCmu6('6x8x16 CMU Block', 5.625, 7.625, 15.625),
  standardCmu4('4x8x16 CMU Block', 3.625, 7.625, 15.625),
  standardModularBrick('Modular Brick (3.5x2.25x7.625)', 3.5, 2.25, 7.625),
  kingSizeBrick('King Size Brick (3x2.75x9.625)', 3.0, 2.75, 9.625),
  retainingWallBlock('Retaining Wall Block (12x4x8)', 8.0, 4.0, 12.0, isDryStacked: true);

  final String label;
  final double widthInches;
  final double heightInches;
  final double lengthInches;
  final bool isDryStacked;

  const MasonryUnitType(
    this.label,
    this.widthInches,
    this.heightInches,
    this.lengthInches, {
    this.isDryStacked = false,
  });
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
  final bool isDryStacked;

  const MasonryResult({
    required this.totalUnitsRequired,
    required this.netUnitsRequired,
    required this.coursesHigh,
    required this.unitsPerCourse,
    required this.wallSquareFeet,
    required this.mortarBagsEstimated,
    required this.wastePercent,
    this.isDryStacked = false,
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
    bool isDryStacked = false,
    double wastePercent = 10.0,
  }) {
    final effectiveJoint = isDryStacked ? 0.0 : mortarJointThicknessInches;
    final effLengthInches = unitLengthInches + effectiveJoint;
    final effHeightInches = unitHeightInches + effectiveJoint;

    final wallLengthInches = wallLength.toInches();
    final wallHeightInches = wallHeight.toInches();

    final unitsPerCourse = (wallLengthInches / effLengthInches).ceil();
    final coursesHigh = (wallHeightInches / effHeightInches).ceil();

    final baseUnitCount = unitsPerCourse * coursesHigh;
    final totalWithWaste = ((baseUnitCount * (1.0 + (wastePercent / 100.0))) - 1e-9).ceil();

    final wallSqFt = wallLength.toFeet() * wallHeight.toFeet();

    // Generic industry estimate: approximately 32 standard hollow CMU per 80-lb (36.3 kg) pre-blended mortar bag using face-shell bedding.
    // Retaining wall blocks are dry-stacked with no mortar.
    final isBlock = unitHeightInches >= 6.0;
    final mortarBags = isDryStacked
        ? 0.0
        : (isBlock
            ? totalWithWaste / 32.0
            : (totalWithWaste / 100.0) * 3.5);

    return MasonryResult(
      totalUnitsRequired: totalWithWaste,
      netUnitsRequired: baseUnitCount,
      coursesHigh: coursesHigh,
      unitsPerCourse: unitsPerCourse,
      wallSquareFeet: wallSqFt,
      mortarBagsEstimated: mortarBags.ceilToDouble(),
      wastePercent: wastePercent,
      isDryStacked: isDryStacked,
    );
  }
}
