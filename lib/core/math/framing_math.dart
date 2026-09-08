import 'measurement.dart';

/// Standard nominal dimensional lumber sizes.
enum NominalLumberSize {
  oneByFour('1x4', 0.75, 3.5, 1.0, 4.0),
  oneBySix('1x6', 0.75, 5.5, 1.0, 6.0),
  oneByEight('1x8', 0.75, 7.25, 1.0, 8.0),
  twoByFour('2x4', 1.5, 3.5, 2.0, 4.0),
  twoBySix('2x6', 1.5, 5.5, 2.0, 6.0),
  twoByEight('2x8', 1.5, 7.25, 2.0, 8.0),
  twoByTen('2x10', 1.5, 9.25, 2.0, 10.0),
  twoByTwelve('2x12', 1.5, 11.25, 2.0, 12.0),
  fourByFour('4x4', 3.5, 3.5, 4.0, 4.0),
  fourBySix('4x6', 3.5, 5.5, 4.0, 6.0),
  sixBySix('6x6', 5.5, 5.5, 6.0, 6.0);

  final String label;
  final double actualThicknessInches;
  final double actualWidthInches;
  final double nominalThicknessInches;
  final double nominalWidthInches;
  const NominalLumberSize(
    this.label,
    this.actualThicknessInches,
    this.actualWidthInches,
    this.nominalThicknessInches,
    this.nominalWidthInches,
  );
}

/// Result of Board-Feet and framing lumber calculation.
class BoardFeetResult {
  final double totalBoardFeet;
  final int pieceCount;
  final double? unitCost;
  final double? totalEstimatedCost;

  const BoardFeetResult({
    required this.totalBoardFeet,
    required this.pieceCount,
    this.unitCost,
    this.totalEstimatedCost,
  });
}

/// Calculation engine for framing lumber and board footage.
class FramingMath {
  /// Calculates Board Feet using nominal dimensions:
  /// Board Feet = (Nominal Thickness in inches * Nominal Width in inches * Length in feet) / 12 * Quantity
  static BoardFeetResult calculateBoardFeet({
    required double nominalThicknessInches,
    required double nominalWidthInches,
    required Length length,
    int quantity = 1,
    double? costPerBoardFoot,
  }) {
    final lengthFeet = length.toFeet();
    final singlePieceBf = (nominalThicknessInches * nominalWidthInches * lengthFeet) / 12.0;
    final totalBf = singlePieceBf * quantity;

    final totalCost = costPerBoardFoot != null ? totalBf * costPerBoardFoot : null;

    return BoardFeetResult(
      totalBoardFeet: totalBf,
      pieceCount: quantity,
      unitCost: costPerBoardFoot,
      totalEstimatedCost: totalCost,
    );
  }

  /// Calculates stud count for a framing wall run with on-center spacing (16" or 24" O.C.).
  /// Formula: (Wall Length / Spacing) + 1 + (extra corner/T-wall/plate allowances).
  static int calculateStudCount({
    required Length wallLength,
    required Length spacingOnCenter, // 16" or 24"
    int corners = 2,                 // 3 studs per corner usually
    int intersectingWalls = 0,       // 2 studs per T-intersection
    double wastePercent = 10.0,
  }) {
    final wallInches = wallLength.toInches();
    final spacingInches = spacingOnCenter.toInches();

    final baseStuds = (wallInches / spacingInches).ceil() + 1;
    final cornerStuds = corners * 2; // Extra beyond the 1 already in line
    final teeStuds = intersectingWalls * 2;

    final subtotal = baseStuds + cornerStuds + teeStuds;
    final totalWithWaste = (subtotal * (1.0 + (wastePercent / 100.0))).ceil();

    return totalWithWaste;
  }
}
